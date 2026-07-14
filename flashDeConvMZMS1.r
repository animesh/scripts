#usage####
#..\R-4.5.0\bin\Rscript.exe  flashDeConvMZMS1.r L:\promec\HF\Lars\2026\Solveig_Janus\test\redo\
#mzML####
#generate mzML in windows prompt using cmd
#wget https://mc-tca-01.s3.us-west-2.amazonaws.com/ProteoWizard/bt83/4071095/pwiz-bin-windows-x86_64-vc145-release-3_0_26181_1c640ef.tar.bz2
#tar xvjf pwiz-bin-windows-x86_64-vc145-release-3_0_26181_1c640ef.tar.bz2
#l:
#cd L:\promec\HF\Lars\2026\Solveig_Janus\test\
#for %i in ("*.raw") do ("L:\promec\Animesh\Download\pwiz-bin-windows-x86_64-vc145-release-3_0_26181_1c640ef\msconvert.exe" %i)
#mkdir centroided
#for %i in (*.raw) do "L:\promec\Animesh\Download\pwiz-bin-windows-x86_64-vc145-release-3_0_26181_1c640ef\msconvert.exe" "%i" --mzML --zlib --filter "peakPicking vendor msLevel=1-" -o centroided
#for %i in ("*.raw") do start "%~nxi" "L:\promec\Animesh\Download\pwiz-bin-windows-x86_64-vc145-release-3_0_26181_1c640ef\msconvert.exe" "%i" --mzML --zlib --filter "peakPicking vendor msLevel=1-" -o centroided
#runFLASHDeconv####
#wget https://abibuilder.cs.uni-tuebingen.de/archive/openms/OpenMSInstaller/experimental/FVdeploy/OpenMS-3.5.0-pre-FVdeploy-2026-01-29-Win64.exe"
#for %i in ("*.mzML") do ("F:\OpenMS-3.5.0-pre-FVdeploy-2026-01-29\bin\FLASHDeconv.exe"  -in %i -out %i.fdc.tsv ) 
#for %i in ("*.mzML") do start "%~nxi" "F:\OpenMS-3.5.0-pre-FVdeploy-2026-01-29\bin\FLASHDeconv.exe" -in "%i" -out "%i.fdc.tsv"
#cd centroided
#1. Default baseline
#"F:\OpenMS-3.5.0-pre-FVdeploy-2026-01-29\bin\FLASHDeconv.exe" -write_ini FLASHDeconv_default.ini 
#2. Focused subunit/search run
#SD:min_mass = 10000
#SD:max_mass = 100000
#SD:min_charge = 5
#SD:max_charge = 100
#SD:min_cos = 0.85
#SD:min_snr = 0.25
#ft:min_sample_rate = 0.1
#3. Intact/high-mass search run
#SD:min_mass = 50000
#SD:max_mass = 200000
#SD:min_charge = 20
#SD:max_charge = 150
#SD:min_cos = 0.85
#SD:min_snr = 0.25
#cd L:\promec\HF\Lars\2026\Solveig_Janus\test\redo
#for %i in ("*.mzML") do (
#    start "%~ni [Standard]" "F:\OpenMS-3.5.0-pre-FVdeploy-2026-01-29\bin\FLASHDeconv.exe" -in "%i" -out "%~ni.mzML.fdc.tsv" -out_spec1 "%~ni.ms1.spec.tsv" -out_annotated_mzml "%~ni.annotated.mzML"
#    start "%~ni [Subunit]" "F:\OpenMS-3.5.0-pre-FVdeploy-2026-01-29\bin\FLASHDeconv.exe" -in "%i" -out "%~ni.subunit.fdc.tsv" -out_spec1 "%~ni.subunit.ms1.spec.tsv" -out_annotated_mzml "%~ni.subunit.annotated.mzML" -ini "FLASHDeconv_subunit_10-100kDa.ini"
#    start "%~ni [Highmass]" "F:\OpenMS-3.5.0-pre-FVdeploy-2026-01-29\bin\FLASHDeconv.exe" -in "%i" -out "%~ni.highmass.fdc.tsv" -out_spec1 "%~ni.highmass.ms1.spec.tsv" -out_annotated_mzml "%~ni.highmass.annotated.mzML" -ini "FLASHDeconv_highmass_50-200kDa.ini"
#    start "%~ni [18-25kDa]" "F:\OpenMS-3.5.0-pre-FVdeploy-2026-01-29\bin\FLASHDeconv.exe" -in "%i" -out "%~ni.18-25kDa.fdc.tsv" -out_spec1 "%~ni.18-25kDa.ms1.spec.tsv" -out_annotated_mzml "%~ni.18-25kDa.annotated.mzML" -SD:min_mass 18000 -SD:max_mass 25000 -SD:min_charge 8 -SD:max_charge 40
#)
#setup####
#https://abibuilder.cs.uni-tuebingen.de/archive/openms/OpenMSInstaller/experimental/feature/FLASHDeconv/
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
if (length(args) != 1) {stop("\n\nNeeds full path of the directory containing REPORTS for example: c:/Users/animeshs/R/bin/Rscript.exe flashDeConvMZMS1.r \"L:/promec/HF/Lars/2023/IgG Mus Therese/mzML/deconv/\"", call.=FALSE)}
#dataFolder####
inpD <- args[1]
#inpD<-"L:/promec/HF/Lars/2026/Solveig_Janus/test/redo/"
#merge####
inpFL<-list.files(pattern="*mzML.fdc.tsv$",path=inpD,full.names=F,recursive=F)
outF=paste(inpD,"combine.intMZ1",sep = "/")
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
