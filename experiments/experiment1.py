"""
Author: Ondrej Misar
Description: Implementation of first experiment, which runs the garden and task maze example of different configurations
             After every run completes the time it took for every run and average value of every run is saved
"""

import subprocess
import time

from base_experiment import BaseExperiment


class Experiment1(BaseExperiment):

    def one_test_case(self, method, steps, alpha, beta, roll_out_steps):
        """
        Takes the method, moves the configuration file of said method to the main package and runs the configuration
        After all the runs finish, the results are saved to output path, does not save individual runs, only the time results
        :param method: the name of method that the experiment is run for
        :param steps: number of steps after which the FRAg simulation is terminated
        :param alpha: Alpha computation budget
        :param beta: Beta computation budget
        :param roll_out_steps: Number of steps in roll out
        """
        time_taken = []
        method_path = f"{self.result_dir}/{method}"
        method_output = f"{self.result_dir}/{method}/experiment1/{alpha}-{beta}"

        for i in range(1, self.num_runs + 1):
            print(f"Run {i}...")

            self.replace_file_content(f"{method_path}/{self.program_setting}", self.prolog_setting)
            self.update_reasoning_params(
                self.prolog_setting,
                '(reasoning_params, mcts_params(5,5,60)),',
                f'(reasoning_params, mcts_params({alpha},{beta},{roll_out_steps})),'
            )
            self.update_reasoning_params(
                self.prolog_setting,
                '(control, terminate(timeout, 25)),',
                f'(control, terminate(timeout, {steps})),'
            )

            start_time_expansion = time.perf_counter()
            subprocess.run(['swipl', '-l', '../core/FragPL.pl', '-g', self.prolog_program, '-g', 'halt'])
            end_time_expansion = time.perf_counter()
            elapsed_time_expansion = end_time_expansion - start_time_expansion
            time_taken.append(elapsed_time_expansion)

        self.write_time_result(method_output, time_taken)


if __name__ == '__main__':
    exp1 = Experiment1(
        "frag('../examples/task_maze/task_maze').",
        "../examples/task_maze/task_maze.mas2fp",
        "../examples/task_maze",
        "task_maze_task_maze.out",
        "../examples/task_maze",
        10,
        "task_maze.mas2fp")

    exp1.one_test_case("mcts-prolog", 5, 1, 1, 40)
    exp1.one_test_case("mcts-internal", 5, 1, 1, 40)
    exp1.one_test_case("mcts-external-sequential", 5, 1, 1, 40)
    exp1.one_test_case("mcts-external-parallel", 5, 1, 1, 40)

    exp1.one_test_case("mcts-prolog", 5, 5, 5, 40)
    exp1.one_test_case("mcts-internal", 5, 5, 5, 40)
    exp1.one_test_case("mcts-external-sequential", 5, 5, 5, 40)
    exp1.one_test_case("mcts-external-parallel", 5, 5, 5, 40)

    exp1.one_test_case("mcts-prolog", 5, 10, 10, 40)
    exp1.one_test_case("mcts-internal", 5, 10, 10, 40)
    exp1.one_test_case("mcts-external-sequential", 5, 10, 10, 40)
    exp1.one_test_case("mcts-external-parallel", 5, 10, 10, 40)

    exp2 = Experiment1(
        "frag('../examples/garden/garden').",
        "../examples/garden/garden.mas2fp",
        "../examples/garden",
        "garden_garden.out",
        "../examples/garden",
        10,
        "garden.mas2fp")

    exp2.one_test_case("mcts-prolog", 5, 1, 1, 40)
    exp2.one_test_case("mcts-internal", 5, 1, 1, 40)
    exp2.one_test_case("mcts-external-sequential", 5, 1, 1, 40)
    exp2.one_test_case("mcts-external-parallel", 5, 1, 1, 40)

    exp2.one_test_case("mcts-prolog", 5, 5, 5, 40)
    exp2.one_test_case("mcts-internal", 5, 5, 5, 40)
    exp2.one_test_case("mcts-external-sequential", 5, 5, 5, 40)
    exp2.one_test_case("mcts-external-parallel", 5, 5, 5, 40)

    exp2.one_test_case("mcts-prolog", 5, 10, 10, 40)
    exp2.one_test_case("mcts-internal", 5, 10, 10, 40)
    exp2.one_test_case("mcts-external-sequential", 5, 10, 10, 40)
    exp2.one_test_case("mcts-external-parallel", 5, 10, 10, 40)
