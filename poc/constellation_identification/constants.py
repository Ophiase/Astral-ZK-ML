import numpy as np
import math
import os

NUM_STARS = 1000
NUM_SAMPLES = 100

INTENSITY_RANGE = (0.1, 1)

STAR_DATA_FILE = os.path.join("data", "stars.csv")
TRAINING_GRAPHS_DIR = os.path.join("data", "sample")

FOV_U = math.radians(30.0)  # Field of view width in degrees
FOV_V = math.radians(15.0)  # Field of view height in degrees
MAX_ANGLE = np.pi