superhist <- function(x, filename = "super_histograms.pdf",
                     dev = "pdf", title = "Superimposed Histograms") {
  junk = NULL
  grouping = NULL
  for(i in 1:length(x)) {
    junk = c(junk,x[[i]])
    grouping <- c(grouping, rep(i,length(x[[i]]))) }
  grouping <- factor(grouping)
  n.gr <- length(table(grouping))
  xr <- range(junk)
  histL <- tapply(junk, grouping, hist, plot = FALSE)
  maxC <- max(sapply(lapply(histL, "[[", "counts"), max))
  if(dev == "pdf") { pdf(filename, version = "1.4") } else{}
  if((TC <- transparent.cols <- .Device %in% c("pdf", "png"))) {
    cols <- hcl(h = seq(30, by=360 / n.gr, length = n.gr), l = 65, alpha = 0.5) } else {
      h.den <- c(10, 15, 20)
      h.ang <- c(45, 15, -30) }
  if(TC) {
    plot(histL[[1]], xlim = xr, ylim= c(0, maxC), col = cols[1], xlab = "x", main = title) } else { plot(histL[[1]], xlim = xr, ylim= c(0, maxC), density = h.den[1], angle = h.ang[1], xlab = "x") }
  if(!transparent.cols) {
      for(j in 2:n.gr) plot(histL[[j]], add = TRUE, density = h.den[j], angle = h.ang[j]) } else {
        for(j in 2:n.gr) plot(histL[[j]], add = TRUE, col = cols[j]) }
  invisible()
  if( dev == "pdf") {
    dev.off() } }

t.test((x<-rnorm(1000)),(y<-rnorm(1000)))
l1 = list(x,y)
superhist(l1)
