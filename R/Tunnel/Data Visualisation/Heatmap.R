# Packages
library(RColorBrewer)
library(openxlsx)
library(dplyr)
library(edgeR)

# Read data
raw_data <- read.xlsx("./R/Tunnel/Data/Formatted/tunnel-bees_readcounts_sample-details-trimmed.xlsx")

# Select Genes
genes <- c("GB41387", "GB40722", "GB50642", "GB40714", "GB54617", "GB50940", "GB49348", "GB41887", "GB41392", "GB55807", "GB50290", "GB42813", "GB49478", "GB55243", "GB42174", "GB45448", "GB52425", "GB55460")

# Remove Genes column
row.names(raw_data) <- raw_data$X1
raw_data <- t(raw_data[,2:ncol(raw_data)]) %>%  subset(select = genes) %>% as.matrix()
logcpm <- cpm(raw_data, log=TRUE)

# Show results of gene expr analysis
colnames(raw_data) <- c("GB41387", "GB40722*", "GB50642", "GB40714**", "GB54617**", "GB50940**", "GB49348", "GB41887", "GB41392*", "GB55807", "GB50290**", "GB42813*", "GB49478**", "GB55243*", "GB42174", "GB45448", "GB52425", "GB55460")
colnames(logcpm)<- c("GB41387", "GB40722*", "GB50642", "GB40714**", "GB54617**", "GB50940**", "GB49348", "GB41887", "GB41392*", "GB55807", "GB50290**", "GB42813*", "GB49478**", "GB55243*", "GB42174", "GB45448", "GB52425", "GB55460")

# Create Heatmap for focal genes
heatmap(
  raw_data %>% t(),
  Colv = NA,
  Rowv = NA,
  col = colorRampPalette(brewer.pal(9, "Oranges"))(25)
)

legend(
  x = 36,
  y = 35,
  cex=.7,
  title = "Level of expr.",
  legend = c("min", "ave", "max"), 
  fill = colorRampPalette(brewer.pal(8, "Oranges"))(3)
)
