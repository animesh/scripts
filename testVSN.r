#"c:\Program Files\R\R-4.5.2\bin\Rscript.exe" diffExprTestCor.r "L:\promec\TIMSTOF\LARS\2026\260518_Sonali\DIANNv2P2.63.260612_140833.64.highacc\report.pg_matrix.tsv" "L:\promec\TIMSTOF\LARS\2026\260518_Sonali\DIANNv2P2.63.260612_140833.64.highacc\Groups.txt" "F..promec.TIMSTOF.LARS.2026.260518_Sonali.260518_Sonali_" ".d" "log2LFQ" "Rem20" "fertilisation_percent"
#"c:\Program Files\R\R-4.5.2\bin\Rscript.exe" diffExprTestCor.r "L:\promec\TIMSTOF\LARS\2026\260518_Sonali\DIANNv2P2.63.260612_140833.64.highacc\report.pg_matrix.tsv" "L:\promec\TIMSTOF\LARS\2026\260518_Sonali\DIANNv2P2.63.260612_140833.64.highacc\Groups.txt" "F..promec.TIMSTOF.LARS.2026.260518_Sonali.260518_Sonali_" ".d" "LFQvsn" "Rem20" "fertilisation_percent"
## Does VSN systematically increase Pearson correlation?

library(vsn)

set.seed(123)


## Parameters


n.proteins <- 5000
n.samples  <- 20

fert <- seq(60,100,length.out=n.samples)


## Simulate proteins


simulate_dataset <- function(){
  
  ## true log2 abundance
  
  true.log2 <-
    matrix(
      rnorm(
        n.proteins*n.samples,
        mean=15,
        sd=2),
      nrow=n.proteins)
  
  ## biological effect
  
  beta <- rnorm(
    n.proteins,
    mean=0,
    sd=0.04)
  
  fert.scaled <-
    scale(fert)
  
  true.log2 <-
    true.log2 +
    beta %*% t(fert.scaled)
  

  ## convert to raw intensity

  
  raw <- 2^true.log2
  

  ## multiplicative noise

  
  raw <-
    raw *
    matrix(
      rlnorm(
        length(raw),
        meanlog=0,
        sdlog=0.20),
      nrow=n.proteins)
  

  ## additive noise

  
  raw <-
    raw +
    matrix(
      rnorm(
        length(raw),
        sd=300),
      nrow=n.proteins)
  

  ## heteroscedastic noise

  
  raw <-
    raw +
    matrix(
      rnorm(length(raw)),
      nrow=n.proteins) *
    raw^0.6
  
  raw[raw<1] <- 1
  
  raw
  
}


## simulate


raw <- simulate_dataset()
raw[is.nan(raw)] <- 1
summary(raw)


## log2


log2.data <- log2(raw)
hist(log2.data,breaks=100,col="grey",main="log2 intensity distribution")


## VSN

vsn.data <- vsn::justvsn(as.matrix(raw))


## correlations


cor.log2 <-
  apply(
    log2.data,
    1,
    function(x)
      cor(x,fert))

cor.vsn <-
  apply(
    vsn.data,
    1,
    function(x)
      cor(x,fert))

delta <- cor.vsn-cor.log2


## summaries


cat("\n")

cat("Mean delta :",mean(delta),"\n")
cat("Median     :",median(delta),"\n")
cat("Positive   :",mean(delta>0),"\n")


## histogram


hist(
  delta,
  breaks=100,
  col="grey",
  main="VSN - log2 correlation difference",
  xlab="Delta correlation")

abline(
  v=mean(delta),
  col="red",
  lwd=2)


## scatter


plot(
  cor.log2,
  cor.vsn,
  pch=16,
  cex=.4,
  xlab="log2 correlation",
  ylab="VSN correlation")

abline(
  0,
  1,
  col="red",
  lwd=2)


## intensity vs delta


plot(
  rowMeans(log2.data),
  delta,
  pch=16,
  cex=.4,
  xlab="Mean log2 intensity",
  ylab="Correlation difference")


## Repeat many simulations


N <- 100

summary.df <-
  data.frame(
    mean=rep(NA,N),
    median=rep(NA,N),
    positive=rep(NA,N))

for(i in 1:N){
  
  raw <- simulate_dataset()
  raw[is.nan(raw)] <- 1
  summary(raw)
  
  
  log2.data <- log2(raw)
  
  fit <- vsn2(raw)
  
  vsn.data <- predict(fit,raw)
  
  cor.log2 <-
    apply(
      log2.data,
      1,
      function(x)
        cor(x,fert))
  
  cor.vsn <-
    apply(
      vsn.data,
      1,
      function(x)
        cor(x,fert))
  
  delta <- cor.vsn-cor.log2
  
  summary.df$mean[i] <- mean(delta)
  summary.df$median[i] <- median(delta)
  summary.df$positive[i] <- mean(delta>0)
  
}

cat("\n=========================\n")

cat("Across",N,"simulations\n\n")

print(summary(summary.df))

hist(
  summary.df$median,
  breaks=20,
  main="Median delta across simulations",
  xlab="Median(VSN-log2)")
