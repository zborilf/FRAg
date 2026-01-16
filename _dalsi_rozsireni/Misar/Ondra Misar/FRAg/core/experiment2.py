"""
Author: Ondrej Misar
Description: Implementation of second experiment, which runs the garden example of different configurations
             Each run output is saved and plots are created as result
"""


import subprocess
import time

from base_experiment import BaseExperiment


class Experiment2(BaseExperiment):

    def one_test_case(self, method, steps, alpha=0, beta=0, roll_out_steps=60):
        """
        Takes the method, moves the configuration file of said method to the main package and runs the configuration
        After all the runs finish, the results are saved to output path
        :param method: the name of method that the experiment is run for
        :param steps: number of steps after which the FRAg simulation is terminated
        :param alpha: Alpha computation budget
        :param beta: Beta computation budget
        :param roll_out_steps: Number of steps in roll out
        """
        time_taken = []
        method_path = f"{self.result_dir}/{method}"
        method_output = f"{self.result_dir}/{method}/experiment2/{alpha}-{beta}-{roll_out_steps}"

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

            start_time = time.perf_counter()
            subprocess.run(['swipl', '-l', 'FragPL.pl', '-g', self.prolog_program, '-g', 'halt'])
            end_time = time.perf_counter()
            elapsed_time = end_time - start_time
            time_taken.append(elapsed_time)

            self.write_run_result(method_output, i)

        self.write_time_result(method_output, time_taken)


if __name__ == '__main__':
    exp = Experiment2(
        "frag('../examples/garden/garden').",
        "../examples/garden/garden.mas2fp",
        "../examples/garden",
        "garden_garden.out",
        "../examples/garden",
        5,
        "garden.mas2fp")


    exp.one_test_case("random", 50)
    exp.one_test_case("robin", 50)

    exp.one_test_case("mcts-prolog", 50, 5, 5, 5)
    exp.one_test_case("mcts-external-sequential", 50, 5, 5, 5)
    exp.one_test_case("mcts-external-parallel", 50, 5, 5, 5)
    exp.one_test_case("mcts-online-learning", 50, 5, 5, 5)

    exp.one_test_case("mcts-prolog", 50, 10, 5, 5)
    exp.one_test_case("mcts-external-sequential", 50, 10, 5, 5)
    exp.one_test_case("mcts-external-parallel", 50, 10, 5, 5)
    exp.one_test_case("mcts-online-learning", 50, 10, 5, 5)

    exp.one_test_case("mcts-prolog", 50, 10, 10, 5)
    exp.one_test_case("mcts-external-sequential", 50, 10, 10, 5)
    exp.one_test_case("mcts-external-parallel", 50, 10, 10, 5)
    exp.one_test_case("mcts-online-learning", 50, 10, 10, 5)

    exp.one_test_case("mcts-prolog", 50, 15, 10, 5)
    exp.one_test_case("mcts-external-sequential", 50, 15, 10, 5)
    exp.one_test_case("mcts-external-parallel", 50, 15, 10, 5)
    exp.one_test_case("mcts-online-learning", 50, 15, 10, 5)

    exp.one_test_case("mcts-prolog", 50, 5, 5, 3)
    exp.one_test_case("mcts-external-sequential", 50, 5, 5, 3)
    exp.one_test_case("mcts-external-parallel", 50, 5, 5, 3)
    exp.one_test_case("mcts-online-learning", 50, 5, 5, 3)

    exp.one_test_case("mcts-prolog", 50, 5, 5, 4)
    exp.one_test_case("mcts-external-sequential", 50, 5, 5, 4)
    exp.one_test_case("mcts-external-parallel", 50, 5, 5, 4)
    exp.one_test_case("mcts-online-learning", 50, 5, 5, 4)

    exp.one_test_case("mcts-prolog", 50, 5, 5, 8)
    exp.one_test_case("mcts-external-sequential", 50, 5, 5, 8)
    exp.one_test_case("mcts-external-parallel", 50, 5, 5, 8)
    exp.one_test_case("mcts-online-learning", 50, 5, 5, 8)
