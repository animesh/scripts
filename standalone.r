# You can run this simple R program directly from the R console, or
# load it into STATISTICA to run it and retrieve results to a report

x <- rnorm(100)           # 100 random numbers from a normal(0,1) distribution
y <- exp(x) + rnorm(100)  # an exponential function with error
result <- lm(y ~ x)       # regress x on y and store the results
summary(result)           # print the regression results
plot(x,y)                 # pretty obvious what this does
abline(result)            # add the regression line to the plot
lines(lowess(x,y), col=2) # add a nonparametric regression line (a smoother)
hist(result$residuals)    # histogram of the residuals from the regression
