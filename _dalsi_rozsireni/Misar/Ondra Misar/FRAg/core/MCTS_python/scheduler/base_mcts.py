"""
Author: Ondrej Misar
Description: Base class of MCTS that implements selection, expansion and back propagation
             This file contains utility functions for parsing the program and environment
"""

import math
import time
from loguru import logger

import MCTS_python.scheduler.mctsnode as node
from swiplserver import PrologMQI


def split_top_level_items(text: str) -> list[str]:
    """
    Takes in a string that contains all the predicates and splits them by the top level closure
    :param text: Text that contains multiple predicates
    :return: List of every predicate
    """
    result = []
    buffer = []
    depth = 0
    i = 0

    while i < len(text):
        char = text[i]

        if char == '(':
            depth += 1
        elif char == ')':
            depth -= 1

        if depth == 0 and text[i:i + 5] in [',fact', ',even', ',plan', ',inte']:
            result.append(''.join(buffer))
            buffer = []
            i += 1
            continue

        buffer.append(char)
        i += 1

    if buffer:
        result.append(''.join(buffer))

    return result


def parse_program_thread(program: str, batched_asserts):
    """
    Takes in the whole program string and creates an assert query for every predicate.
    :param program: The program of agent in string format
    :param batched_asserts: List where should the assert query be stored
    :return: Number for events and intentions
    """
    new = program.strip()[1:-1]
    new = new.replace(" ", "")
    splits = split_top_level_items(new)
    event = 0
    intention = 0
    for item in splits:
        for prefix in ("fact", "event", "plan", "intention"):
            if item.startswith(prefix):
                match prefix:
                    case "fact":
                        if not "reward" in item:
                            batched_asserts.append(f"assertz(fRAgAgent:{item})")
                    case "event":
                        batched_asserts.append(f"assertz(fRAgAgent:{item})")
                        event += 1
                    case "plan":
                        batched_asserts.append(f"assertz(fRAgAgent:{item})")
                    case "intention":
                        batched_asserts.append(f"assertz(fRAgAgent:{item})")
                        intention += 1
                break

    return event, intention


def parse_environment_thread(environment: str, batched_asserts):
    """
    Takes in the whole environment as a string and creates an assert query for every predicate.
    :param environment: The environment in string format
    :param batched_asserts: List where should the assert query be stored
    """
    new = environment.strip()[1:-1]
    new = new.replace(" ", "")
    splits = split_top_level_items(new)
    for item in splits:
        for prefix in ("fact", "event", "plan", "intention"):
            if item.startswith(prefix):
                match prefix:
                    case "fact":
                        if not "reward" in item:
                            batched_asserts.append(f"assertz(env_utils:{item})")
                    case "event":
                        batched_asserts.append(f"assertz(env_utils:{item})")
                    case "plan":
                        batched_asserts.append(f"assertz(env_utils:{item})")
                    case "intention":
                        batched_asserts.append(f"assertz(env_utils:{item})")
                break


class BaseMCTS:
    def __init__(
            self,
            root_program: str,
            root_environment: str,
            alpha: int,
            beta: int,
            steps: int,
            environment_name: str,
            environment_path: str):
        self.root_program = root_program
        self.root_environment = root_environment
        self.alpha = alpha
        self.beta = beta
        self.steps = steps
        self.environment_name = environment_name
        self.environment_path = environment_path
        self.rollouts = 0
        self.epsilon = 1e-6

    def uct(self, parent: node.MctsNode, children: node.MctsNode, c: float) -> float:
        """
        Calculates the UCT value for children MCTS node.
        :param parent: Parent MCTS node
        :param children: Child MCTS node
        :param c: Constant C that is used for exploration
        :return: UCT value for the child node
        """
        average_value = children.total_value / (children.visits * 3)

        exploration_value = c * math.sqrt(math.log(parent.visits + 1) / children.visits)

        return average_value + exploration_value

    def selection(self, current_node: node.MctsNode) -> node.MctsNode:
        """
        Selects a next MCTS node based on the UCT value of every node until the leaf node is reached
        :param current_node: Root node from which the selection starts
        :return: Next MCTS node that should be expanded
        """
        selected_node = None

        best_uct = float('-inf')

        for child in current_node.children:
            if child.visits == 0:
                return child

            uct = self.uct(current_node, child, 2.0 * math.sqrt(2.0))
            if uct > best_uct:
                best_uct = uct
                selected_node = child

        return selected_node

    def back_propagation(self, best_simulation: int, visited: list[node.MctsNode]):
        """
        Back propagate the best simulation value to every visited MCTS node
        :param best_simulation: Value of the best simulation
        :param visited: All the MCTS nodes that were visited
        """
        for visited_node in visited:
            visited_node.visits = visited_node.visits + 1
            visited_node.total_value = visited_node.total_value + best_simulation

    def selection_expansion(self, root_node: node.MctsNode, current_node: node.MctsNode, environment_name: str, visited) -> node.MctsNode:
        """
        Perform both selection phase and expansion phase
        :param root_node: Root MCTS node
        :param current_node: Node from which the selection starts
        :param environment_name: Name of the environment that is used
        :param visited: List of visited MCTS nodes
        :return: New MCTS node for which the simulation should be performed
        """
        with PrologMQI() as mqi:
            with mqi.create_thread() as prolog_thread:
                start_time_expansion = time.perf_counter()
                prolog_thread.query("consult('FragPL.pl').")

                batched_asserts = []
                num_event, num_intention = parse_program_thread(root_node.program, batched_asserts)

                if batched_asserts:
                    query = ", ".join(batched_asserts) + "."
                    prolog_thread.query(query)

                prolog_thread.query(f"""
                                    fRAgAgent:load_environment('{self.environment_path}'), !,
                                    fRAgAgent:set_default_environment({self.environment_name}), !,
                                    fRAgAgent:fa_init_run, !,
                                    fRAgAgent:fa_init_environments, !,
                                    assertz(fRAgAgent:late_bindings(true)),
                                    assertz(fRAgAgent:simulate_late_bindings(true)),
                                    assert(fRAgAgent:intention_fresh({num_intention + 1})),
                                    assert(fRAgAgent:event_fresh({num_event + 1})).
                                    """)

                prolog_thread.query("env_utils:delete_facts.")

                facts_batched = []
                parse_environment_thread(root_node.environment, facts_batched)

                if facts_batched:
                    query = ", ".join(facts_batched) + "."
                    prolog_thread.query(query)

                while current_node is not None and not current_node.is_leaf():

                    current_node = self.selection(current_node)
                    if current_node.is_root is None:
                        if "model_act_node" in current_node.deliberation:
                            prolog_thread.query(f"""
                                    fRAgAgent:force_execution(Node_ID, {current_node.deliberation}, 0), !,
                                    fRAgAgent:force_perceiving, !.
                                """)

                        if "model_reasoning_node" in current_node.deliberation:
                            prolog_thread.query(f"fRAgAgent:force_reasoning(Node_ID, {current_node.deliberation}), !.")

                    if current_node is not None:
                        visited.append(current_node)

                current_node.expand(prolog_thread, environment_name)

                new_node = current_node.select_random_children()

                if new_node is None:
                    new_node = current_node
                else:
                    visited.append(new_node)

                end_time_expansion = time.perf_counter()
                elapsed_time_expansion = end_time_expansion - start_time_expansion
                logger.debug(f"Inner selection and Expansion completed in {elapsed_time_expansion:.4f} seconds.")

        return new_node

    def get_final_prefix_act(self, best_node: node.MctsNode):
        """
        Select the final reasoning and action from the best MCTS node
        :param best_node: Best MCTS node
        :return: The reasoning and action that should be scheduled
        """
        reasoning_prefix = []
        act = []

        while best_node is not None and "model_act_node" not in best_node.deliberation:
            if best_node is not None and "model_reasoning_node" in best_node.deliberation:
                reasoning_prefix.append(best_node)
                best_node = best_node.select_max_children()

        if best_node is not None and "model_act_node" in best_node.deliberation:
            act.append(best_node)

        return reasoning_prefix, act

    def is_root_one_chice(self, alfa_loop, root_node: node.MctsNode) -> bool:
        """
        Is there is only one choice from the root node, we do not need to continue in Alpha expansion
        :param alfa_loop: The index of alpha loop
        :param root_node: Root MCTS node
        :return: If there is only one choice from the root node
        """
        if alfa_loop > 0 and len(root_node.children) == 1:
            if "model_act_node" in root_node.children[0].deliberation:
                return True
            if "model_reasoning_node" in root_node.children[0].deliberation:
                if len(root_node.children[0].children) == 1:
                    if "model_act_node" in root_node.children[0].children[0].deliberation:
                        return True

        return False
