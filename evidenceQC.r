#Rscript proteinGroupsQC.r "L:/promec/TIMSTOF/LARS/2023/230310 ChunMei/combined/txt/evidence.txt"
#setup####
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpF <- args[1]
#inpD<-"L:/promec/TIMSTOF/LARS/2023/230310 ChunMei/combined/txt/evidence.txt"
data<-read.table(inpF,header = T,sep = "\t",quote = "")
jpeg("F1A1.jpg")
hist(data$Uncalibrated...Calibrated.m.z..ppm.,breaks=10,density = 200,main = "Uncalibrated...Calibrated.m.z..ppm.",xlab = "PPM",col = "skyblue",)
#hist(data$Mass.error..ppm.)
dev.off()
jpeg("F1A2.jpg")
d<-density(data$Uncalibrated...Calibrated.m.z..Da.)
plot(d,main = "Uncalibrated...Calibrated.m.z..Da.",xlab = "Dalton")
polygon(d, col="skyblue", border="black")
#hist(data$Mass.error..Da.)
dev.off()
dataSel<-data#[1:50000,]
jpeg("F2.jpg")
#hist(dataSel$Charge)
plot(dataSel$Length,dataSel$m.z,pch=19,col=factor(dataSel$Charge),main="Length vs m.z",xlab="Length",ylab="m.z")
legend("bottomright",legend=levels(factor(dataSel$Charge)),col=1:4,pch=19,title="Charge")
dev.off()
jpeg("F2A1.jpg")
#hist(dataSel$Charge)
hist(dataSel$Length,breaks=10,density = 200,main = "Length",xlab = "Length",col = "skyblue")
legend("bottomright",legend=levels(factor(dataSel$Charge)),col=1:4,pch=19,title="Charge")
dev.off()
jpeg("F2A2.jpg")
#hist(dataSel$Charge)
hist(dataSel$m.z,breaks=10,density = 200,main = "m.z",xlab = "m.z",col = "skyblue")
legend("bottomright",legend=levels(factor(dataSel$Charge)),col=1:4,pch=19,title="Charge")
dev.off()
jpeg("F3.jpg")
pie(table(dataSel$Missed.cleavages),main="Charge")
dev.off()
jpeg("F4.jpg")
pie(table(dataSel$Charge),main="Charge")
dev.off()
