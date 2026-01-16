"""
Author: Ondrej Misar
Description: This file defines the MCTS node structure and State-Action tree node structure
"""

import copy
import random
import typing

from loguru import logger
from swiplserver import json_to_prolog


class MctsNode:
    def __init__(self, program, environment, deliberation, is_root=None):
        self.children = []
        self.visits = 0
        self.total_value = 0
        self.program = program
        self.environment = environment
        self.deliberation = deliberation
        self.is_root = is_root
        self.is_expanded = False

    def clone(self):
        return copy.deepcopy(self)

    def expand(self, thread, environment_name: str):
        """
        Expands the MCTS node based on the current state of agent
        :param thread: Prolog thread
        :param environment_name: Name of the environment that is used
        """
        expanded_act = thread.query("fRAgAgent:model_expand_actions(Expanded_Acts), !.")
        expanded_plans = thread.query("fRAgAgent:model_expand_deliberations(Expanded_Plans), !.")

        program_snapshot = thread.query("fRAgAgent:take_snapshot(Program2).")
        prolog_term_program = json_to_prolog(program_snapshot[0]["Program2"])

        environment = thread.query(f"env_utils:all_facts_struct({environment_name}, Agent, Facts).")
        prolog_environment = json_to_prolog(environment[0]["Facts"])

        for new_item in expanded_plans[0]["Expanded_Plans"] + expanded_act[0]["Expanded_Acts"]:
            new_node = MctsNode(prolog_term_program, prolog_environment, json_to_prolog(new_item))
            self.children.append(new_node)
        self.is_expanded = True

    def select_random_children(self) -> typing.Self | None:
        if len(self.children) > 0:
            return random.choice(self.children)
        else:
            return None

    def select_max_children(self) -> typing.Self:
        best_value = -1
        best_child = None
        for child in self.children:
            if child.total_value > best_value:
                best_value = child.total_value
                best_child = child

        return best_child

    def is_leaf(self) -> bool:
        return len(self.children) == 0

    def print_tree(self, index):
        slash = " - " * index
        logger.debug(f"{slash} {self}")
        index = index + 1
        for child in self.children:
            child.print_tree(index)

    def __str__(self):
        return f"[visit: {self.visits} / value: {self.total_value}] {self.deliberation}"


class Action:
    def __init__(self, action, name):
        self.action = action
        self.name = name

    def __str__(self):
        return f"Name: {self.name}, action hash: "


class StateAction:
    def __init__(self, program, action, is_root=None):
        self.children = []
        self.visits = 1
        self.total_value = 0
        self.program = program
        self.action = action
        self.is_root = is_root

    def is_child(self, state_action):
        for child in self.children:
            if child.program == state_action.program and child.action == state_action.action:
                child.visits = child.visits + 1
                return child
        return None

    def add_child(self, state_action):
        """
        Check if the input node is in the current node, if yes increment the statistics, if no add it as a child node
        :param state_action: StateAction node that should be added to current node
        :return: Next StateAction node that should be checked
        """
        if len(self.children) == 0:
            self.children.append(state_action)
            return state_action
        else:
            existing_child = self.is_child(state_action)

            if existing_child is None:
                self.children.append(state_action)
                return state_action
            else:
                return existing_child

    def print_tree(self, index):
        slash = " - " * index
        logger.debug(f"{slash} Depth: {index} {self}")
        index = index + 1
        for child in self.children:
            child.print_tree(index)

    def __str__(self):
        return f"[visit: {self.visits} / value: {self.total_value}] program:{self.program} action: {self.action}"
