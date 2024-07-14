import os
import json
import numpy as np
import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder, LabelEncoder, StandardScaler
from keras.utils import to_categorical

import matplotlib.pyplot as plt

from common import globalState

SAMPLE_SIZE = 5
DATASET_PATH = os.path.join("..", "data", "star_classification.csv")

def import_data():
    df = pd.read_csv(DATASET_PATH)

    X = df.drop(columns=["class"])
    scaler = StandardScaler()
    X_normalized = pd.DataFrame(scaler.fit_transform(X), columns=X.columns)
    X_normalized = X_normalized.astype(float)
    X = X_normalized.to_numpy()

    Y = df["class"]
    Y = np.array(LabelEncoder().fit_transform(y=Y.values))
    Y = np.array(OneHotEncoder().fit_transform(Y.reshape(-1, 1)).toarray()).astype(float)

    train_X, test_X, train_Y, test_Y = train_test_split(X, Y, test_size=0.2, random_state=42)

    globalState.train_X = np.array(train_X)
    globalState.train_Y = np.array(train_Y)
    globalState.test_X = np.array(test_X)
    globalState.test_Y = np.array(test_Y)

def sample() -> np.array:
    indices = np.random.permutation(1000)
    selected_indices = indices[:SAMPLE_SIZE]
    X = globalState.train_X[selected_indices]
    Y = globalState.train_Y[selected_indices]

    return X, Y
    # print(matrix_to_wfloat(sample))
    # print("--------------------")
    # print(matrix_to_wfloat(model.forward(sample)))