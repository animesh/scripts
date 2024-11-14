#Rscript evidenceQC.r "L:/promec/USERS/Mei/2016-05_PancreaticCancer/QE/evidence.txt" "Tumor_"
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpF <- args[1]
#inpF<-"L:/promec/USERS/Mei/2016-05_PancreaticCancer/QE/evidence.txt"
selection <- args[2]
#selection<-"Tumor_"
data<-read.table(inpF,header = T,sep = "\t",quote = "")
data<-data[grep(selection,data$Raw.file),]
jpeg(paste0(inpF,selection,"Uncalibrated...Calibrated.m.z..ppm.jpg"))
hist(data$Uncalibrated...Calibrated.m.z..ppm.,breaks=10,density = 200,main = "Uncalibrated...Calibrated.m.z..ppm.",xlab = "PPM",col = "skyblue",)
#hist(data$Mass.error..ppm.)
dev.off()
jpeg(paste0(inpF,selection,"Uncalibrated...Calibrated.m.z..ppm.density.jpg"))
d<-density(data$Uncalibrated...Calibrated.m.z..Da.,na.rm = T)
plot(d,main = "Uncalibrated...Calibrated.m.z..Da.",xlab = "Dalton")
polygon(d, col="skyblue", border="black")
#hist(data$Mass.error..Da.)
dev.off()
dataSel<-data#[1:50000,]
jpeg(paste0(inpF,selection,"Charge.jpg"))
#hist(dataSel$Charge)
plot(dataSel$Length,dataSel$m.z,pch=19,col=factor(dataSel$Charge),main="Length vs m.z",xlab="Length",ylab="m.z")
legend("bottomright",legend=levels(factor(dataSel$Charge)),col=1:4,pch=19,title="Charge")
dev.off()
jpeg(paste0(inpF,selection,"Missed.cleavages.jpg"))
pie(table(dataSel$Missed.cleavages),main="Missed cleavages")
dev.off()
