
Uses("stats") #' ensures that a library (and its dependents) are installed and loaded

ActiveDataSet #' requires an active dataset in STATISTICA

RouteOutput(ActiveDataSet)

RouteOutput(Spreadsheet("adstudy")) #' defaults to STATISTICA Example Datasets

str(Spreadsheet("adstudy")) #' display structure of the data frame

RouteOutput(WorldPhones, "Number of Telephones Worldwide") #' built-in R dataset

comments <- matrix(c("Some comments", "and more comments..."), byrow = TRUE)
RouteOutput(comments, "Comments Section")
