NEWBLER = read.table('NEWBLERAn.fgp')
MIRA = read.table('MIRAAn.fgp')
PHRAP = read.table('PHRAPAn.fgp')
CAP3 = read.table('CAP3An.fgp')

par(mfrow = c(2,2))

plot(MIRA, xlab= "Left-End", ylab = "Right-End", col="cyan", border="pink", main = "MIRA")
plot(PHRAP, xlab= "Left-End", ylab = "Right-End", col="magenta", border="pink", main = "PHRAP")
plot(CAP3, xlab= "Left-End", ylab = "Right-End",  col="orange", border="pink", main = "CAP3" )
plot(NEWBLER, xlab= "Left-End", ylab = "Right-End",  col="grey", border="pink", main = "NEWBLER")


plot(MIRA, xlab= "Left-End", ylab = "Right-End", col="cyan", border="pink", main = "MIRA", type="h")
plot(PHRAP, xlab= "Left-End", ylab = "Right-End", col="magenta", border="pink", main = "PHRAP", type="h")
plot(CAP3, xlab= "Left-End", ylab = "Right-End",  col="orange", border="pink", main = "CAP3" , type="h")
plot(NEWBLER, xlab= "Left-End", ylab = "Right-End",  col="grey", border="pink", main = "NEWBLER", type="h")

