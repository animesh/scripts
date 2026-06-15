library(naniar)
library(ggplot2)
data <- read.csv("Z:/Download/clinical_data-20260608T085237Z-3-001/clinical_data/heart_disease-switzerland.csv")
View(data)
data[data==-9] <- NA
gg_miss_case(data)
gg_miss_var(data)
miss_var_summary(data)
ggplot(data = data,aes(x = trestbps,y = num)) +   geom_miss_point()
miss_case_cumsum(data)
#plot patern of missingness interaction
gg_miss_upset(data)

mcar_test(data)

mcar_test(data, response ="trestbps", explanatory = "num")

dataTib <- naniar::nabular(data)
naniar::n_miss(dataTib)

impute <- function(x, what=c("median", "mean")){

    what <- match.arg(what)
    
    if(what == "median"){
        retval <-
            apply(x, 2,
                  function(z) {z[is.na(z)] <- median(z, na.rm=TRUE); z})
    }
    else if(what == "mean"){
        retval <-
            apply(x, 2,
                  function(z) {z[is.na(z)] <- mean(z, na.rm=TRUE); z})
    }
    else{
        stop("`what' invalid")
    }
    retval
}
