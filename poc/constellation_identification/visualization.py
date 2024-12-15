import os
import numpy as np
import matplotlib.pyplot as plt
import torch
import torch.nn as nn
import torch.optim as optim
from torch_geometric.loader import DataLoader

from constants import TRAINING_GRAPHS_DIR

def load_sample(sample_id: int, data_dir: str):
    """
    Load a graph sample (X and Y) from the specified directory.

    :param sample_id: ID of the sample to load
    :param data_dir: Directory containing the sample files
    :return: Tuple with X (graph data) and Y (ground truth)
    """
    x_file = os.path.join(data_dir, f"sample_{sample_id}_x.npz")
    y_file = os.path.join(data_dir, f"sample_{sample_id}_y.npz")

    x_data = np.load(x_file)
    y_data = np.load(y_file)

    return x_data, y_data

def visualize_sample(sample_id: int, data_dir: str):
    """
    Visualize the graph sample by plotting nodes and their connections.

    :param sample_id: ID of the sample to visualize
    :param data_dir: Directory containing the sample files
    """
    x_data, y_data = load_sample(sample_id, data_dir)

    distances = x_data['distances']
    relative_positions = x_data['relative_positions']
    intensities = x_data['intensities']
    true_positions = y_data['true_positions']
    camera_center = y_data['camera_center']

    plt.figure(figsize=(10, 8))

    # Plot nodes
    for i, (pos, intensity) in enumerate(zip(relative_positions, intensities)):
        plt.scatter(pos[0], pos[1], s=intensity * 50, label=f"Node {i}" if i < 10 else "")

    # Plot edges based on distances
    num_nodes = distances.shape[0]
    for i in range(num_nodes):
        for j in range(num_nodes):
            if distances[i, j] > 0:
                plt.plot(
                    [relative_positions[i, 0], relative_positions[j, 0]],
                    [relative_positions[i, 1], relative_positions[j, 1]],
                    color="gray", linestyle="--", linewidth=0.5
                )

    # Annotate true positions
    for pos in true_positions:
        plt.scatter(pos[0], pos[1], color="red", marker="x", label="True Position" if 'True Position' not in plt.gca().get_legend_handles_labels()[1] else "")

    # Plot camera center
    plt.scatter(camera_center[0], camera_center[1], color="blue", marker="o", label="Camera Center")

    plt.title(f"Graph Visualization for Sample {sample_id}")
    plt.xlabel("Relative Position U")
    plt.ylabel("Relative Position V")
    plt.legend()
    plt.grid(True)
    plt.show()

def visualize_predictions(model: nn.Module, dataloader: DataLoader, device: torch.device, sample_idx: int = 0, verbose: bool=True) -> None:
    model.eval()
    with torch.no_grad():
        data = next(iter(dataloader)).to(device)
        data = data[sample_idx]
       
        if verbose:
            print("DATA:")
            print(data)

        true_positions = data.y.cpu().numpy()
        predicted_positions = model(data).cpu().numpy()
        if verbose:
            print("TRUTH:")
            print(true_positions)
            print("PREDICTED:")
            print(predicted_positions)

        plt.figure(figsize=(6, 6))
        plt.scatter(true_positions[:, 0], true_positions[:, 1], color='red', marker='x', label='True Position')
        plt.scatter(predicted_positions[:, 0], predicted_positions[:, 1], color='blue', marker='o', label='Predicted Position')
        plt.title(f"True vs Predicted Star Positions (Sample 0)")
        plt.xlabel("Position U")
        plt.ylabel("Position V")
        plt.legend()
        plt.grid(True)
        plt.show()

def main():
    visualize_sample(2, TRAINING_GRAPHS_DIR)

if __name__ == "__main__":
    main()