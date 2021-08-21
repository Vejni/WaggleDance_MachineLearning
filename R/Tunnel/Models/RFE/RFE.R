# Packages
library(randomForest)
library(tidyverse)
library(openxlsx)
library(doSNOW)
library(caret)
library(e1071)

## ============================ Get Data & Format ============================ ##
raw_data <- read.xlsx("./R/Tunnel/Data/Formatted/tunnel-bees_readcounts_sample-details-trimmed.xlsx")

# Add row names
row.names(raw_data) <- raw_data$X1
raw_data <- raw_data[,2:ncol(raw_data)]

# Transpose data
data <- data.frame(t(raw_data))

# Add class
data$Class <- ifelse(
  grepl("N", rownames(data)),
  "Non.Dancer",
  "Dancer"
)


# Convert to factor
data$Class <- factor(data$Class)

# Remove 0 variance cols
nzv <- nearZeroVar(data %>% select(-Class))
data <- data[, -nzv]

## ============================ Split ============================ ##
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
rfFuncs$summary <- twoClassSummary
ctrl <- rfeControl(
  functions = rfFuncs,
  method = "repeatedcv",
  repeats = 100,
  number = 10,
  verbose = FALSE
)

# Specify parallel processing parameters
cl <- makeCluster(3, type = "SOCK")

# Register cluster so that caret will know to train in parallel.
registerDoSNOW(cl)

## ============================ Train ============================ ##
set.seed(1)
# Run the rfe using rf algorithm
model <- rfe(
  factor(Class) ~ .,
  data = bees.train,
  preProcess = c("center", "scale"),
  sizes = c(5, 10, 20, 30, 75, 200, 500, 1000, 5000),
  rfeControl  = ctrl,
  metric = "ROC",
  method = "rf"
)

# Stop parallel computing
stopCluster(cl)

## ============================ Summary ============================ ##
model

# The predictors function can be used to get a text string of 
# variable names that were picked in the final model
predictors(model)

# Save
png(filename="./R/Tunnel/Models/RFE/Plots/Selected_Variables_Scree.png")
# Performance across subset sizes
trellis.par.set(caretTheme())
plot(model, type = c("g", "o"))
dev.off()

## ============================ Predict ============================ ##
# Get result metrics for train set
model$fit

# Make predictions for test set
preds <- predict(model, bees.test)
preds

## ============================ Save ============================ ##
saveRDS(model, "./R/Tunnel/Models/RFE/model_rfe.rds")
