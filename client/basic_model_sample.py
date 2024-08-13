import numpy as np
from sklearn.datasets import load_iris
from sklearn.preprocessing import OneHotEncoder
from sklearn.model_selection import train_test_split
from tensorflow.keras.datasets import mnist
from typing import List, Tuple, Union

from matplotlib import pyplot as plt
from basic_conversions import matrix_as_felt_string, vector_as_felt_string

# ----------------------------------------------------------------------------------------------------------------

class ILayer:
    def build(self, input_shape: int) -> None:
        raise NotImplementedError("Must implement build method")
    
    def forward(self, X: np.ndarray) -> np.ndarray:
        raise NotImplementedError("Must implement forward method")
    
    def backward(self, dY: np.ndarray, learning_rate: float) -> np.ndarray:
        raise NotImplementedError("Must implement backward method")
    
    def num_params(self) -> int: return 0

    def serialize(self) -> str: return ""

# ----------------------------------------------------------------------------------------------------------------

class DenseLayer(ILayer):
    def __init__(self, input_shape: int = None, output_shape: int = None, activation: str = None) -> None:
        self.input_shape = input_shape
        self.output_shape = output_shape
        self.activation_name = activation
        self.activation = None
        self.activation_derivative = None

    def build(self, input_shape: int = None) -> None:
        if input_shape:
            self.input_shape = input_shape
        self.W = np.random.randn(self.input_shape, self.output_shape) * 0.01
        self.b = np.zeros((1, self.output_shape))
        if self.activation_name == "Sigmoid":
            self.activation = lambda x: 1 / (1 + np.exp(-x))
            self.activation_derivative = lambda x: self.activation(x) * (1 - self.activation(x))
        elif self.activation_name == "ReLU":
            self.activation = lambda x: np.maximum(0, x)
            self.activation_derivative = lambda x: (x > 0).astype(float)
        elif self.activation_name == "Softmax":
            self.activation = lambda x: np.exp(x) / np.sum(np.exp(x), axis=1, keepdims=True)
            self.activation_derivative = lambda x: 1 # Not Implemented
        else:
            raise ValueError("Unsupported activation function")

    def forward(self, X: np.ndarray) -> np.ndarray:
        self.input = X
        self.z = np.dot(X, self.W) + self.b
        self.output = self.activation(self.z)
        
        return self.output

    def backward(self, dY: np.ndarray, learning_rate: float) -> np.ndarray:
        m = dY.shape[0]
        dZ = dY * self.activation_derivative(self.z)
        dW = np.dot(self.input.T, dZ) / m
        dB = np.sum(dZ, axis=0, keepdims=True) / m
        dX = np.dot(dZ, self.W.T)
        
        self.W -= learning_rate * dW
        self.b -= learning_rate * dB
        
        return dX

    def num_params(self) -> int:
        return np.prod(self.W.shape) + np.prod(self.b.shape)
    
    # we force ReLU activation for simplicity
    # TODO: not force it
    def serialize(self) -> str :
        weights = matrix_as_felt_string(self.W)
        biaises = vector_as_felt_string(self.b[0])
        activation = 0
        return f"{weights}, {biaises}, {activation}"

class Sequential:
    def __init__(self, layers: List[ILayer], optimizer: 'SGD') -> None:
        self.layers = layers
        self.optimizer = optimizer

    def build(self) -> None:
        input_shape = self.layers[0].input_shape
        for layer in self.layers:
            layer.build(input_shape)
            input_shape = layer.output_shape

    def forward(self, X: np.ndarray) -> np.ndarray:
        for layer in self.layers:
            X = layer.forward(X)
        return X

    def backward(self, dY: np.ndarray) -> None:
        for layer in reversed(self.layers):
            dY = layer.backward(dY, self.optimizer.learning_rate)

    def train(
            self, X: np.ndarray, y: np.ndarray, epochs: int, 
            batch_size: int, verbose: bool = False) -> List[float]:
        
        self.loss_history = []
        for epoch in range(epochs):
            permutation = np.random.permutation(X.shape[0])
            X_shuffled = X[permutation]
            y_shuffled = y[permutation]

            for i in range(0, X.shape[0], batch_size):
                X_batch = X_shuffled[i:i + batch_size]
                y_batch = y_shuffled[i:i + batch_size]
                output = self.forward(X_batch)
                loss = self.mse_loss(output, y_batch)
                dY = output - y_batch
                self.backward(dY)

            predictions = self.forward(X)
            loss = self.mse_loss(predictions, y)
            self.loss_history.append(loss)

            if verbose and epoch % 10 == 0:
                print(f'Epoch {epoch+1}, Loss: {loss}')

        return self.loss_history

    def mse_loss(self, predictions: np.ndarray, targets: np.ndarray) -> float:
        return np.mean(np.square(predictions - targets))

    def num_params(self) -> int:
        return sum(layer.num_params() for layer in self.layers)
    
    def serialize(self) -> str:
        result = f"{len(self.layers)}, "
        for layer in self.layers:
            result += f"{layer.serialize()}, "
        return result[:-2]

class SGD:
    def __init__(self, learning_rate : float) -> None:
        self.learning_rate = learning_rate

# ----------------------------------------------------------------------------------------------------------------

def build_model(train_X, train_Y):
    layers = [
        DenseLayer(input_shape=train_X.shape[1], output_shape=5, activation="ReLU"), 
        DenseLayer(output_shape=5, activation="ReLU"), 
        DenseLayer(output_shape=train_Y.shape[1], activation="ReLU"), 
    ]

    model = Sequential(layers, SGD(learning_rate=0.01))
    model.build()
    model.train(train_X, train_Y, epochs=30, batch_size=1000, verbose=True)
    
    return model