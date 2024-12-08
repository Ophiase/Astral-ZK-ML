import pandas as pd
import numpy as np
from constants import NUM_STARS, INTENSITY_RANGE, DATA_FILE_PATH

def generate_star_data(num_stars=NUM_STARS, intensity_range=INTENSITY_RANGE):
    positions = np.random.uniform(0, 2 * np.pi, size=(num_stars, 2))
    intensities = np.random.uniform(*intensity_range, size=num_stars)
    return pd.DataFrame({'x': positions[:, 0], 'y': positions[:, 1], 'intensity': intensities})

def save_star_data(df, filepath=DATA_FILE_PATH):
    df.to_csv(filepath, index=False)

def main():
    df = generate_star_data()
    save_star_data(df)
    print(f"Star data saved to {DATA_FILE_PATH}")

if __name__ == "__main__":
    main()
