"""
Author: Ondrej Misar
Description: Creates the zone moisture and water tank level plots for specific output file.
"""

import os
import re

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


def get_zone_hydration(loop_text, zone):
    match = re.search(rf"fact\(garden, garden, zone_moisture\({zone}, (\d+)\)\)\.", loop_text)
    if match:
        return int(match.group(1))
    else:
        return 0


def get_water_tank(loop_text):
    match = re.search(r"fact\(garden, garden, available_water\((\d+)\)\)\.", loop_text)
    if match:
        return int(match.group(1))
    else:
        return 0


def extract_data(filename):
    """
    Extracts water tank levels and zone moisture level from text file.
    :param filename: Path to file from which the data should be extracted
    :return: List of water levels, List of zone moisture levels
    """
    with open(filename, 'r') as file:
        content = file.read()

    loops = re.split(r"=+\s*Loop (\d+) started\s*=+", content)
    zone_by_loop = []
    water_by_loop = []

    for i in range(1, len(loops), 2):
        loop_num = int(loops[i])
        loop_text = loops[i + 1]

        water_amount = get_water_tank(loop_text)
        water_by_loop.append((loop_num, water_amount))

        zone_a = get_zone_hydration(loop_text, "a")
        zone_b = get_zone_hydration(loop_text, "b")
        zone_c = get_zone_hydration(loop_text, "c")
        zone_d = get_zone_hydration(loop_text, "d")
        zone_e = get_zone_hydration(loop_text, "e")
        zone_f = get_zone_hydration(loop_text, "f")
        zone_g = get_zone_hydration(loop_text, "g")
        zone_h = get_zone_hydration(loop_text, "h")
        zone_i = get_zone_hydration(loop_text, "i")
        zone_by_loop.append((loop_num, zone_a, zone_b, zone_c, zone_d, zone_e, zone_f, zone_g, zone_h, zone_i))

    return water_by_loop, zone_by_loop


def plot_water_with_seaborn(data, output_path):
    """
    Creates a plot of water tank level over agent steps
    :param data: Data that should be plotted
    :param output_path: Where should the plot be stored
    """
    df = pd.DataFrame(data, columns=['Loop', 'Available Water'])

    sns.set(style="whitegrid")
    plt.figure(figsize=(10, 6))
    ax = sns.lineplot(x='Loop', y='Available Water', data=df, marker='o', linewidth=2.5, color='royalblue')

    ax.set_title("Available Water per Loop", fontsize=16)
    ax.set_xlabel("Agent steps", fontsize=12)
    ax.set_ylabel("Available Water", fontsize=12)

    plt.tight_layout()
    plt.savefig(output_path, dpi=300)
    plt.close()


def plot_zone_with_seaborn(data, output_path):
    """
    Creates a plot of every zone moisture level over agent steps
    :param data: Data that should be plotted
    :param output_path: Where should the plot be stored
    """
    columns = ['loop_num', 'zone_a', 'zone_b', 'zone_c', 'zone_d',
               'zone_e', 'zone_f', 'zone_g', 'zone_h', 'zone_i']
    df = pd.DataFrame(data, columns=columns)

    df_melted = df.melt(id_vars='loop_num',
                        value_vars=columns[1:],
                        var_name='zone',
                        value_name='value')

    plt.figure(figsize=(12, 6))
    sns.lineplot(data=df_melted, x='loop_num', y='value', hue='zone', palette='tab10')

    plt.title('Zone Moisture by Agent Steps')
    plt.xlabel('Agent Steps')
    plt.ylabel('Zone Moisture')
    plt.legend(bbox_to_anchor=(0.98, 0.98), loc='upper right', borderaxespad=0)

    plt.subplots_adjust(right=0.75)
    plt.tight_layout()
    plt.savefig(output_path, dpi=300)
    plt.close()


def write_run_result(method_output, i):
    """
    Extract the data from the result file, create plot for water tank level and every zone moisture level
    :param method_output: Output where the plot should be stored
    :param i: Index of the run that should be plotted
    :return:
    """
    os.makedirs(method_output, exist_ok=True)
    dst = os.path.join(method_output, f"run_{i}.out")

    water_data, zone_data = extract_data(dst)
    plot_water_with_seaborn(water_data, os.path.join(method_output, f"run_{i}_plot_water.pdf"))
    plot_zone_with_seaborn(zone_data, os.path.join(method_output, f"run_{i}_plot_zone.pdf"))

    print("Saved plots")


if __name__ == '__main__':
    method_output = f"../examples/garden/mcts-qlearning/experiment2/5-5-5"

    for i in range(1, 6):
        write_run_result(method_output, i)
