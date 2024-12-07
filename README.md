# Astral-ZK-ML

<p align="center"><img src="resources/logo.png" width=400></p>

Sponsorized by [ETH Global - Brussels](https://ethglobal.com/events/brussels). \
Prize : **Nethermind** - Best zkML project

Decentralized Machine Learning Protocol adapted to both terrestrial and spatial context. \
The models and the two smartcontracts utilizing them are written in the ZK-Proovable language Cairo. \
In the future, the smart contracts will be deployed on specific L3 for each planets/asteroids using Madara.

## Introduction

- ✅ **ZK-ML tools** : Built in Cairo for contracts on starknet-compatible blockchain
	- ✅ Implemented on blockchain
		- Basic Algebra + Linear Algebra
			- Principal types: Signed Integer, Float (WFloat), Vector, Matrix
			- Numerous High level operations to manipulate those types.
			- Uniform pseudo random generator (to initialize weights)
				- TODO: add more distributions (normal, poisson, $\dots$)
		- Multi Layer Perceptron (ie. regular Neural Network)
			- eg: Star type identification
	- ❌ Additional Proof of Concept
		- Crater identification (Computer Vision)
		- Constellation identification (Computer Vision)
	- ❌ Not implemented in cairo yet
		- Convolutional Neural Network
			- for Crater identification
		- Graph Attention Network
			- for Constellation identification
- **Decentralized Smart Contracts** : Variants of the smart contract :
	- ❌ **Fully Decentralized** (not implemented yet)
		- <p align="center"><img src="./resources/schema_fully_decentralized.png" width=700></p>
		- Based on financial incentive (ie. egoistic incentive)
		- Terestrial variant adapted to Starknet L2.
	- ❌ **Country Wise Decentralized** (not implemented yet)
		- <p align="center"><img src="./resources/schema_country_wise_decentralized.png" width=8700></p>
		- Assumed resistance to Byzantine fault
		- Spacial variant adapted to a specific L3 for a planet/satellite owned by multiples countries.
- **Demonstration Client**
    - ❌ Not implemented yet

## Documentation

- ### [On Chain content](contract/README.md) 
    - ZK-ML tools 
    - Fully Decentralized contract
    - Country Wise Decentralized contract
- ### [Mathematical/Implementation details](documentation/README.md)
    - Mathematical model/assumptions
    - Algorithms
    - Misc
- ### [Demonstration Client](client/README.md)
- ### Proof Of Concept
	- [Crater Identification](poc/crater_identification/README.md)
	- [Constellation Identification](poc/constellation_identification/README.md)
