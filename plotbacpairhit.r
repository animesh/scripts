stickle=read.table('bacsticklebac.rmp.txt');
medaka=read.table('bacmedaka.rmp.txt');
branchiostoma=read.table('bacbranchiostoma.rmp.txt');
elephantshark=read.table('bacelephantshark.rmp.txt');
fugu=read.table('bacfugu.rmp.txt');
tetraodon=read.table('bactetraodon.rmp.txt');
zebra=read.table('baczf.rmp.txt');
u150k=c(1,sum(stickle$V19<150000&stickle$V19!=0));
u150k=rbind(u150k,c(2,sum(medaka$V19<150000&medaka$V19!=0)))
u150k=rbind(u150k,c(3,sum(branchiostoma$V19<150000&branchiostoma$V19!=0)))
u150k=rbind(u150k,c(4,sum(elephantshark$V19<150000&elephantshark$V19!=0)))
u150k=rbind(u150k,c(5,sum(fugu$V19<150000&fugu$V19!=0)))
u150k=rbind(u150k,c(6,sum(tetraodon$V19<150000&tetraodon$V19!=0)))
u150k=rbind(u150k,c(7,sum(zebra$V19<150000&zebra$V19!=0)))


allph=c(1,dim(t(stickle[,1])));
allph=rbind(allph,c(2,dim(t(medaka[,1]))));
allph=rbind(allph,c(3,dim(t(branchiostoma[,1]))));
allph=rbind(allph,c(4,dim(t(elephantshark[,1]))));
allph=rbind(allph,c(5,dim(t(fugu[,1]))));
allph=rbind(allph,c(6,dim(t(tetraodon[,1]))));
allph=rbind(allph,c(7,dim(t(zebra[,1]))));

avgph=c(1,stickle[dim(t(stickle[,1])),20]);
avgph=rbind(avgph,c(2,medaka[dim(t(medaka[,1])),20]));
avgph=rbind(avgph,c(3,branchiostoma[dim(t(branchiostoma[,1])),20]));
avgph=rbind(avgph,c(4,elephantshark[dim(t(elephantshark[,1])),20]));
avgph=rbind(avgph,c(5,fugu[dim(t(fugu[,1])),20]));
avgph=rbind(avgph,c(6,tetraodon[dim(t(tetraodon[,1])),20]));
avgph=rbind(avgph,c(7,zebra[dim(t(zebra[,1])),20]));



pdf("bac2fish.pdf");

plot(allph[,1],allph[,3],xlab="stickle medaka branchiostoma elephantshark fugu tetraodon zebra", ylab="total#hits", main="Number of hits", col="orange");
plot(u150k,xlab="stickle medaka branchiostoma elephantshark fugu tetraodon zebra", ylab="#hits", main="Number of same sequence hits under 150k", col="red");
plot(avgph[,1],avgph[,3],xlab="stickle medaka branchiostoma elephantshark fugu tetraodon zebra", ylab="avg dist b/w hits", main="Average distance between paired hits", col="brown");


plot(stickle$V6,stickle$V8,xlab="Forward", ylab="Reverse", main="stickle Cod paired BAC hits Alignment Length scatter", col="green")
plot(medaka$V6,medaka$V8,xlab="Forward", ylab="Reverse", main="medaka Cod paired BAC hits Alignment Length scatter", col="green")
plot(branchiostoma$V6,branchiostoma$V8,xlab="Forward", ylab="Reverse", main="branchiostoma Cod paired BAC hits Alignment Length scatter", col="green")
plot(elephantshark$V6,elephantshark$V8,xlab="Forward", ylab="Reverse", main="elephantshark Cod paired BAC hits Alignment Length scatter", col="green")
plot(fugu$V6,fugu$V8,xlab="Forward", ylab="Reverse", main="fugu Cod paired BAC hits Alignment Length scatter", col="green")
plot(tetraodon$V6,tetraodon$V8,xlab="Forward", ylab="Reverse", main="tetraodon Cod paired BAC hits Alignment Length scatter", col="green")
plot(zebra$V6,zebra$V8,xlab="Forward", ylab="Reverse", main="zebra Cod paired BAC hits Alignment Length scatter", col="green")


plot(stickle$V15,stickle$V17,xlab="Forward", ylab="Reverse", main="stickle sequence to Cod paired BAC hits scatter", col="blue")
plot(medaka$V15,medaka$V17,xlab="Forward", ylab="Reverse", main="medaka sequence to Cod paired BAC hits scatter", col="blue")
plot(branchiostoma$V15,branchiostoma$V17,xlab="Forward", ylab="Reverse", main="branchiostoma sequence to Cod paired BAC hits scatter", col="blue")
plot(elephantshark$V15,elephantshark$V17,xlab="Forward", ylab="Reverse", main="elephantshark sequence to Cod paired BAC hits scatter", col="blue")
plot(fugu$V15,fugu$V17,xlab="Forward", ylab="Reverse", main="fugu sequence to Cod paired BAC hits scatter", col="blue")
plot(tetraodon$V15,tetraodon$V17,xlab="Forward", ylab="Reverse", main="tetraodon sequence to Cod paired BAC hits scatter", col="blue")
plot(zebra$V15,zebra$V17,xlab="Forward", ylab="Reverse", main="zebra sequence to Cod paired BAC hits scatter", col="blue")



q(save="no")

