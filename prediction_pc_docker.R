# Required Libraries
library(caret)     # version 7.0-1

# Load trained models
load("/PCPred/models.RData")

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
pred_svm_radialtest1 <- predict(svm_radial1, newdata = TestData[,1:13] )
knn_pred_test_class_optk <- knn(train = TrainData[,1:13],test= TestData[,1:13],
                                cl = TrainData$Type, k = 7)

pred_rf_tune_te <- predict(fit_rf, TestData[,1:13])
pred_gbm_model_test <- predict(gbm_model , TestData[,1:13])

pred_xg_boost_test <- predict(xg_boost, TestData[,1:13])
pred_nb_model_test <- predict(nb_model, TestData)


# Convert predictions to character
pred_svm_radialtest1 <- as.character(pred_svm_radialtest1)
knn_pred_test_class_optk <- as.character(knn_pred_test_class_optk)
pred_rf_tune_te <- as.character(pred_rf_tune_te)
pred_gbm_model_test <- as.character(pred_gbm_model_test)
pred_xg_boost_test <- as.character(pred_xg_boost_test)
pred_nb_model_test <- as.character(pred_nb_model_test)


# Combine predictions into a data frame
probs <- cbind.data.frame(
  pred_svm_radialtest1,
  knn_pred_test_class_optk,
  pred_rf_tune_te,
  pred_gbm_model_test,
  pred_xg_boost_test,
  pred_nb_model_test
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
cat("-----------------------------------------------------------------------------------------------------\n\n")
cat("Predicted outcome for provided sample(s):\n\n")
print(final_prediction)
cat("\nPlease see the file 'pancreatic_cancer_prediction.csv' generated in the working directory.\n\n")
cat("-----------------------------------------------------------------------------------------------------\n\n")


# Prepare result
result <- cbind.data.frame(
  Sample = rownames(TestData),
  SVM = pred_svm_radialtest1,
  kNN = knn_pred_test_class_optk,
  RF = pred_rf_tune_te,
  SGB = pred_gbm_model_test,
  XGB = pred_xg_boost_test,
  NB = pred_nb_model_test,
  Majority_Vote_from_5_models = final_prediction
)

# Save result to CSV
write.csv(result, file = "/WorkPlace/pancreatic_cancer_prediction.csv", row.names = FALSE)

#V2



































