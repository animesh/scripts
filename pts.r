## D:\\animesh\\booksNpapers\\lang\\statistics\\time_series\\timeseries_plots
## read cocoa price file, note that we use 
## comma as decimal seperator and 
## semicolon as field seperator.
a<-read.csv2("cocoa.csv")

## chop the year and avg columns
a<-a[,2:13]

## write table to vector b row by row.
## as.numeric is important here
b<-vector()
for(i in 1:dim(a)[1])
    b<-c(b,as.numeric(a[i,]))

## make time series
b<-ts(b, frequency=12, start=1971)

## read oil prices and basically do the same
m<-read.csv2("oil.csv")
m<-ts(m[,3],frequency=12,start=1974)

## price of 1.1.1974 price shall be set to 1
m<-m/m[1]

## plot nominal cocoa time line
## if you do not run R under win use x11 instead of wingraph
win.graph(5,2)
par(cex=.5)
plot(b, ylab="Price per lb cocoa in US Cent", 
        xlab="Year", 
        main="Monthly Prices for Cocoa")

## plot nominal cocoa time line and add a green trend line
win.graph(5,2)
par(cex=.5)
plot(b, ylab="Price per lb cocoa in US Cent", 
        xlab="Year", 
        main="Monthly Prices for Cocoa")
b1<-filter(b, filter=rep(1/50,50))
lines(b1, col=3)

## set the 37th value (1.1.1974) to 1 as well
b<-b/b[37]

## plot both timelines
win.graph(6,4)
par(cex=.7)
plot(m, col=2, ylab="Price per 'lb cocoa'/'barrel oil' relative to 1.1.1974", 
               xlab="Year", 
               main="Monthly Prices for Crude Oil and Cocoa", 
               sub="prices are set to 1 at the 1.1.1974 to maintain trend comparability")
lines(b, col=3)
legend(1975, 6, c("Crude Oil","Cocoa"), fill=2:3)

##don't leave footsteps
rm(a,b,b1,m)



