FROM rocker/r-ver:4.4.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install remotes for versioned R packages
RUN R -e "install.packages('remotes', repos = 'http://cran.r-project.org')"

# Install required R packages with specific versions
RUN R -e "remotes::install_version('caret', version = '7.0-1', repos = 'http://cran.r-project.org')" \
    && R -e "remotes::install_version('kernlab', version = '0.9-33', repos = 'http://cran.r-project.org')" \
    && R -e "remotes::install_version('xgboost', version = '1.7.8.1', repos = 'http://cran.r-project.org')" \
    && R -e "remotes::install_version('randomForest', version = '4.7-1.2', repos = 'http://cran.r-project.org')" \
    && R -e "remotes::install_version('gbm', version = '2.2.2', repos = 'http://cran.r-project.org')" \
    && R -e "remotes::install_version('naivebayes', version = '1.0.0', repos = 'http://cran.r-project.org')"

# Set working directory inside container
WORKDIR /PCPred

# Copy prediction script and models
COPY prediction_pc_docker.R models.RData ./

WORKDIR /WorkPlace

# Entry point: run your prediction script
ENTRYPOINT ["Rscript", "/PCPred/prediction_pc_docker.R"]

