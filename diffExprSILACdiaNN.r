####library####
#https://github.com/vdemichev/diann-rpackage
#install.packages("devtools")
#install.packages("rlang")
#install.packages("usethis")
#devtools::install_github("https://github.com/vdemichev/diann-rpackage")
library(diann)
####data####
fileName<-"C:/Users/animeshs/Downloads/SILACDIA2/report.tsv"
df <- diann_load(fileName)
####plot####
plot(log2(df$PG.MaxLFQ),log2(df$PG.Normalised))
hist(log2(df$PG.MaxLFQ))
protein.groups <- diann_maxlfq(df[df$Q.Value <= 0.01 & df$PG.Q.Value <= 0.01,], group.header="Protein.Group", id.header = "Precursor.Id", quantity.header = "Precursor.Normalised")
write.csv(protein.groups,paste0(fileName,"proteinGroups.csv"))
peptides <- diann_matrix(df, pg.q = 0.01)#, id.header="Stripped.Sequence")
write.csv(peptides,paste0(fileName,"peptideGroups.csv"))
peptides.maxlfq <- diann_maxlfq(df[df$Q.Value <= 0.01 & df$PG.Q.Value <= 0.01,], group.header="Stripped.Sequence", id.header = "Precursor.Id", quantity.header = "Precursor.Normalised")
write.csv(peptides.maxlfq,paste0(fileName,"peptideGroupsMQ.csv"))


