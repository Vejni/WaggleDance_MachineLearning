# Load the VennDiagram package
library(VennDiagram)

# Most features
svm_genes <- read.xlsx("./R/Tunnel/Data/Out/Dataset_S6.xlsx")$Gene
glmnet_genes <- read.xlsx("./R/Tunnel/Data/Out/Dataset_S4.xlsx")$Gene
rfe_genes <- read.xlsx("./R/Tunnel/Data/Out/Dataset_S8.xlsx")$.
colors <- c("#6b7fff", "#c3db0f", "#149414")

# Make Venn diagram from list of groups
venn.diagram(
  x = list(svm_genes, glmnet_genes, rfe_genes) ,
  category.names = c("SVM-Radial", "GLMNET ", "RFE-RF"),
  filename = './R/Tunnel/Data Visualisation/Venn.png',
  output=TRUE,
  imagetype="png", 
  scaled = FALSE,
  col = "black",
  fill = colors,
  cat.col = colors,
  cat.cex = 2,
  margin = 0.15,
  disable.logging = TRUE
)

# Top 20 features
svm_genes_20 <- c("GB54617","GB40714","GB50642","GB50940","GB49348","GB45448","GB55243","GB40722","GB41387","GB42813","GB55807","GB55460","GB41392","GB49478","GB41887","GB50290","GB42174","GB48893","GB52425","GB54048")
glmnet_genes_20 <- c("GB44245","GB47997","GB43230","GB40035","GB56014","GB53622","GB40209","GB51024","GB41392","GB43076","GB44261","GB49797","GB49478","GB45742","GB45641","GB41387","GB50567","GB40722","GB46711","GB47016")
rfe_genes_20 <- c("GB50642","GB40714","GB54617","GB50940","GB49348","GB55460","GB45448","GB50290","GB55807","GB55243","GB49478","GB42813","GB52425","GB41392","GB53144","GB41887","GB50203","GB42174","GB54048","GB50234")
colors <- c("#6b7fff", "#c3db0f", "#149414")

# Make Venn diagram from list of groups
venn.diagram(
  x = list(svm_genes_20, glmnet_genes_20, rfe_genes_20) ,
  category.names = c("SVM-Radial", "GLMNET ", "RFE-RF"),
  filename = './R/Tunnel/Data Visualisation/Venn_20.png',
  output=TRUE,
  imagetype="png", 
  scaled = FALSE,
  col = "black",
  fill = colors,
  cat.col = colors,
  cat.cex = 2,
  margin = 0.15,
  disable.logging = TRUE
)
