# Packages
library(tidyverse)
library(openxlsx)
library(writexl)
library(doSNOW)
library(caret)
library(e1071)

## ============================ Get Predictors ============================ ##
deseq2 <- read.xlsx("./R/Tunnel/Data/DESeq2_diff-expr-genes.xlsx")$GeneID


## ============================ Get Data & Format ============================ ##
raw_data <- read.xlsx("./R/Tunnel/Data/Formatted/tunnel-bees_readcounts_sample-details-trimmed.xlsx")

# Add row names
row.names(raw_data) <- raw_data$X1
raw_data <- raw_data[,2:ncol(raw_data)]

# Transpose data
data <- data.frame(t(raw_data)) %>% select(deseq2)

# Add class
data$Class = ifelse(
  grepl("N", rownames(data)),
  "Non.Dancer",
  "Dancer"
)

# Convert to factor
data$Class <- factor(data$Class)

## ============================ Split ============================ ##
# Set seed for reproducibility
set.seed(1234)
# Split Data 80% - 20%
indexes <- createDataPartition(
  data$Class,
  times = 1,
  p = 0.8,
  list = FALSE
)
bees.train <- data[indexes,]
bees.test <- data[-indexes,]

# Examine the proportions of the class lable across the datasets
prop.table(table(data$Class))
prop.table(table(bees.train$Class))
prop.table(table(bees.test$Class))

## ============================ Set up ============================ ##
# Set up caret to perform 10-fold cross validation repeated 3 
# times and to use a grid search for optimal model hyperparamter values
train.control <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 100,
  search = "grid",
  classProbs = TRUE,
  summaryFunction = twoClassSummary
)

# Specify parallel processing parameters
cl <- makeCluster(3, type = "SOCK")

# Register cluster so that caret will know to train in parallel.
registerDoSNOW(cl)

## ============================ Train ============================ ##
set.seed(123)
# SVM with radial kernel
svm_radial <- train(
  Class ~ ., 
  data = bees.train,
  method = "svmRadial",
  preProcess = c("center", "scale"),
  tuneLength = 10,
  trControl = train.control,
  metric = "ROC"
)

set.seed(456)
# Elastic Net
glmnet <- train(
  Class ~ ., 
  data = bees.train,
  method = "glmnet",
  preProcess = c("center", "scale"),
  tuneLength = 10,
  trControl = train.control,
  metric = "ROC"
)

# Stop parallel computing
stopCluster(cl)

## ============================ Compare ============================ ##
# Check models
svm_radial
glmnet

# collect resamples
results <- resamples(
  list(
    SVM = svm_radial,
    GLMNET = glmnet
  )
)

# summarize the distributions
summary(results)

## ============================ Predict ============================ ##
# SVM 
svm.predict <- predict(svm_radial, bees.test)
confusionMatrix(svm.predict, bees.test$Class)

# GLMNET 
glmnet.predict <- predict(glmnet, bees.test)
confusionMatrix(glmnet.predict, bees.test$Class)

## ============================ Save ============================ ##
# SVM
saveRDS(svm_radial, "./R/Tunnel/Models/Diff Selected/model_deseq2_svm.rds")

# GLMNET
saveRDS(glmnet, "./R/Tunnel/Models/Diff Selected/model_deseq2_glmnet.rds")
