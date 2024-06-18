#Rscript metaboGroups.r DR_MOHAN_300S_METABOLOMICS_ANALYSIS_NEGATIVE_MODE.xlsx DR_MOHAN_300S_METABOLOMICS_ANALYSIS_POSITIVE_MODE.xlsx
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
options(nwarnings = 1000000)
warnings()
#data####
inpFN<-args[1]
inpFP<-args[2]
#inpFN<-file.path("DR_MOHAN_300S_METABOLOMICS_ANALYSIS_NEGATIVE_MODE.xlsx")
#inpFP<-file.path("DR_MOHAN_300S_METABOLOMICS_ANALYSIS_POSITIVE_MODE.xlsx")
if(require("readxl")){
  dataN<-readxl::read_xlsx(inpFN)
  names(dataN)
  dataP<-readxl::read_xlsx(inpFP)
  names(dataP)
}#'String exceeds Excel's limit of 32,767 characters.'#https://stackoverflow.com/a/43051932
data<-rbind(dataP[,1:25],dataN[,1:25])
dim(data)
#plot####
pdf(paste(inpFN,basename(inpFP),"pdf",sep = "."))
#dev.off()
#ppm####
hist((data$`Annot. DeltaMass [ppm]`),breaks = 100)
hist(log2(data$`Annot. DeltaMass [ppm]`),breaks = 100)
hist(as.matrix(data[abs(data$`Annot. DeltaMass [ppm]`)<5,"Annot. DeltaMass [ppm]"]),breaks = 100)
hist(as.matrix(dataN[abs(dataN$`Annot. DeltaMass [ppm]`)<5,"Annot. DeltaMass [ppm]"]),breaks = 100)
hist(as.matrix(dataP[abs(dataP$`Annot. DeltaMass [ppm]`)<5,"Annot. DeltaMass [ppm]"]),breaks = 100)
#selectN####
selection="Norm.";
print(paste("Selecting",selection,"Values(s)"))
dataSelN<-dataN[,grep(selection,colnames(dataN))]
#rownames(dataSelN)<-paste(data$CSID,sep=";;")#repeat IDs ‘103012’, ‘10441592’, ‘10480082’, ‘113087’, ‘13628081’, ‘165080’, ‘19992713’, ‘2015556’, ‘2626’, ‘27027782’, ‘272336’, ‘296912’, ‘30777618’, ‘30777619’, ‘30778500’, ‘30778501’, ‘30778504’, ‘390063’, ‘392720’, ‘398402’, ‘4039’, ‘4424891’, ‘56515’, ‘5660’, ‘610602’, ‘74852096’, ‘74886393’, ‘74886798’, ‘75634’, ‘7822264’, ‘8832538’, ‘9835’, ‘9840’,
rownames(dataSelN)<-paste(dataN$`Calc. MW`,dataN$`RT [min]`,dataN$CSID,dataN$Name,dataN$`KEGG ID`,dataN$`Metabolika Pathways`,sep=";;")
colnames(dataSelN)<-gsub("[\\(\\)]", "", regmatches(colnames(dataSelN), gregexpr("\\(.*?\\)", colnames(dataSelN))))#split(colnames(dataSelN),"\(")[[1]]
dim(dataSelN)
dataSelN5ppm<-dataSelN[abs(dataN$`Annot. DeltaMass [ppm]`)<5,]
dim(dataSelN5ppm)
write.csv(dataSelN5ppm,paste0(inpFN,selection,"dataSelN5ppm.csv"),row.names = T)
print(paste("Selected",selection,"Values(s) written to",paste0(inpFN,selection,"dataSelN5ppm.csv")))
print("Selecting Raw Intensity Values(s) for dataSelN")
print("Selecting Raw Intensity Values(s) for dataSelN5ppm")
#samples####
Bondhu
_JMI_SAMPLE_(helathy)
_JMI_LP_SAMPLE(Liver patients)
_JMI_COVID_SAMPLE (Covid)
Rest BLANK and POOL might be contro
#combine####
check the ref shared by Mohan for combining positive and negative modes and combine the samples, need mapping?
#close####
dev.off()
summary(warnings())
