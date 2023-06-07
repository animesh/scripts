inpD<-"C:/Users/animeshs/OneDrive/Desktop/OneDrive-2023-06-07/"
inpFL<-list.files(pattern="*.txt$",path=inpD,full.names=F,recursive=F)
dfMZ1<-0
sheets<-list()
library(writexl)
for(inpF in inpFL){
    print(inpF)
    data<-read.csv(paste0(inpD,inpF),sep="\t")
    sheets<-append(sheets,list(data))
    MZ1<-data$MZ1
    dfMZ1<-union(dfMZ1,MZ1)
    colnames(data)<-paste0(colnames(data),inpF)
    #hist(log2(as.numeric(data[,4])))
    data$MZ1<-MZ1
    assign(inpF,data)
}
summary(warnings())
summary(MZ1)
#sheets <- list(data,data) #assume sheet1 and sheet2 are data frames
write_xlsx(sheets, paste0(inpD,"combined.xlsx"))
