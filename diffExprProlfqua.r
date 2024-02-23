#git checkout fe5f9e92f3fe5ca0c75e9d8acfd211feb7358066 diffExprProlfqua.r
#Rscript diffExprProlfqua.r
#remotes::install_github('fgcz/prolfqua', dependencies = TRUE)
#https://fgcz.github.io/prolfqua/articles/Comparing2Groups.html
#label####
inputAnnotation <-"L:/promec/Animesh/Mathilde/Groups.xlsx"
labelD<-basename(inputAnnotation)
annotation <- readxl::read_xlsx(inputAnnotation)
head(annotation$raw.file)
#data####
inputMQfile <-"L:/promec/Animesh/Mathilde/rawdata_from animesh 2.txt"
startdata <- prolfqua::tidyMQ_ProteinGroups(inputMQfile)
head(startdata$raw.file)
outP=paste(inputMQfile,labelD,"prolfqua","pdf",sep = ".")
#pdf(outP)
startdata <- dplyr::inner_join(annotation, startdata, by = "raw.file")
#startdata <- dplyr::filter(startdata, nr.peptides > 1)
startdata <- dplyr::filter(startdata, is.na(Rem))
atable <- prolfqua::AnalysisTableAnnotation$new()
atable$fileName = "raw.file"
head(startdata$proteinID)
atable$hierarchy[["protein_Id"]] <- c("proteinID")
atable$factors[["mouse."]] = "sample"
atable$set_response("mq.protein.intensity")
config <- prolfqua::AnalysisConfiguration$new(atable)
adata <- prolfqua::setup_analysis(startdata, config)
lfqdata <- prolfqua::LFQData$new(adata, config)
lfqdata$remove_small_intensities()
dataLFQ<-lfqdata[["to_wide"]]()$data
head(dataLFQ)
dataLFQd<-data.frame(dataLFQ[,3:61])
dataLFQd<-log2(dataLFQd)
dataLFQd<-sapply(dataLFQd,as.numeric)
hist(dataLFQd)
vsn::meanSdPlot(dataLFQd)
vsn::meanSdPlot(dataLFQd,ranks = FALSE)
rownames(dataLFQd)<-dataLFQ$protein_Id
countTableDAuniGORNAddsMed<-apply(dataLFQd,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsSD<-apply(dataLFQd,1,function(x) sd(x,na.rm=T))
countTableDAuniGORNAdds<-(dataLFQd-countTableDAuniGORNAddsMed)#/countTableDAuniGORNAddsSD
hist(countTableDAuniGORNAdds)
par(mar=c(12,3,1,1))
boxplot(countTableDAuniGORNAdds,las=2)
write.csv(dataLFQd,file=paste(inputMQfile,labelD,"dataLFQd","csv",sep = "."),quote=FALSE)
lfqdata$factors()
lfqplotter <- lfqdata$get_Plotter()
density_nn <- lfqplotter$intensity_distribution_density()
lfqplotter$NA_heatmap()
lfqdata$get_Summariser()$plot_missingness_per_group()
lfqplotter$missigness_histogram()
stats <- lfqdata$get_Stats()
stats$violin()
prolfqua::table_facade( stats$stats_quantiles()$wide, paste0("quantile of ",stats$stat ))
stats$density_median()
lt <- lfqdata$get_Transformer()
transformed <- lt$log2()$robscale()$lfq
transformed$config$table$is_response_transformed
transformed$config$table$workIntensity
dataLFQt<-transformed[["to_wide"]]()$data
head(dataLFQt)
dataLFQtd<-data.frame(dataLFQt[,3:61])
dataLFQtd<-sapply(dataLFQtd,as.numeric)
rownames(dataLFQtd)<-dataLFQt$protein_Id
hist(dataLFQtd)
diffLFQtd<-dataLFQtd-dataLFQd
hist(diffLFQtd)
par(mar=c(12,3,1,1))
boxplot(diffLFQtd,las=2)
boxplot(countTableDAuniGORNAdds,las=2)
countTableDAuniGORNAddsMed<-apply(dataLFQtd,1,function(x) median(x,na.rm=T))
countTableDAuniGORNAddsSD<-apply(dataLFQtd,1,function(x) sd(x,na.rm=T))
countTableDAuniGORNAdds<-(dataLFQtd-countTableDAuniGORNAddsMed)#/countTableDAuniGORNAddsSD
hist(countTableDAuniGORNAdds)
boxplot(countTableDAuniGORNAdds,las=2)
boxplot(dataLFQtd,las=2)
vsn::meanSdPlot(dataLFQtd)
vsn::meanSdPlot(dataLFQtd,ranks = FALSE)
write.csv(dataLFQtd,file=paste(inputMQfile,labelD,"prolfqua","csv",sep = "."),quote=FALSE)
dataLFQtdc<-cor(dataLFQtd,use="pairwise.complete.obs",method="pearson")
pheatmap::pheatmap(dataLFQtdc)
pl <- transformed$get_Plotter()
density_norm <- pl$intensity_distribution_density()
plot(density_norm[["data"]][["transformedIntensity"]],density_norm[["data"]][["log2_mq.protein.intensity"]])
hist(density_norm[["data"]][["transformedIntensity"]])
hist(density_norm[["data"]][["log2_mq.protein.intensity"]])
hist(density_norm[["data"]][["transformedIntensity"]]-density_norm[["data"]][["log2_mq.protein.intensity"]])
gridExtra::grid.arrange(density_nn, density_norm)
pl$pairs_smooth()
p <- pl$heatmap_cor()
transformed$config$table$get_response()
formula_Condition <-  prolfqua::strategy_lm("transformedIntensity ~ mouse.")
modelName  <- "Model"
unique(transformed$data$mouse.)
Contrasts <- c("SI" = "mouse.SI - mouse.STNTC",
               "AMHC" = "mouse.AMHC - mouse.STNTC",
               "Botox" = "mouse.Botox - mouse.STNTC",
               "BI" = "mouse.BI - mouse.STNTC",
               "BC" = "mouse.BC - mouse.STNTC",
               "SC" = "mouse.SC - mouse.STNTC",
               "IC" = "mouse.IC - mouse.STNTC",
               "BICW" = "mouse.BICW - mouse.STNTC")
mod <- prolfqua::build_model(transformed$data,formula_Condition,subject_Id = transformed$config$table$hierarchy_keys() )
mod$anova_histogram("FDR")
aovtable <- mod$get_anova()
head(aovtable)
dim(aovtable)
write.csv(aovtable,file=paste(inputMQfile,labelD,"aovtable","csv",sep = "."),quote=FALSE)
xx <- aovtable |> dplyr::filter(FDR < 0.2)
signif <- transformed$get_copy()
#write.csv(signif$to_wide(),file=paste(inputMQfile,labelD,"signif","csv",sep = "."),quote=FALSE)
signif$data <- signif$data |> dplyr::filter(protein_Id %in% xx$protein_Id)
hmSig <- signif$get_Plotter()$heatmap()
hmSig
contr <- prolfqua::Contrasts$new(mod, Contrasts)
v1 <- contr$get_Plotter()$volcano()
v1
contr <- prolfqua::ContrastsModerated$new(contr)
contrdf <- contr$get_contrasts()
plotter <- contr$get_Plotter()
v2 <- plotter$volcano()
gridExtra::grid.arrange(v1$FDR,v2$FDR, ncol = 1)
plotter$ma_plotly()
mC <- prolfqua::ContrastsMissing$new(lfqdata = transformed, contrasts = Contrasts)
colnames(mC$get_contrasts())
merged <- prolfqua::merge_contrasts_results(prefer = contr,add = mC)$merged
plotter <- merged$get_Plotter()
tmp <- plotter$volcano()
tmp$FDR
merged <- prolfqua::merge_contrasts_results(prefer = contr,add = mC)
moreProt <- transformed$get_copy()
moreProt$data <- moreProt$data |> dplyr::filter(protein_Id %in% merged$more$contrast_result$protein_Id)
moreProt$get_Plotter()$raster()
#writexl::write_xlsx(as.data.frame(moreProt),paste(inputMQfile,labelD,"prolfqua","xlsx",sep = "."))
#BiocManager::install("org.Mm.eg.db")
#remotes::install_github("protViz/prora")
#BiocManager::install("clusterProfiler")
#evalAll <- require("clusterProfiler") & require("org.Mm.eg.db") & require("prora")
#library(clusterProfiler)
#library(org.Mm.eg.db)
#bb <- prolfqua::get_UniprotID_from_fasta_header(merged$merged$get_contrasts(),idcolumn = "protein_Id")
#bb <- prora::map_ids_uniprot(bb$protein_Id)
#ranklist <- bb$statistic
#names(ranklist) <- bb$P_ENTREZGENEID
#res <- clusterProfiler::gseGO(sort(ranklist, decreasing = TRUE),OrgDb = org.Mm.eg.db,ont = "ALL")
#ridgeplot( res )
#dotplot(res , showCategory = 30)
#enrichplot::upsetplot(res)
