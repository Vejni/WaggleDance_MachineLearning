# Packages
library(openxlsx)
library(dplyr)

# Read data
lib.sizes <- read.xlsx("./R/Tunnel/Data/tunnel_bees_library-sizes_NEW_190820.xlsx")
tunnel.bees <- read.xlsx("./R/Tunnel/Data/tunnel-bees_readcounts_sample-details.xlsx")
X1 <- tunnel.bees$X1

# Get proportions
cutoff.point <- 20000000

lib.sizes <- 
  lib.sizes %>%
  mutate(proportions = ifelse(total.reads > cutoff.point, cutoff.point / total.reads, 1))

# Format
tunnel.bees <- tunnel.bees[,2:ncol(tunnel.bees)]

# Normalize
tunnel.bees <- mapply("*", as.data.frame(tunnel.bees), t(as.matrix(select(lib.sizes, proportions))))

# Convert to numeric
mode(tunnel.bees) = "numeric"
tunnel.bees <- data.frame(tunnel.bees)

# Save dataframe
write.xlsx(cbind(X1, tunnel.bees), "./R/Tunnel/Data/Formatted/tunnel-bees_readcounts_sample-details-trimmed.xlsx")
