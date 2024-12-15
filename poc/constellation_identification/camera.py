from turtle import pd
from typing import Tuple
import numpy as np
import pandas as pd
from constants import ANGLE_RANGE

def generate_camera_angles(num_angles=1):
    return np.random.uniform((0, 2*np.pi), size=(num_angles, 2))

def transform_positions(positions, angles):
    u, v = angles
    rotation_matrix = np.array([[np.cos(u), -np.sin(u)], [np.sin(u), np.cos(u)]])
    return np.dot(positions, rotation_matrix.T)

def main():
    angles = generate_camera_angles(3)
    print(f"Generated camera angles: {angles}")

if __name__ == "__main__":
    main()
