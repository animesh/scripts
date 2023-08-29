#F:\R-4.3.1\bin\Rscript.exe uniprotIDmap.r
#setup####
#install.packages(c("readxl","writexl","BiocManager"), dependencies=TRUE)
#BiocManager::install("UniProt.ws")#http://bioconductor.org/packages/release/bioc/vignettes/UniProt.ws/inst/doc/UniProt.ws.html
#UniprotR####
library("UniProt.ws")
up <- UniProt.ws(taxId=9606)
#data####
#inpF<-"L:/promec/TIMSTOF/LARS/2023/230217_Caroline/combined/txt/proteinGroups.txtLFQ.intensity.110Omego6Cntr6h00.050.5InfBiotTestBH.xlsx"
#data<-readxl::read_excel(inpF)
#upID<-data.frame(Uniprot=unique(unlist(strsplit(paste(sapply(strsplit(data$RowGeneUniProtScorePeps, ";;",fixed=T), "[", 3)), ";"))))
#upIDremc=data.frame(Uniprot=upID[upID!=""])
#sum(upIDremc=="")
#upData<-mapUniProt(from="UniProtKB_AC-ID",to='Ensembl',query=upIDremc$Uniprot)
#writexl::write_xlsx(upData,paste0(dirname(inpF),"/EnsemblID.xlsx"))
#write.csv(upData,paste0(dirname(inpF),"/EnsemblID.csv"))
inpD<-"L:/promec/TIMSTOF/LARS/2023/230217_Caroline/combined/txt"
inpFL<-list.files(pattern="h00.050.5InfBiotTestBH.xlsx$",path=inpD,full.names=T,recursive=F)
for(inpF in inpFL){
  print(inpF)
  data<-readxl::read_excel(inpF)
  print(summary(data))
  print(dim(data))
  print(colnames(data))
  upData<-mapUniProt(from="UniProtKB_AC-ID",to='Ensembl',query=data$Uniprot)
  writexl::write_xlsx(upData,paste0(inpF,"EnsemblID.xlsx"))
  write.csv(upData,paste0(inpF,"EnsemblID.csv"))
  dataMap<-merge(data,upData,by.y="From",by.x="Uniprot",all.x=TRUE)
  writexl::write_xlsx(dataMap,paste0(inpF,"EnsemblIDmap.xlsx"))
  write.csv(dataMap,paste0(inpF,"EnsemblIDmap.csv"))
}
