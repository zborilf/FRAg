"""
Author: Ondrej Misar
Description: Implementation of basic MCTS variant, sequential run of all simulations
"""


import time
from loguru import logger

import MCTS_python.scheduler.mctsnode as node
from MCTS_python.scheduler.base_mcts import BaseMCTS, parse_program_thread, parse_environment_thread
from swiplserver import PrologMQI

class MCTS(BaseMCTS):

    def simulation(self, new_node: node.MctsNode, thread) -> int:
        start_time = time.perf_counter()
        # Start roll out
        mcts_res = thread.query(f'fRAgAgent:mcts_rollouts_integrated_python({self.steps}, Final_Result), !.')

        end_time = time.perf_counter()
        elapsed_time = end_time - start_time
        logger.debug(f"Roll out completed in {elapsed_time:.4f} seconds.")

        return mcts_res[0]["Final_Result"]["args"][0]

    def run_all_simulations(self, new_node: node.MctsNode, prolog_thread):
        """
        Run all the simulations based on the beta budget and return the results
        :param new_node: Node for which the simulation should be run
        :param prolog_thread: Prolog thread for executing the prolog queries
        :return: List of all the simulation results
        """

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


        simulations_sq = []
        for i in range(self.beta):

            start_time = time.perf_counter()

            # Parse the program and environment and assert it to the prolog instance
            batched_asserts = []
            num_event, num_intention = parse_program_thread(new_node.program, batched_asserts)

            if batched_asserts:
                query = ", ".join(batched_asserts) + "."
                prolog_thread.query(query)

            prolog_thread.query(f"""
                                        assert(fRAgAgent:intention_fresh({num_intention + 1})),
                                        assert(fRAgAgent:event_fresh({num_event + 1})).
                                        """)

            prolog_thread.query("env_utils:delete_facts.")

            facts_batched = []
            parse_environment_thread(new_node.environment, facts_batched)

            if facts_batched:
                query = ", ".join(facts_batched) + "."
                prolog_thread.query(query)

            simulations_sq.append(self.simulation(new_node, prolog_thread))

            end_time = time.perf_counter()
            elapsed_time = end_time - start_time
            logger.debug(f"One simulation completed in {elapsed_time:.4f} seconds.")
        return simulations_sq

    def run(self) -> node.MctsNode:

        root_node = node.MctsNode(self.root_program, self.root_environment, "model_act_node(no_intention,no_action,[[]])", True)

        visited = []

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

            simulations = []
            with PrologMQI() as mqi:
                with mqi.create_thread() as prolog_thread:
                    simulations = self.run_all_simulations(new_node, prolog_thread)


            end_time = time.perf_counter()
            elapsed_time = end_time - start_time
            logger.debug(f"All Simulations completed in {elapsed_time:.4f} seconds.")


            self.rollouts += 1

            logger.debug(simulations)
            logger.info(f"Best simulation: {max(simulations)}")

            self.back_propagation(max(simulations), visited)

        root_node.print_tree(1)

        best_node = root_node.select_max_children()

        reasoning_prefix, act = self.get_final_prefix_act(best_node)

        return reasoning_prefix, act

