# PCPred

**PCPred** is ML based classification model to predict given sample is pancreatic cancer or normal.
This repository provides a Docker-based machine learning pipeline to classify whether a given gene expression sample corresponds to pancreatic cancer or a normal condition. It includes trained models and an R script to make reproducible predictions in any environment using Docker.

## Contents

The files contained in this repository are as follows:

- `Dockerfile` : Docker environment specification  
- `prediction_pc_docker.R` : R script to load models and make predictions  
- `models.RData` : Pre-trained machine learning models (SVM, kNN, RF, SGB, XGB, NB)  
- `sample_data.csv` : Sample gene expression input file  
- `Data/TrainData.rds` : Original training dataset used to develop the models  

## Prerequisites

- Install [Docker](https://www.docker.com/) on your system.
- R is not needed on your local machine — it's inside the container.

## Input Data Format

The input should be a `.csv` file with **log2-normalized gene expression values** in the following exact order:
CEACAM5, CEACAM6,	CTSE,	GALNT5,	LAMB3,	LAMC2,	SLC6A14,	TMPRSS4,	TSPAN1,	ITGA2,	ITGB6,	POSTN,	IAPP
> **_NOTE:_** Refer to `sample_data.csv`

## Usage

### 1. Clone the Repository
```bash
git clone https://github.com/PGlab-NIPER/PCPred.git
cd PCPred
```
### 2. Build the Docker Image
```bash
docker build -t PCPred .
```
### 3. Run the Prediction
#### On Linux/Windows/macOS terminal
```bash
docker run --rm -v "${PWD}:/app" PCPred sample_data.csv
```
> **_NOTE:_**  Replace your_input.csv with the path to your actual .csv file.

### 4. Prediction Results
The output file pancreatic_cancer_prediction.csv will be generated in the same directory as your input. It includes:
* Predictions from each model
* A majority vote results from all the models


## R Environment Inside Docker
The container uses the following R setup:
* R Version: 4.4.2
* caret: 7.0-1
* kernlab: 0.9-33
* xgboost: 1.7.8.1
* randomForest: 4.7-1.2
* gbm: 2.2.2
* naivebayes: 1.0.0

## GEO dataset 
The file Data/TrainData.rds contains the dataset used to train the included models. It was compiled using log2-normalized microarray gene expression values from the following public GEO datasets:
* GSE28735 https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE28735
* GSE62452 https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE62452
* GSE183795 https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE183795

## Citation
If you use  **PCPred** in your publication, consider citing the [paper]([https://pubmed.ncbi.nlm.nih.gov/.../]):
```
@ARTICLE{,
AUTHOR={Pradnya Kamble, Tanmaykumar Varma, Rajender Kumar, and Prabha Garg},   
TITLE={Computational Theranostics Strategy for Pancreatic Ductal Adenocarcinoma},      
JOURNAL={..,},      
VOLUME={},           
YEAR={2025},     
URL={https://pubmed.ncbi.nlm.nih.gov/...},       
DOI={...},      	
ISSN={}
}
```


