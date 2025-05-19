#  Call important libraries
library(writexl)
library(readxl)
library(tibble)
library(tidyverse)
library(tidyr)
library(tidyselect)
library(dplyr)
library(caret)
library(e1071)
library(randomForest)
library(class)
library(C50)
library(ggplot2)
library(naivebayes)

# Import Train and Test data
TrainData <- readRDS('TrainData.rds')
TestData <- readRDS('TestData.rds')

# convert target/dependent variable to factor
TrainData$Type <- as.factor(TrainData$Type)
TestData$Type <- as.factor(TestData$Type)


# view(TrainData)
independent_variable_nos <- NCOL(TrainData)-1

# svm radial

svm_radial1 <- train(Type ~., data = TrainData, method = "svmRadial",
                     trControl = train_control, tuneLength = 6)

svm_radial1
pred_svm_radialtrain1 <- predict(svm_radial1, newdata = TrainData[,1:independent_variable_nos])
pred_svm_radialtest1 <- predict(svm_radial1, newdata = TestData[,1:independent_variable_nos] )
cm_svm_radial_train1 <- confusionMatrix(TrainData$Type, pred_svm_radialtrain1, positive = 'tumor', mode = "everything")
cm_svm_radial_test1 <- confusionMatrix(TestData$Type, pred_svm_radialtest1, positive = 'tumor', mode = "everything")
cm_svm_radial_train1
cm_svm_radial_test1


# knn

# using classs library
library(class)
NROW(TrainData)
number_of_rows_data <- NROW(TrainData)
appropriate_kvalue <- as.integer(sqrt(number_of_rows_data))


knn_pred_train_class <- knn(train = TrainData[,1:independent_variable_nos],test = TrainData[,1:independent_variable_nos], 
                            cl = TrainData$Type, k = appropriate_kvalue)
knn_pred_train_class
knn_pred_test_class <- knn(train = TrainData[,1:independent_variable_nos],test= TestData[,1:independent_variable_nos],
                           cl = TrainData$Type, k = appropriate_kvalue)

cm_knn_train_class <- confusionMatrix(TrainData$Type, knn_pred_train_class, positive = 'tumor', mode = "everything")
cm_knn_test_class <- confusionMatrix(TestData$Type, knn_pred_test_class, positive = 'tumor', mode = "everything")
cm_knn_train_class
cm_knn_test_class

# select a optimum k value
# for train
j=1
k.optm.train=1
for (j in 1:28){
  knn.mod.train <- knn(TrainData[,1:independent_variable_nos],test = TrainData[,1:independent_variable_nos], 
                       cl = TrainData$Type, k=j)
  k.optm.train[j] <- 100 * sum(TrainData$Type == knn.mod.train)/NROW(TrainData$Type)
  k=j
  cat(k,'=',k.optm.train[j],'
')
}

# for test
i=1
k.optm.test=1
for (i in 1:28){
  knn.mod.test <- knn(TrainData[,1:independent_variable_nos],test = TestData[,1:independent_variable_nos], 
                      cl = TrainData$Type, k=i)
  k.optm.test[i] <- 100 * sum(TestData$Type == knn.mod.test)/NROW(TestData$Type)
  k=i
  cat(k,'=',k.optm.test[i],'
')
}
optimum_k_value <- as.numeric(readline("Enter optimum k value: "))

# knn with class with optimum k value
knn_pred_train_class_optk <- knn(train = TrainData[,1:independent_variable_nos],test = TrainData[,1:independent_variable_nos], 
                                 cl = TrainData$Type, k = optimum_k_value)

knn_pred_test_class_optk <- knn(train = TrainData[,1:independent_variable_nos],test= TestData[,1:independent_variable_nos],
                                cl = TrainData$Type, k = optimum_k_value)

cm_knn_train_class_optk <- confusionMatrix(TrainData$Type, knn_pred_train_class_optk, positive = 'tumor', mode = "everything")
cm_knn_test_class_optk <- confusionMatrix(TestData$Type, knn_pred_test_class_optk, positive = 'tumor', mode = "everything")
cm_knn_train_class_optk
cm_knn_test_class_optk
# -----------------------------------------------------------------------------------------------

# RF models
# tuning hyperparameters
# to select best mtry
set.seed(1234)
tuneGridrf <- expand.grid(.mtry = c(1:10))
rf_mtry <- train(Type~.,data = TrainData, method = "rf", metric = "Accuracy",
                 tuneGrid = tuneGridrf, trControl = train_control, importance = TRUE,
                 nodesize = 14, ntree = 300)
rf_mtry$bestTune$mtry
max(rf_mtry$results$Accuracy)
best_mtry <- rf_mtry$bestTune$mtry
# can train random forest with following parameters
mtry_tune <- as.numeric(readline("enter mtry see above results in console: "))


# search the best maxnode
store_maxnode <- list()
tuneGrid_rf <- expand.grid(.mtry = best_mtry)
# for (maxnodes in c(5:15)) # c(20:30)
for (maxnodes in c(5:30)){
  set.seed(1234)
  rf_maxnode <- train(Type~.,
                      data = TrainData,
                      method = "rf",
                      metric = "Accuracy",
                      tuneGrid = tuneGrid_rf,
                      trControl = train_control,
                      importance = TRUE,
                      nodesize = 14,
                      maxnodes = maxnodes,
                      ntree = 300)
  current_iteration <- toString(maxnodes)
  store_maxnode[[current_iteration]] <- rf_maxnode
}
results_node <- resamples(store_maxnode)
summary(results_node)

# can train random forest with following parameters
maxnodes_tune <- as.numeric(readline("enter maxnodes see above results in console: "))

# Search for best ntrees
store_maxtrees <- list()
for (ntree in c(250, 300, 350, 400, 450, 500, 550, 600, 800, 1000, 2000)){
  set.seed(5678)
  rf_maxtrees <- train(Type~.,
                       data = TrainData,
                       method = "rf",
                       metric = "Accuracy",
                       tuneGrid = tuneGrid_rf,
                       trControl = train_control,
                       importance = TRUE,
                       nodesize = 14,
                       maxnodes = 24,
                       ntree = ntree)
  key <- toString(ntree)
  store_maxtrees[[key]] <- rf_maxtrees
}
results_tree <- resamples(store_maxtrees)
summary(results_tree)
# can train random forest with following parameters
ntree_tune <- as.numeric(readline("enter ntree see above results in console: "))

# can train random forest with following parameters
# ntree=1000, mtry=1, maxnodes=20
fit_rf <- train(Type~.,
                data = TrainData,
                method = "rf",
                metric = "Accuracy",
                tuneGrid = tuneGrid_rf,
                trControl = train_control,
                importance = TRUE,
                nodesize = 14,
                ntree = ntree_tune,
                maxnodes = maxnodes_tune)


pred_rf_tune_tr <- predict(fit_rf, TrainData[,1:independent_variable_nos])
pred_rf_tune_te <- predict(fit_rf, TestData[,1:independent_variable_nos])
cm_pred_rf_tune_tr <- confusionMatrix(pred_rf_tune_tr, TrainData$Type, positive = 'tumor', mode = "everything")
cm_pred_rf_tune_te <- confusionMatrix(pred_rf_tune_te, TestData$Type, positive = 'tumor', mode = "everything")
cm_pred_rf_tune_tr 
cm_pred_rf_tune_te

#---------------------------------------------------------------------------------------------------------------------------
# GBM - Stochastic Gradient Boosting
library(gbm)
# method gbm
set.seed(10)
gbm_model <- train(TrainData[,1:independent_variable_nos], TrainData$Type, method = "gbm", metric = "Accuracy",
                   trControl = train_control, verbose = FALSE)
pred_gbm_model_train <- predict(gbm_model , TrainData[,1:independent_variable_nos])
pred_ggbm_model_test <- predict(gbm_model , TestData[,1:independent_variable_nos])
cm_pred_gbm_model_train <- confusionMatrix(pred_gbm_model_train, TrainData$Type, positive = 'tumor', mode = "everything")
cm_pred_gbm_model_test <- confusionMatrix(pred_ggbm_model_test, TestData$Type, positive = 'tumor', mode = "everything")
#---------------------------------------------------------------------------------------------------------------------------
# xgboost
library(xgboost)
# method xgbTree
grid_default_xgb <- expand.grid(nrounds = 100,
                                max_depth = 6,
                                eta = 0.3,
                                gamma = 0,
                                colsample_bytree = 1,
                                min_child_weight = 1,
                                subsample = 1)

xg_boost <- train(Type~., data = TrainData, trControl = train_control, tuneGrid= grid_default_xgb, method = 'xgbTree',
                  verbose = TRUE)

pred_xg_boost_train <- predict(xg_boost, TrainData[,1:independent_variable_nos])
pred_xg_boost_test <- predict(xg_boost, TestData[,1:independent_variable_nos])
cm_pred_xg_boost_train <- confusionMatrix(pred_xg_boost_train, TrainData$Type, positive = 'tumor', mode = "everything")
cm_pred_xg_boost_test <- confusionMatrix(pred_xg_boost_test, TestData$Type, positive = 'tumor', mode = "everything")
cm_pred_xg_boost_train
cm_pred_xg_boost_test
#----------------------------------------------------------------------------------------------------
# NB - Naive Bayes (NB) ****bad***
library(klaR)
set.seed(7)

# Grid = expand.grid(usekernel=TRUE,adjust=1,fL=c(0.2,0.5,0.8))
# Grid = data.frame(usekernel=TRUE,adjust=c(0,0.5,1.0),fL=c(0,0.5,1.0))
# nb <- train(Type~., data = TrainData, trControl = train_control, method = 'nb',
#                metric = "accuracy", importance = TRUE) #tuneGrid = Grid)
# # 
# modelLookup("naive_bayes")
# modelLookup("naive_bayes")
library(naivebayes)

nb_model <- train(Type~., data = TrainData, trControl = tune_control, tuneGrid = expand.grid(
  usekernel = c(TRUE, FALSE), laplace = 0.3, adjust = c(0,0.5,1.0)),FL = 0, method = 'naive_bayes')
nb_model$bestTune   
# plot(nb)
pred_nb_model_train <- predict(nb_model, TrainData)
pred_nb_model_test <- predict(nb_model, TestData)
cm_pred_nb_model_train <- confusionMatrix(pred_nb_model_train, TrainData$Type, positive = 'tumor', mode = "everything")
cm_pred_nb_model_test <- confusionMatrix(pred_nb_model_test, TestData$Type, positive = 'tumor', mode = "everything")
cm_pred_nb_model_train
cm_pred_nb_model_test












