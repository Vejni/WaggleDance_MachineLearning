# Packages
library(wesanderson)
library(tidyverse)
library(ggbiplot)
library(openxlsx)
library(ggplot2)
library(GGally)

# Read data
raw_data <- read.xlsx("./R/Tunnel/Data/Formatted/tunnel-bees_readcounts_sample-details-trimmed.xlsx")

# Add rownames
row.names(raw_data) <- raw_data$X1
raw_data <- raw_data[,2:ncol(raw_data)]

# Transpose
raw_data <- data.frame(t(raw_data))

# Add Classes - All 4
# raw_data$Class = ifelse(
#   grepl("D", rownames(raw_data)),
#   ifelse(
#     grepl("L", rownames(raw_data)),
#     "Dancer.Long",
#     "Dancer.Short"
#   ),
#   ifelse(
#     grepl("L", rownames(raw_data)),
#     "Non.Dancer.Long",
#     "Non.Dancer.Short"
#   )
# )

# Add Classes - Dancers vs Non-Dancers
raw_data$Class = ifelse(
  grepl("D", rownames(raw_data)),
  "Dancer",
  "Non.Dancer"
)

# Convert to matrix
my_matrix <- raw_data %>% select(-Class) %>% as.matrix()

# Remove 0 variance cols
my_matrix <- my_matrix[ , which(apply(my_matrix, 2, var) != 0)]
which(apply(my_matrix, 2, var)==0)

# Perform PCA
pca <- prcomp((my_matrix), scale=TRUE)

# Write scores
write.csv(pca$x, "./R/Tunnel/Data/Out/Dataset_S1.csv")

# Write loadings
write.csv(pca$rotation, "./R/Tunnel/Data/Out/Dataset_S2.csv")

# Compute variances
pca.var <- pca$sdev^2
pca.var.per <- round(pca.var/sum(pca.var)*100, 1)

# Plot variance per PCA
barplot(
  pca.var.per,
  main="Scree plot",
  xlab="PCA",
  ylab="Variation (%)"
)

# Pairwise plots of PCAs
pcas <- data.frame(pca$x)[, 1:5]
ggpairs(
  pcas, 
  aes(
    label=rownames(pcas),
    color = raw_data$Class
  )
) + ggtitle("PCA Analysis: 4 groups comparison")

# Format data for ggplot
pca.data <- data.frame(
  Sample=rownames(pca$x),
  X=pca$x[,1],
  Y=pca$x[,2]
)

Class = raw_data$Class
# Plot with ellipses
ggplot(
  data=pca.data, 
  aes(
    x=X, 
    y=Y, 
    label=Sample, 
    color = Class,
    shape = Class
  ), 
  shape = batch,
  group = raw_data$Class
) +
  geom_point() +
  stat_ellipse() +
  xlab(paste("PC1 - ", pca.var.per[1], "%", sep="")) +
  ylab(paste("PC2 - ", pca.var.per[2], "%", sep="")) +
  theme_light() + 
  scale_color_manual(values=wes_palette(n=2, name="Darjeeling1"))
