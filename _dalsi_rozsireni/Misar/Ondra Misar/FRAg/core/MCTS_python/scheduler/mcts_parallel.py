"""
Author: Ondrej Misar
Description: Implementation of parallel MCTS version, uses the persistent worker that starts the Prolog instance
             MCTS implementation and Worker communicate using the job and result queue
"""


from multiprocessing import Process, Queue
import time
from loguru import logger

import MCTS_python.scheduler.mctsnode as node
from MCTS_python.scheduler.base_mcts import BaseMCTS, parse_program_thread, parse_environment_thread
from swiplserver import PrologMQI

class PrologWorker(Process):
    def __init__(self, job_queue: Queue, result_queue: Queue, environment_path, environment_name, steps):
        super().__init__()
        self.job_queue = job_queue
        self.result_queue = result_queue
        self.environment_path = environment_path
        self.environment_name = environment_name
        self.steps = steps

    def run(self):
        """
        Proces class that initiates the prolog at the start then takes the jobs from the queue, calls roll out and puts the result to the queue
        """
        with PrologMQI() as mqi:
            with mqi.create_thread() as prolog_thread:
                # Initiate the FRAg program
                prolog_thread.query("consult('FragPL.pl').")

                prolog_thread.query(f"""
                                        fRAgAgent:load_environment('{self.environment_path}'), !,
                                        fRAgAgent:set_default_environment({self.environment_name}), !,
                                        fRAgAgent:fa_init_run, !,
                                        fRAgAgent:fa_init_environments, !,
                                        assertz(fRAgAgent:virtual_mode(true)),
                                        assertz(fRAgAgent:late_bindings(true)),
                                        assertz(fRAgAgent:simulate_late_bindings(true)),
                                        fRAgAgent:set_reasoning(random_reasoning).
                                        """)

                while True:
                    # Receive the job from queue
                    job = self.job_queue.get()
                    if job is None:
                        break

                    sim_id, (program, environment) = job
                    logger.debug(f"Worker {self.pid} got a job")

                    try:
                        # Parse the program and environment and assert it to the prolog instance
                        batched_asserts = []
                        num_event, num_intention = parse_program_thread(program, batched_asserts)

                        if batched_asserts:
                            query = ", ".join(batched_asserts) + "."
                            prolog_thread.query(query)

                        prolog_thread.query(f"""
                                                    assert(fRAgAgent:intention_fresh({num_intention + 1})),
                                                    assert(fRAgAgent:event_fresh({num_event + 1})).
                                                    """)

                        prolog_thread.query("env_utils:delete_facts.")

                        facts_batched = []
                        parse_environment_thread(environment, facts_batched)

                        if facts_batched:
                            query = ", ".join(facts_batched) + "."
                            prolog_thread.query(query)

                        start_time = time.perf_counter()

                        # Start roll out
                        mcts_res = prolog_thread.query(f'fRAgAgent:mcts_rollouts_call_service({self.steps}, Final_Result), !.')

                        end_time = time.perf_counter()
                        elapsed_time = end_time - start_time
                        logger.debug(f"Roll out completed in {elapsed_time:.4f} seconds.")
                        value =  mcts_res[0]["Final_Result"]["args"][0]

                        # Put result to the queue
                        self.result_queue.put((sim_id, value))

                    except Exception as e:
                        self.result_queue.put((sim_id, f"Error: {str(e)}"))



class MCTS(BaseMCTS):

    def __init__(
            self,
            root_program: str,
            root_environment: str,
            alpha: int,
            beta: int,
            steps: int,
            environment_name: str,
            environment_path: str):
        super(MCTS, self).__init__(root_program, root_environment,alpha,beta,steps,environment_name,environment_path)

        self.job_queue = Queue()
        self.result_queue = Queue()
        self.num_workers = 4
        self.workers = []

    def run_all_simulations(self, new_node):
        """
        Create new jobs in queue that the simulation should be run for
        :param new_node: Node that the simulation should be run for
        """
        for i in range(self.beta):
            self.job_queue.put((i, (new_node.program, new_node.environment)))

        results = [None] * self.beta
        for _ in range(self.beta):
            sim_id, value = self.result_queue.get()
            results[sim_id] = value

        return results

    def run(self) -> node.MctsNode:

        root_node = node.MctsNode(self.root_program, self.root_environment, "model_act_node(no_intention,no_action,[[]])", True)

        visited = []

        # Initiate persistent workers
        self.workers = [
            PrologWorker(self.job_queue, self.result_queue, self.environment_path, self.environment_name, self.steps)
            for _ in range(self.num_workers)
        ]
        for worker in self.workers:
            worker.start()

        for i in range(self.alpha):
            if self.is_root_one_chice(i, root_node):
                break

            current_node = root_node
            visited.clear()

            visited.append(current_node)

            start_time_expansion = time.perf_counter()

            new_node = self.selection_expansion(root_node, current_node, self.environment_name, visited)

            end_time_expansion = time.perf_counter()
            elapsed_time_expansion = end_time_expansion - start_time_expansion
            logger.debug(f"Whole selection and Expansion completed in {elapsed_time_expansion:.4f} seconds.")

            start_time = time.perf_counter()

            simulations = self.run_all_simulations(new_node)

            end_time = time.perf_counter()
            elapsed_time = end_time - start_time
            logger.debug(f"All processes completed in {elapsed_time:.4f} seconds.")

            self.rollouts += 1

            logger.debug(simulations)
            logger.info(f"Best simulation: {max(simulations)}")

            self.back_propagation(max(simulations), visited)

        root_node.print_tree(1)

        best_node = root_node.select_max_children()

        reasoning_prefix, act = self.get_final_prefix_act(best_node)

        # Stop the persistent workers
        for _ in self.workers:
            self.job_queue.put(None)

        for worker in self.workers:
            worker.join()

        return reasoning_prefix, act

