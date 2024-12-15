# Constellation Identification

🏗️ **Work In Progress**

This project simulates star constellations and uses a Graph Attention Network (GAT) to predict the rotational angles (u, v) of a robot's head from a graph of the captured image.

## Objectives
- **Simulate star dataset**:
    - [x] Simulate stars
    - [x] Convert stars into graph representations (stars as nodes, distances as edges)
    - [ ] Convert stars into image samples
    - [ ] Convert images into graph representations (stars as nodes, distances as edges)
- **Implement GAT model**:
    - [ ] Predict the true position of stars and/or the camera angle (\(u\), \(v\)).
    - Should we predict star positions and deduce the camera angle, or predict the camera angle directly?

## Execution

```bash
make dummy_data # simulate dummy data (naive)
make clean # clean

# not implemented yet
make simulate_data # simulate stars positions => images of stars => graph of stars => prediction
make train # train the GAT
```