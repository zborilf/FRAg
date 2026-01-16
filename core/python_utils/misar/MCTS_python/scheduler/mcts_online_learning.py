"""
Author: Ondrej Misar
Description: Implementation of online learning MCTS variant, uses the state-action tree defined in mctsnode.py
"""

import MCTS_python.scheduler.mctsnode as node
from MCTS_python.scheduler.base_mcts import BaseMCTS, parse_program_thread, parse_environment_thread
from loguru import logger
from swiplserver import PrologMQI, json_to_prolog


class MCTS(BaseMCTS):

    def update_state_action(self, root, simulation_actions, simulation_result):
        """
        Update the value of state action nodes based on which actions where executed during the roll  out
        :param root: Root node of state action tree
        :param simulation_actions: Actions that were taken during the roll out
        :param simulation_result: Value of the roll out
        """
        for child in root.children:
            for saction in simulation_actions:
                if child.action.action == saction.action and child.action.name == saction.name:
                    child.total_value = child.total_value + simulation_result
            if len(child.children) != 0:
                self.update_state_action(child, simulation_actions, simulation_result)

    def get_action(self, actions, action_new):
        """
        Check if the new action exists, if not create it, otherwise return it
        :param actions: All the actions that were already created
        :param action_new: New action that is created
        :return: Action object
        """
        for action in actions:
            if action.action == action_new:
                return action

        if not any(action.action == action_new for action in actions):
            numeric_names = [action.name for action in actions]
            max_name = max(numeric_names) if numeric_names else 1
            new_name = max_name + 1
            action_object = node.Action(action_new, new_name)
            actions.append(action_object)
            return action_object

        return None

    def simulation(self, new_node: node.MctsNode, thread, root, actions) -> int:
        state_action = root
        simulation_actions = []

        # Call simulation for the Expanded node
        mcts_res = thread.query(f'fRAgAgent:mcts_rollouts_learning({self.steps}, Final_Result), !.')

        # Process the roll out result
        process_list = []
        for item in mcts_res[0]["Final_Result"]["args"][1]:
            action_new = json_to_prolog(item["args"][1])
            program_from_state = json_to_prolog(item["args"][0])
            process_list.append((program_from_state, action_new))

        # Create the queue of steps that were taken during the roll out
        sorted_list = []
        for index, (program, action) in enumerate(process_list):
            if index == 0:
                sorted_list.append((program, action))
                root.program = program
            else:
                if (index + 1) < len(process_list):
                    next_program, next_action = process_list[index + 1]
                    sorted_list.append((next_program, action))
                else:
                    sorted_list.append(("", action))

        # Update the state action tree from the queue of steps
        for (program, action) in sorted_list:
            action_object = self.get_action(actions, action)

            simulation_actions.append(action_object)
            new_state_action = node.StateAction(program, action_object)
            continuation_node = state_action.add_child(new_state_action)
            state_action = continuation_node

        simulation_result = mcts_res[0]["Final_Result"]["args"][0]
        self.update_state_action(root, simulation_actions, simulation_result)
        return simulation_result

    def insert_state_action(self, root, batched_asserts):
        for child in root.children:
            #value_of_node = child.total_value / child.visits
            batched_asserts.append(
                f"assertz(fRAgAgent:state_action({root.program}, {child.action.action}, {child.total_value}))")
            self.insert_state_action(child, batched_asserts)

    def run_all_simulations(self, new_node, root, actions, prolog_thread):
        """
        Run all the simulations based on the beta budget and return the results
        :param new_node: Node for which the simulation should be run
        :param root: Root node of state action tree
        :param actions: All the actions that were already created
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
                                        fRAgAgent:set_reasoning(random_reasoning_learning).
                                        """)

        simulations_sq = []
        for i in range(self.beta):

            # Parse the program and environment and assert it to the prolog instance
            batched_asserts = []
            num_event, num_intention = parse_program_thread(new_node.program, batched_asserts)

            self.insert_state_action(root, batched_asserts)

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

            simulations_sq.append(self.simulation(new_node, prolog_thread, root, actions))

        return simulations_sq

    def run(self) -> node.MctsNode:

        root_node = node.MctsNode(self.root_program, self.root_environment,
                                  "model_act_node(no_intention,no_action,[[]])", True)

        visited = []

        for i in range(self.alpha):
            if self.is_root_one_chice(i, root_node):
                break

            current_node = root_node
            visited.clear()

            visited.append(current_node)

            new_node = self.selection_expansion(root_node, current_node, self.environment_name, visited)

            simulations = []
            actions = []
            action = node.Action("", 0)

            root = node.StateAction(new_node.program, action, True)
            actions.append(action)

            with PrologMQI() as mqi:
                with mqi.create_thread() as prolog_thread:
                    simulations = self.run_all_simulations(new_node, root, actions, prolog_thread)

            # root.print_tree(0)

            self.rollouts += 1

            logger.debug(simulations)
            logger.info(f"Best simulation: {max(simulations)}")

            self.back_propagation(max(simulations), visited)

        root_node.print_tree(1)

        best_node = root_node.select_max_children()

        reasoning_prefix, act = self.get_final_prefix_act(best_node)

        return reasoning_prefix, act
