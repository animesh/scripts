#Rscript evidenceQC.r "L:/promec/TIMSTOF/LARS/2023/230815 mathilde/evidence.txt"
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpF <- args[1]
#inpF<-"L:/promec/TIMSTOF/LARS/2023/230815 mathilde/evidence.txt"
data<-read.table(inpF,header = T,sep = "\t",quote = "")
jpeg(paste0(inpF,"Uncalibrated...Calibrated.m.z..ppm.jpg"))
hist(data$Uncalibrated...Calibrated.m.z..ppm.,breaks=10,density = 200,main = "Uncalibrated...Calibrated.m.z..ppm.",xlab = "PPM",col = "skyblue",)
#hist(data$Mass.error..ppm.)
dev.off()
jpeg(paste0(inpF,"Uncalibrated...Calibrated.m.z..ppm.density.jpg"))
d<-density(data$Uncalibrated...Calibrated.m.z..Da.)
plot(d,main = "Uncalibrated...Calibrated.m.z..Da.",xlab = "Dalton")
polygon(d, col="skyblue", border="black")
#hist(data$Mass.error..Da.)
dev.off()
dataSel<-data#[1:50000,]
jpeg(paste0(inpF,"Charge.jpg"))
#hist(dataSel$Charge)
plot(dataSel$Length,dataSel$m.z,pch=19,col=factor(dataSel$Charge),main="Length vs m.z",xlab="Length",ylab="m.z")
legend("bottomright",legend=levels(factor(dataSel$Charge)),col=1:4,pch=19,title="Charge")
dev.off()
jpeg(paste0(inpF,"Missed.cleavages.jpg"))
pie(table(dataSel$Missed.cleavages),main="Missed cleavages")
dev.off()
