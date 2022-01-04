library(openxlsx)
library(limma)
library(dplyr)

# Read data
raw_data <- read.xlsx("./R/Tunnel/Data/Formatted/tunnel-bees_readcounts_sample-details-trimmed.xlsx")

# Add rownames
row.names(raw_data) <- raw_data$X1
raw_data <- raw_data[,2:ncol(raw_data)]

# Add nest information
full_annotations <- read.xlsx("R/Tunnel/Data/Out/Dataset_S9.xlsx")
row.names(full_annotations) <- full_annotations$ID

# Add Classes - Dancers vs Non-Dancers
full_annotations$Class = ifelse(
  grepl("D", rownames(full_annotations)),
  "Dancer",
  "Non.Dancer"
)

# Subset
full_annotations <- full_annotations %>% select(colony, Class)

# Simulate a paired experiment with incomplete blocks
Block <- full_annotations$Colony
Treat <- as.factor(full_annotations$Class)
design <- model.matrix(~Treat)

# Estimate the within-block correlation
dupcor <- duplicateCorrelation(raw_data, design, block=Block)
dupcor$consensus.correlation
