import os
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch_geometric.nn import GATConv
from torch_geometric.data import Data
from torch_geometric.loader import DataLoader
import matplotlib.pyplot as plt

from constants import MODEL_PATH, TRAINING_GRAPHS_DIR, NUM_SAMPLES
from visualization import visualize_predictions

class StarDataset(torch.utils.data.Dataset):
    def __init__(self, data_dir):
        self.data_dir = data_dir
        self.samples = [
            int(file.split('_')[1])
            for file in os.listdir(data_dir)
            if file.endswith("_x.npz")
        ]

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        sample_id = self.samples[idx]
        x_path = os.path.join(self.data_dir, f"sample_{sample_id}_x.npz")
        y_path = os.path.join(self.data_dir, f"sample_{sample_id}_y.npz")

        x_data = np.load(x_path)
        y_data = np.load(y_path)

        distances = torch.tensor(x_data['distances'], dtype=torch.float32)
        intensities = torch.tensor(x_data['intensities'], dtype=torch.float32).unsqueeze(1)
        positions = torch.tensor(x_data['relative_positions'], dtype=torch.float32)

        true_positions = torch.tensor(y_data['true_positions'], dtype=torch.float32)
        camera_center = torch.tensor(y_data['camera_center'], dtype=torch.float32)

        edge_index = (distances > 0).nonzero(as_tuple=False).T
        edge_attr = distances[distances > 0].view(-1, 1)

        x = torch.cat([positions, intensities], dim=1)

        return Data(x=x, edge_index=edge_index, edge_attr=edge_attr, y=true_positions, camera_center=camera_center)

def create_dataloader(data_dir, batch_size):
    dataset = StarDataset(data_dir)
    return DataLoader(dataset, batch_size=batch_size, shuffle=True)

class GATModel(nn.Module):
    def __init__(self, input_dim, hidden_dim, output_dim):
        super(GATModel, self).__init__()
        self.gat1 = GATConv(input_dim, hidden_dim, heads=4, concat=True)
        self.gat2 = GATConv(hidden_dim * 4, hidden_dim, heads=4, concat=True)
        self.fc = nn.Linear(hidden_dim * 4, output_dim)

    def forward(self, data):
        x, edge_index, edge_attr = data.x, data.edge_index, data.edge_attr
        x = self.gat1(x, edge_index, edge_attr)
        x = torch.relu(x)
        x = self.gat2(x, edge_index, edge_attr)
        x = torch.relu(x)
        out = self.fc(x)
        return out

def train_model(model, dataloader, epochs, lr, device):
    optimizer = optim.Adam(model.parameters(), lr=lr)
    criterion = nn.MSELoss()

    for epoch in range(epochs):
        model.train()
        epoch_loss = 0

        for data in dataloader:
            data = data.to(device)
            optimizer.zero_grad()
            outputs = model(data)
            loss = criterion(outputs, data.y)
            loss.backward()
            optimizer.step()
            epoch_loss += loss.item()

        print(f"Epoch {epoch + 1}/{epochs}, Loss: {epoch_loss / len(dataloader):.4f}")

def save_model(model: nn.Module, path: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    torch.save(model.state_dict(), path)

def load_model(model: nn.Module, path: str) -> None:
    if os.path.exists(path):
        model.load_state_dict(torch.load(path))
        print(f"Model loaded from {path}")
    else:
        print(f"No model found at {path}")


def main() -> None:
    data_dir = TRAINING_GRAPHS_DIR
    batch_size = 10
    epochs = 30
    lr = 0.001
    input_dim = 3
    hidden_dim = 64
    output_dim = 2
    device = torch.device('cpu')

    dataloader = create_dataloader(data_dir, batch_size)

    model = GATModel(input_dim, hidden_dim, output_dim)
    
    load_model(model, MODEL_PATH)
    
    if not os.path.exists(MODEL_PATH):
        train_model(model, dataloader, epochs, lr, device)
        save_model(model, MODEL_PATH)

    visualize_predictions(model, dataloader, device)

if __name__ == "__main__":
    main()


