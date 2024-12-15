import os
import numpy as np
import pandas as pd
from typing import Tuple, List

from constants import FOV_U, FOV_V, MAX_ANGLE, NUM_SAMPLES, STAR_DATA_FILE, TRAINING_GRAPHS_DIR

def sample_visible_stars(star_data: pd.DataFrame, fov_u: float, fov_v: float) -> Tuple[np.ndarray, np.ndarray]:
    """
    Sample stars visible within a random camera field of view (FOV).

    :param star_data: DataFrame with star positions and intensities
    :param fov_u: Field of view in the u direction (angular width)
    :param fov_v: Field of view in the v direction (angular height)
    :return: Tuple containing visible star data and the camera center (u, v)
    """
    center_u = np.random.uniform(-MAX_ANGLE + fov_u / 2, MAX_ANGLE - fov_u / 2)
    center_v = np.random.uniform(-MAX_ANGLE + fov_v / 2, MAX_ANGLE - fov_v / 2)

    mask = (
        (star_data['u'] >= center_u - fov_u / 2) &
        (star_data['u'] <= center_u + fov_u / 2) &
        (star_data['v'] >= center_v - fov_v / 2) &
        (star_data['v'] <= center_v + fov_v / 2)
    )

    visible_stars = star_data[mask]

    return visible_stars.to_numpy(), np.array([center_u, center_v])

def compute_angular_distances(positions: np.ndarray) -> np.ndarray:
    """
    Compute the angular distances between all pairs of positions.

    :param positions: Array of star positions (u, v)
    :return: Adjacency matrix of angular distances
    """
    num_stars = positions.shape[0]
    distances = np.zeros((num_stars, num_stars))

    for i in range(num_stars):
        for j in range(num_stars):
            if i != j:
                distances[i, j] = np.sqrt((positions[i, 0] - positions[j, 0])**2 +
                                          (positions[i, 1] - positions[j, 1])**2)
    return distances

def save_graph_sample(graph_sample: dict, sample_id: int, output_dir: str) -> None:
    os.makedirs(output_dir, exist_ok=True)
    np.savez(
        os.path.join(output_dir, f"sample_{sample_id}.npz"),
        distances=graph_sample['distances'],
        intensities=graph_sample['intensities'],
        camera_center=graph_sample['camera_center']
    )

def generate_training_graphs_per_file(
    star_data_file: str,
    fov_u: float,
    fov_v: float,
    num_samples: int,
    output_dir: str,
    k_neighbors: int = None
) -> None:
    star_data = pd.read_csv(star_data_file)

    for i in range(num_samples):
        visible_stars, camera_center = sample_visible_stars(star_data, fov_u, fov_v)
        positions = visible_stars[:, :2]
        intensities = visible_stars[:, 2]

        distances = compute_angular_distances(positions)

        if k_neighbors:
            distances = keep_k_closest(distances, k_neighbors)

        save_graph_sample(
            {
                'distances': distances,
                'intensities': intensities,
                'camera_center': camera_center
            },
            sample_id=i,
            output_dir=output_dir
        )

def keep_k_closest(distances: np.ndarray, k: int) -> np.ndarray:
    num_stars = distances.shape[0]
    for i in range(num_stars):
        row = distances[i, :]
        closest_indices = np.argsort(row)[:k + 1]
        mask = np.ones_like(row, dtype=bool)
        mask[closest_indices] = False
        row[mask] = 0.0
    return distances

def main():
    generate_training_graphs_per_file(STAR_DATA_FILE, FOV_U, FOV_V, NUM_SAMPLES, TRAINING_GRAPHS_DIR)

if __name__ == "__main__" :
    main()