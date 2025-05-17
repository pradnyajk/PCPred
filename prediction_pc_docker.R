# Required Libraries
library(caret)     # version 7.0-1

# Load trained models
load("models.RData")

# Accept input CSV file as an argument
args <- commandArgs(trailingOnly = TRUE)

# Stop if no file is provided
if (length(args) == 0) {
  stop("Error: Please provide a CSV file as an argument. Example: docker run ... your_file.csv")
}

input_file <- args[1]

# Read the test data
TestData <- read.csv(input_file)

# Ensure column names match those of training data
colnames(TestData) <- colnames(TrainData[, 1:13])

# Generate predictions from all models
pred_svm_radial_test_10_fold <- predict(svm_radial_10_fold, newdata = TestData[, 1:13])
knn_pred_test_10fold <- predict(knn_10_fold, newdata = TestData[, 1:13])
rf_pred_test_10fold <- predict(rf_10_fold, newdata = TestData[, 1:13])
sgb_pred_test_10fold <- predict(sgb_10_fold, newdata = TestData[, 1:13])
xgb_pred_test_10fold <- predict(xgb_10_fold, newdata = TestData[, 1:13])
nb_pred_test_10fold <- predict(nb_10_fold, newdata = TestData[, 1:13])

# Convert predictions to character
pred_svm_radial_test_10_fold <- as.character(pred_svm_radial_test_10_fold)
knn_pred_test_10fold <- as.character(knn_pred_test_10fold)
rf_pred_test_10fold <- as.character(rf_pred_test_10fold)
sgb_pred_test_10fold <- as.character(sgb_pred_test_10fold)
xgb_pred_test_10fold <- as.character(xgb_pred_test_10fold)
nb_pred_test_10fold <- as.character(nb_pred_test_10fold)

# Combine predictions into a data frame
probs <- cbind.data.frame(
  pred_svm_radial_test_10_fold,
  knn_pred_test_10fold,
  rf_pred_test_10fold,
  sgb_pred_test_10fold,
  xgb_pred_test_10fold,
  nb_pred_test_10fold
)

# Majority vote function
get_majority_vote <- function(row) {
  counts <- table(row)
  majority_label <- names(counts)[which.max(counts)]
  return(majority_label)
}

# Apply majority vote
probs$majority_vote <- apply(probs, 1, get_majority_vote)
final_prediction <- probs$majority_vote

# Print results
cat("-----------------------------------------------------------------------------------------------------\n")
cat("Predicted outcome for provided sample(s):\n")
print(final_prediction)
cat("\nPlease see the file 'pancreatic_cancer_prediction.csv' generated in the working directory.\n")
cat("-----------------------------------------------------------------------------------------------------\n")

# Prepare result
result <- cbind.data.frame(
  Sample = rownames(TestData),
  SVM = pred_svm_radial_test_10_fold,
  kNN = knn_pred_test_10fold,
  RF = rf_pred_test_10fold,
  SGB = sgb_pred_test_10fold,
  XGB = xgb_pred_test_10fold,
  NB = nb_pred_test_10fold,
  Majority_Vote_from_5_models = final_prediction
)

# Save result to CSV
write.csv(result, file = "pancreatic_cancer_prediction.csv", row.names = FALSE)
