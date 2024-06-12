#https://github.com/Noble-Lab/casanovo/releases/tag/v4.0.0
#casanovo sequence -o  230508_IRD_37TWTL.mztab desk/IRD/230508_IRD_37TWTL.mgf
#wget https://github.com/Noble-Lab/casanovo/releases/download/v4.0.0/casanovo_nontryptic.ckpt
#casanovo sequence -o  230508_IRD_37GWTL.mztab desk/IRD/230508_IRD_37GWTL.mgf --model casanovo_nontryptic.ckpt
#https://casanovo.readthedocs.io/en/latest/getting_started.html
#conda create --name casanovo_env python=3.10
#conda activate casanovo_env
#pip install casanovo
#casanovo configure
#wget https://raw.githubusercontent.com/Noble-Lab/casanovo/main/sample_data/sample_preprocessed_spectra.mgf
#casanovo sequence sample_preprocessed_spectra.mgf
#casanovo evaluate sample_preprocessed_spectra.mgf
#casanovo train --validation_peak_path sample_preprocessed_spectra.mgf sample_preprocessed_spectra.mgf
#casanovo sequence --model casanovo_nontryptic.ckpt  -o t.mztab 220825_PEPTID6_SOLVEIG.mgf
#rsync -Parv   login.nird-lmd.sigma2.no:PD/HF/Lars/2022/November/solveig*ird/PDv2p5try/TryP/*.mzML .
#casanovo sequence -o 231006_IRD_31_D7_T3_ddaPD.mztab IRD/231006_IRD_31_D7_T3_ddaPD.mzML
#for i in IRD/*.mzML ; do echo $i; casanovo sequence -o $i.mztab $i ; done
#BiocManager::install("MSnbase") #https://lgatto.github.io/MSnbase/articles/v01-MSnbase-demo.html#sec:id
#data<-MSnbase::readMzTabData("F:/OneDrive - NTNU/Desktop/IRD/231006_IRD_9_D22_T3_ddaPD.mzML.mztab")
summary(warnings())
#df = read.csv("F:/OneDrive - NTNU/Desktop/IRD/231006_IRD_9_D22_T3_ddaPD.mzML.mztab", skip = 61, header = T,sep="\t")
#hist(as.numeric(df$calc_mass_to_charge))
#hist(as.numeric(df$search_engine_score.1))
inpD<-"F:/OneDrive - NTNU/Desktop/IRD/"
inpFL<-list.files(pattern="*mztab$",path=inpD,full.names=F,recursive=F)
inpF<-inpFL[1]
data<-read.csv(paste0(inpD,inpF),sep="\t",skip=61,header=T)
hist(as.numeric(data$search_engine_score.1.))
inpF<-inpFL[2]
data<-read.csv(paste0(inpD,inpF),sep="\t",skip=61,header=T)
hist(as.numeric(data$search_engine_score.1.))
inpF<-inpFL[28]
data<-read.csv(paste0(inpD,inpF),sep="\t",skip=61,header=T)
hist(as.numeric(data$search_engine_score.1.))
inpFL<-inpFL[-c(1,2,28)]
dfMZ1<-c()
for(inpF in inpFL){
  #inpF<-inpFL[1]
  print(inpF)
  data<-read.csv(paste0(inpD,inpF),sep="\t",skip=61,header=T)
  data<-data[data$search_engine_score.1>0.95,]
  MZ1<-paste0("pep_",data$sequence)
  Score<-data$search_engine_score.1
  dfMZ1<-union(dfMZ1,MZ1)
  dataScore<-data.frame(Score)
  colnames(dataScore)<-paste0(colnames(dataScore),inpF)
  dataScore$MZ1<-MZ1
  #hist(as.numeric(dataScore$Score))
  assign(paste0("df",inpF),dataScore)
}
summary(warnings())
data<-data.frame(MZ1=dfMZ1)
#data<-merge(data,`210408_EL500_SAX_urt3.raw.intensityThreshold1000.errTolDecimalPlace3.MZ1R.csv`, by="MZ1",all=T)
#plot(data$MZ1,data$MZ1210408_EL500_SAX_urt3.raw.intensityThreshold1000.errTolDecimalPlace3.MZ1R.csv)
for (obj in inpFL) {
  print(obj)
  get(paste0("df",obj))
  data<-merge(data,get(paste0("df",obj)),by="MZ1",all=T)
}
#hist(data$MZ1)
plot(data$MZ1)
data<-data[order(rowSums(data),decreasing=T),]
write.csv(data,paste0(inpD,inpF,".sort.combined.csv"))
data1000<-data[c(1:1000),]
#hist(data1000$MZ1)
plot(data1000$MZ1)
write.csv(data1000,paste0(inpD,inpF,".combined.top1000.csv"))
