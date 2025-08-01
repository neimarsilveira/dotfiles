import re
import time
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

# Matplotlib config
plt.rcParams.update({# 'backend': "agg",
                     'font.family': "sans-serif",
                     'font.sans-serif': "Lato",
                     'font.size': 16,
                     'text.usetex': False
                     })


# Data input
disp_dof = "v"
reac_dof = "ry"

points = [
    (2.5, 100, 100),
    (2.5, 100, 100),
    (2.5, 100, 100),
    (2.5, 100, 100),
    (2.5, 100, 100),
]

disp_files = [
    "results_files/current_1.rst",
    "results_files/current.rst",
]


load_files = [
    "results_files/current_1.extract",
    "results_files/current.extract",
]

experimental_data = ("lower_bound.csv", "upper_bound.csv")

# Plot settings
colors = [
    "indianred",
    "royalblue",
    "seagreen",
    "orchid",
    "gold",
]

labels = [
    r"Current",
    r"Previous",
]

#-------------------------------------------------------------
def read_reaction_from_extract(file_name: str):
    with open(file_name, 'r') as file:
        lines = file.readlines()
        reading_data = False
        step = 0 
        data = []
        for line in lines:
            line = line.strip()
            line_data = re.split(r"[ \(\)]+", line)[1:] # dropping first column (line number)

            if line_data[0] != "Reaction_force":
                if reading_data:
                    data.append([step, *step_reaction_sum])
                reading_data = False
                step_reaction_sum = None
                continue

            if not reading_data:
                reading_data = True
                step += 1
                step_reaction_sum = [0., 0., 0., 0., 0., 0.]

            var_index = int(line_data[1])
            step_reaction_sum[var_index] += float(line_data[2])

        # Using for-else statement to handle EOF  
        # else:
        # append the last step
        if step_reaction_sum:
            data.append([step, *step_reaction_sum])

    return pd.DataFrame(data, columns=['step', 'rx', 'ry', 'rz', 'mx', 'my', 'mz'])


def read_solution_from_rst(file_name: str):
    # open file
    with open(file_name, 'r') as file:
        # read lines as a list
        lines = file.readlines()
        reading_data = False
        data = []
        for line in lines:
            line = line.strip() # dealing with trailing spaces and newline characters

            # skip comments
            if line.startswith("#"):
                continue

            # skip blank lines
            if line == "":
                continue

            # check with the quantity is solution
            if line == "Analysis::extractQuantity: Solution":
                reading_data = True
                continue

            # skip if this is not solution
            if not reading_data:
                continue

            # read solution
            line_data = re.split(",", line)
            # skip header lines
            if line_data[0] == "pointX":
                continue

            # get point as tuple
            point = tuple(float(value) for value in line_data[:3])

            # get solution values
            solution = [float(value) for value in line_data[3:] if value != ""]

            # group point and solution values in a new data entry
            data.append([point, *solution])

    return pd.DataFrame(data, columns=['point','u','v','w'])

def plot_experimental_data(
    ax: plt.Axes,
    lower: pd.DataFrame,
    upper: pd.DataFrame
): 
    # PLOTTING
    ax.plot(lower["disp"]/1000, lower["load"], color="lightgray")
    ax.plot(upper["disp"]/1000, upper["load"], color="lightgray")

    # Drawing experimental data range using `fill_betweenx`
    # to make sure we don't miss any peak or valley
    x_fill = np.unique(np.concatenate([lower["disp"], upper["disp"]]))

    # `np.interp` requires data range to be sorted with respect to the variable, which is `x` in this case
    lower_sorted = lower.sort_values("disp")
    upper_sorted = upper.sort_values("disp")
    y_low_fill = np.interp(x_fill, lower_sorted["disp"], lower_sorted["load"])
    y_high_fill = np.interp(x_fill, upper_sorted["disp"], upper_sorted["load"])

    ax.fill_between(x_fill, y_low_fill, y_high_fill, label="Experiment", color="gray", alpha=0.4)
    return ax

def format_axis(ax):
    # Plot limits
    ax.set_xlim(0.0, 0.250)
    ax.set_ylim(0.0, 60.0)
    # Grid
    ax.minorticks_on()
    ax.grid(visible=True, which="major", linewidth=1.0)
    ax.grid(visible=True, which="minor", linestyle='--', linewidth=0.50)
    # Text and axes
    ax.legend()
    # ax.legend(bbox_to_anchor=(0.95, 0.95))
    ax.set_xlabel("CMSD (mm)")
    ax.set_ylabel("Reaction (kN)")
    ax.spines['right'].set_color('none')
    ax.spines['top'].set_color('none')
    return ax


if __name__ == "__main__":
    fig = plt.figure(figsize=(10,7))
    ax = fig.subplots(nrows=1, ncols=1)
    if experimental_data:
        lower = pd.read_csv(experimental_data[0])
        upper = pd.read_csv(experimental_data[1])
        lower["disp"] /= 1000
        upper["disp"] /= 1000
        plot_experimental_data(ax, lower, upper)
        
    for point, disp_file, load_file, label, color in zip(points, disp_files, load_files, labels, colors):
        disp_df = read_solution_from_rst(disp_file)
        disp_serie_right = disp_df[disp_df["point"] == point][disp_dof]
        disp_serie_left = disp_df[disp_df["point"] == (-2.5, 100.0, 100.0)][disp_dof]
        disp_serie = np.abs(disp_serie_right.reset_index(drop=True) - disp_serie_left.reset_index(drop=True))
        reac_serie = read_reaction_from_extract(load_file)[reac_dof] / 1000 # from N to kN

        print(reac_serie.max())
        ax.plot(disp_serie, reac_serie, color=color, label=label)

    format_axis(ax)
    fig.tight_layout()
    plt.show()
    # fig.savefig("plot_load_disp.pdf", bbox_inches='tight')
    # fig.savefig("L_shape_load_disp_approx_order.png", dpi=300, bbox_inches='tight')
