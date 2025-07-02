# PCPred

- **PCPred** is ML based classification model to predict given sample is pancreatic cancer or normal. 
- This repository provides a Docker-based machine learning pipeline to classify whether a given gene expression sample corresponds to pancreatic cancer or a normal condition. It includes trained models and an R script to make reproducible predictions in any environment using Docker.

## Repository Contents

The files contained in this repository are as follows:

- `Dockerfile` : Docker environment specification  
- `prediction_pc_docker.R` : R script that loads pre-trained models and performs predictions  
- `models.RData` : Pre-trained machine learning models (SVM, kNN, RF, SGB, XGB, NB)  
- `sample_data.csv` : Sample input file for demonstration  
- `Data/TrainData.rds` : Training dataset used to develop the models  
- `Training_data` : Folder containing scripts and data used for model training and testing 

## Prerequisites

- Install [Docker](https://www.docker.com/) on your system.
- Input Data
	- Input data must follow the specified format  
    - A reference input file (`sample_data.csv`) is provided

## Input Data Format

The input should be a `.csv` file with **log2-normalized gene expression values** in the following exact order:
CEACAM5, CEACAM6,	CTSE,	GALNT5,	LAMB3,	LAMC2,	SLC6A14,	TMPRSS4,	TSPAN1,	ITGA2,	ITGB6,	POSTN,	IAPP
> **_NOTE:_** Refer to `sample_data.csv`


## Usage

Users have two options to use this tool:

- **Use Prebuilt Docker Image** (via GitHub Container Registry)  
- **Build Docker Image Locally** (from this repository)


### Option 1: Use Prebuilt Image
```bash
docker run --rm -v "${PWD}:/WorkPlace" ghcr.io/tanmay3371/pcpred:latest sample_data.csv
```
Replace sample_data.csv with your input file

### ***OR***

### Option 2: Build Image Locally
### 1. Clone the Repository
```bash
git clone https://github.com/PGlab-NIPER/PCPred.git
cd PCPred
```
### 2. Build the Docker Image
```bash
docker build -t pcpred .
```
### 3. Run the Prediction
#### On Linux/Windows/macOS terminal
```bash
docker run --rm -v "${PWD}:/WorkPlace" pcpred sample_data.csv

```
> **_NOTE:_**  Replace sample_data.csv with the path to your actual .csv file.

## Prediction Results
After execution, a file named ``pancreatic_cancer_prediction.csv`` will be saved in the same directory as your input file. It includes:
* Predictions from each individual model (SVM, kNN, RF, SGB, XGB, NB)
* A majority vote result representing the final prediction


## R Environment Inside Docker
The Docker container uses the following R configuration:
* R Version: 4.4.2
* caret: 7.0-1
* kernlab: 0.9-33
* class: 7.3-22
* xgboost: 1.7.8.1
* randomForest: 4.7-1.2
* gbm: 2.2.2
* naivebayes: 1.0.0

## GEO dataset 
The model was trained on log2-normalized gene expression data, compiled from the following publicly available GEO datasets:
* [GSE28735](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE28735)
* [GSE62452](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE62452)
* [GSE183795](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE183795)
The processed and combined dataset used for model training is available in ``Data/TrainData.rds``.

## Citation
If you use  **PCPred** in your publication, consider citing the [paper]([https://pubmed.ncbi.nlm.nih.gov/40522604/]):
```
Kamble, P., Varma, T., Kumar, R. et al. Computational theranostics strategy for pancreatic ductal adenocarcinoma. Mol Divers (2025). https://doi.org/10.1007/s11030-025-11241-3
```
