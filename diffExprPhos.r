#Rscript.exe diffExprPhos.r L:/promec/TIMSTOF/LARS/2024/241118_Deo/phos/combined/txt/ Bio
#BiocManager::install("PhosR")
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpD <- args[1]
#inpD <-"L:/promec/TIMSTOF/LARS/2024/241118_Deo/phos/combined/txt/"
inpF<-paste0(inpD,"Phospho (STY)Sites.txt")
selection<-"Intensity."
inpL<-paste0(inpD,"Groups.txt")
lGroup <- args[2]
#lGroup<-"Bio"
i <- args[3]
data <- read.table(inpF,stringsAsFactors = FALSE, header = TRUE, quote = "", comment.char = "", sep = "\t")
print(summary(data))
print(colnames(data))
print(dim(data))
label<-read.table(inpL,header=T,sep="\t",row.names=1)#, colClasses=c(rep("factor",3)))
rownames(label)=sub(selection,"",rownames(label))
label["pair2test"]<-label[lGroup]
print(label)
#i <- 1
for(i in 1:3){
  selection2=paste0("___",i);
  print(selection2)
  thr=0.0#count
  selThr=0.05#pValue-tTest
  selThrFC=0.5#log2-MedianDifference
  cvThr=0.05#threshold for coefficient-of-variation
  hdr<-gsub("[^[:alnum:] ]", "",inpD)
  outP=paste(inpF,selection,selection2,selThr,selThrFC,cvThr,hdr,lGroup,"PhosR","VolcanoTestT","pdf",sep = ".")
  print(outP)
  pdf(outP)
  #data####
  LFQ<-as.matrix(data[,grep(selection,colnames(data))])
  colnames(LFQ)=sub(selection,"",colnames(LFQ))
  LFQ<-as.matrix(LFQ[,grep(selection2,colnames(LFQ))])
  colnames(LFQ)=sub(selection2,"",colnames(LFQ))
  #protNum<-1:ncol(LFQ)
  #protNum<-"LFQ intensity"#1:ncol(LFQ)
  #colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),sep=";")
  print(dim(LFQ))
  log2LFQ<-log2(LFQ)
  log2LFQ[log2LFQ==-Inf]=NA
  log2LFQ[log2LFQ==0]=NA
  print(summary(log2LFQ))
  #hist(log2LFQ)
  print(dim(log2LFQ))
  #https://pyanglab.github.io/PhosR/articles/PhosR.html
  dataPhosR <- PhosR::PhosphoExperiment(assays = list(Quantification = as.matrix(log2LFQ)),
                                  Site = as.numeric(data$Position),
                                  GeneSymbol = paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(data$Fasta.headers, "GN=",fixed=T), "[", 2)), " "), "[", 1)), ";",fixed=T), "[", 1)),
                                  UniprotID = paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(data$Proteins, ";",fixed=T), "[", 1)), "-"), "[", 1)), " ",fixed=T), "[", 1)),
                                  Residue = data$Amino.acid,
                                  Sequence = gsub("[^A-Z]","",data$Phospho..STY..Probabilities))
#  dataPhosR<-PhosR::PhosphoExperiment(data)
  print(class(dataPhosR))
#  PhosR::GeneSymbol(dataPhosR) <- paste(sapply(strsplit(paste(sapply(strsplit(paste(sapply(strsplit(dataPhosR@assays@data@listData[[1]]$Fasta.headers, "GN=",fixed=T), "[", 2)), " "), "[", 1)), ";",fixed=T), "[", 1))
#  print(dataPhosR@GeneSymbol)
#  PhosR::Residue(dataPhosR) <- dataPhosR@assays@data@listData[[1]]$Amino.acid
#  PhosR::Site(dataPhosR) <- as.numeric(dataPhosR@assays@data@listData[[1]]$Position)
# PhosR::Sequence(dataPhosR) <- gsub("[^A-Z]","",dataPhosR@assays@data@listData[[1]]$Phospho..STY..Probabilities)
  print(dataPhosR)
  #data = data[!data$Reverse=="+",]
  #data = data[!data$Potential.contaminant=="+",]
  #data = data[!data$Only.identified.by.site=="+",]
  #row.names(data)<-paste(row.names(data),data$Fasta.headers,data$Sequence.window,data$Localization.prob,sep=";;")
  #protNum<-1:ncol(LFQ)
  #protNum<-"LFQ intensity"#1:ncol(LFQ)
  #colnames(LFQ)=paste(protNum,sub(selection,"",colnames(LFQ)),sep=";")
  #label####
  #gsub("_[0-9]{1}", "", colnames(dataPhosR))
  #at least 50% of the replicates in at least one of the conditions
  dataPhosRfiltered <- PhosR::selectGrps(dataPhosR, label$pair2test, 0.5, n=1)
  print(dim(dataPhosRfiltered))
  set.seed(42)
  dataPhosRfilteredImputedTmp <- PhosR::scImpute(dataPhosRfiltered, 0.5, label$pair2test)[,colnames(dataPhosRfiltered)]
  print(dim(dataPhosRfilteredImputedTmp))
  dev.off()
}
