import numpy as np
import pandas as pd
from typing import Tuple, List

from constants import INTENSITY_RANGE, MAX_ANGLE, STAR_DATA_FILE, NUM_STARS

def generate_star_dataset(
        num_stars: int = NUM_STARS, 
        output_file: str = STAR_DATA_FILE
        ) -> None:
    """
    Generate a CSV file with star positions and intensities.

    :param num_stars: Number of stars to generate
    :param output_file: Path to save the CSV file
    """
    positions_u = np.random.uniform(-MAX_ANGLE, MAX_ANGLE, num_stars)
    positions_v = np.random.uniform(-MAX_ANGLE, MAX_ANGLE, num_stars)
    intensities = np.random.uniform(INTENSITY_RANGE[0], INTENSITY_RANGE[1], num_stars)

    data = pd.DataFrame({
        'u': positions_u,
        'v': positions_v,
        'intensity': intensities
    })

    data.to_csv(output_file, index=False)

def main():
    generate_star_dataset()

if __name__ == "__main__" :
    main()