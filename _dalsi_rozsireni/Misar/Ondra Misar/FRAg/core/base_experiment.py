"""
Author: Ondrej Misar
Description: The base experiment class implements methods for file manipulation and replacing content,
             also includes the methods for writing the result to a file
"""

import os

from plot_results import write_run_result


class BaseExperiment:
    def __init__(self, prolog_program, prolog_setting, output_dir, output_file, result_dir, num_runs, program_setting):
        self.prolog_program = prolog_program
        self.prolog_setting = prolog_setting
        self.output_dir = output_dir
        self.output_file = output_file
        self.result_dir = result_dir
        self.num_runs = num_runs
        self.program_setting = program_setting

    def replace_file_content(self, source_path, target_path):
        with open(source_path, 'r', encoding='utf-8') as src:
            content = src.read()

        with open(target_path, 'w', encoding='utf-8') as dst:
            dst.write(content)

    def update_reasoning_params(self, file_path, old_params, new_params):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        updated_content = content.replace(old_params, new_params)

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(updated_content)

    def write_time_result(self, method_output, time_taken):
        """
        Create a result file that contains a time for each run and the average value of all the runs.
        :param method_output: Path where the results for time should be stored
        :param time_taken: List that contains times for runs
        """
        os.makedirs(method_output, exist_ok=True)
        result_file = os.path.join(method_output, "results.txt")
        with open(result_file, 'w', encoding='utf-8') as f:
            f.write("Run times (seconds):\n")
            for idx, t in enumerate(time_taken, start=1):
                f.write(f"Run {idx}: {t:.4f}s\n")
            f.write(f"\nAverage time: {sum(time_taken) / len(time_taken):.4f}s\n")

        print(f"Results written to {result_file}")

    def write_run_result(self, method_output, i):
        """
        Takes current output file and renames it and moves it to the path of where the results should be store,
        for every run a plot for zones and watter level is created and saved to the same path.
        :param method_output: Path where the results for time should be stored
        :param i: Index of a run
        """
        os.makedirs(method_output, exist_ok=True)
        src = os.path.join(self.output_dir, self.output_file)
        dst = os.path.join(method_output, f"run_{i}.out")

        if os.path.exists(dst):
            os.remove(dst)

        if os.path.exists(src):
            os.rename(src, dst)
            print(f"Renamed {self.output_file} to run_{i}")

            write_run_result(method_output, i)
            print("Saved plots")

        else:
            print(f"Error: Expected output file '{self.output_file}' not found.")
