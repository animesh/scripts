resdataap <- read.table("ap.txt")
resdataapip <- read.table("apip.txt")
resdatafl <- read.table("fl.txt")
resdata <- read.table("data.txt")
resconc <- read.table("concval.txt")



t.test(resdataap$Ap,resdatafl$Fl)
t.test(resdataapip$Ap_Ip,resdatafl$Fl)


        Welch Two Sample t-test

data:  resdataap$Ap and resdatafl$Fl
t = -0.8866, df = 5.877, p-value = 0.4101
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
 -13.208386   6.208386
sample estimates:
mean of x mean of y
     12.0      15.5

> t.test(resdataapip$Ap_Ip,resdatafl$Fl)

        Welch Two Sample t-test

data:  resdataapip$Ap_Ip and resdatafl$Fl
t = -0.5382, df = 5.998, p-value = 0.6098
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
 -12.48109   7.98109
sample estimates:
mean of x mean of y
    13.25     15.50

