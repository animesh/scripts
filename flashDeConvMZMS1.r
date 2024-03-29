#usage####
#F:\R-4.3.1\bin\Rscript.exe flashDeConvMZMS1.r F:\IRD\
#mzML####
#generate mzML in windows prompt using cmd
##for %i in ("L:\promec\HF\Lars\2023\IgG Mus Therese\mzML\deconv\*.raw) do ("F:\OneDrive - NTNU\ProteoWizard 3.0.22155.0ff594f 64-bit\msconvert.exe"  --filter "peakPicking true 1-" %i)
#runFLASHDeconv####
#cd F:\IRD
#for %i in ("*.mzML") do ("F:\OpenMS-3.0.0\bin\FLASHDeconv.exe"  -in 231006_IRD_10_D22_T4_ddaPD.mzML -out 231006_IRD_10_D22_T4_ddaPD.mzML.fdc.tsv )
#setup####
#https://abibuilder.cs.uni-tuebingen.de/archive/openms/OpenMSInstaller/experimental/feature/FLASHDeconv/
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 1) {stop("\n\nNeeds full path of the directory containing REPORTS for example: c:/Users/animeshs/R/bin/Rscript.exe flashDeConvMZMS1.r \"L:/promec/HF/Lars/2023/IgG Mus Therese/mzML/deconv/\"", call.=FALSE)}
#dataFolder####
inpD <- args[1]
#inpD<-"F:/IRD/"
#getFlashDeConv####
#download.file("https://abibuilder.cs.uni-tuebingen.de/archive/openms/OpenMSInstaller/experimental/feature/FLASHDeconv/OpenMS-3.0.0-pre-HEAD-2022-08-16-Win64.exe",paste0(inpD,"OpenMS.zip"))
#unzip(paste0(inpD,"OpenMS.zip"),exdir = paste0(inpD,"OpenMS"))
#merge####
inpFL<-list.files(pattern="*mzML.fdc.tsv$",path=inpD,full.names=F,recursive=F)
outF=paste(inpD,"intMZ1",sep = "/")
outP=paste(outF,"plot","pdf",sep = ".")
pdf(outP)
dfMZ1<-0
#inpF<-inpFL[1:4]
for(inpF in inpFL){
    print(inpF)
    data<-read.csv(paste0(inpD,inpF),sep="\t")
    print(summary(data))
    if(sum(!is.na(data$MonoisotopicMass))>0){
    dataS<-as.data.frame(cbind(MZ1=round(data$MonoisotopicMass),sumInt=data$SumIntensity))
    dataSA<-with(dataS, aggregate(list(sumIntensity = sumInt), list(MZ1 = MZ1), sum))
    MZ1<-dataSA$MZ1
    dfMZ1<-union(dfMZ1,MZ1)
    colnames(dataSA)<-paste0(colnames(dataSA),inpF)
    plot((as.numeric(dataSA[,1])),log2(as.numeric(dataSA[,2])),main=inpF,xlab="dcMZ1",ylab="log2sumIntensity")
    dataSA$MZ1<-MZ1
    assign(inpF,dataSA)}
}
hist(dfMZ1)
data<-data.frame(MZ1=dfMZ1)
#data<-merge(data,`210408_EL500_SAX_urt3.raw.intensityThreshold1000.errTolDecimalPlace3.MZ1R.csv`, by="MZ1",all=T)
#plot(data$MZ1,data$MZ1210408_EL500_SAX_urt3.raw.intensityThreshold1000.errTolDecimalPlace3.MZ1R.csv)
for (obj in inpFL) {
    if(exists(obj)){
        print(obj)
    data<-merge(data,get(obj),by="MZ1",all=T)}
}
data[is.na(data)]<-0
data<-data[order(rowSums(data),decreasing=T),]
write.csv(data,paste0(outF,".sort.combined.csv"))
if(exists(obj)){
    hist(data$MZ1)
    #plot(data$MZ1)
    data1000<-data[c(1:1000),]
    hist(data1000$MZ1)
    plot(data$MZ1,rowSums(data))
    plot(data1000$MZ1,rowSums(data1000))
    write.csv(data1000,paste0(outF,".combined.top1000.csv"))
    print(paste0("resuls in ",outF,"*"))
}
