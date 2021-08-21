library(GeneOverlap)
library(openxlsx)

geneIDs <- c(read.xlsx("./R/Tunnel/Data/Formatted/tunnel-bees_readcounts_sample-details-trimmed.xlsx")$X1)

svm_genes <- c("GB54617","GB40714","GB50642","GB50940","GB49348","GB45448","GB55243","GB40722","GB41387","GB42813","GB55807","GB55460","GB41392","GB49478","GB41887","GB50290","GB42174","GB48893","GB52425","GB54048")
glmnet_genes <- c("GB44245","GB47997","GB43230","GB40035","GB56014","GB53622","GB40209","GB51024","GB41392","GB43076","GB44261","GB49797","GB49478","GB45742","GB45641","GB41387","GB50567","GB40722","GB46711","GB47016")
rfe_genes <- c("GB50642","GB40714","GB54617","GB50940","GB49348","GB55460","GB45448","GB50290","GB55807","GB55243","GB49478","GB42813","GB52425","GB41392","GB53144","GB41887","GB50203","GB42174","GB54048","GB50234")

focal_genes = list(
  svm = svm_genes,
  glmnet = glmnet_genes,
  rfe = rfe_genes
)

no_genes = 15314

gom.obj <- newGOM(
  focal_genes,
  focal_genes,
  genome.size=no_genes
)
print(gom.obj)
