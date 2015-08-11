naiveBayes <- function(x, ...)
  UseMethod("naiveBayes")

naiveBayes.default <- function(x, y, laplace = 0, ...) {
  call <- match.call()
  Yname <- deparse(substitute(y))

  ## estimation-function
  est <- function(var)
    if (is.numeric(var)) {
      cbind(tapply(var, y, mean, na.rm = TRUE),
            tapply(var, y, sd, na.rm = TRUE))
    } else {
      tab <- table(y, var)
      (tab + laplace) / (rowSums(tab) + laplace * nlevels(var))
    }
  
  ## create tables
  apriori <- table(y)
  tables <- lapply(x, est)
  
  ## fix dimname names
  for (i in 1:length(tables))
    names(dimnames(tables[[i]])) <- c(Yname, colnames(x)[i])
  names(dimnames(apriori)) <- Yname

  structure(list(apriori = apriori,
                 tables = tables,
                 levels = levels(y),
                 call   = call
                 ),
            
            class = "naiveBayes"
            )
}

naiveBayes.formula <- function(formula, data, laplace = 0, ...,
                               subset, na.action = na.pass) {
  call <- match.call()
  Yname <- as.character(formula[[2]])

  if (is.data.frame(data)) {
    ## handle formula
    m <- match.call(expand = FALSE)
    m$... <- NULL
    m$laplace = NULL
    m$na.action <- na.action
    m[[1]] <- as.name("model.frame")
    m <- eval(m, parent.frame())
    Terms <- attr(m, "terms")
    if (any(attr(Terms, "order") > 1)) 
      stop("naiveBayes cannot handle interaction terms")
    Y <- model.extract(m, "response")
    X <- m[,-attr(Terms, "response")]

    return(naiveBayes(X, Y, laplace = laplace, ...))
  } else if (is.array(data)) {
    ## Find Class dimension
    Yind <- which(names(dimnames(data)) == Yname)

    ## Create Variable index
    deps <- strsplit(as.character(formula)[3], ".[+].")[[1]]
    if (length(deps) == 1 && deps == ".")
      deps <- names(dimnames(data))[-Yind]
    Vind <- which(names(dimnames(data)) %in% deps)
    
    ## create tables
    apriori <- margin.table(data, Yind)
    tables <- lapply(Vind,
                     function(i) (margin.table(data, c(Yind, i)) + laplace) / (as.numeric(apriori) + laplace * dim(data)[i]))

    structure(list(apriori = apriori,
                   tables = tables,
                   levels = names(apriori),
                   call   = call
                   ),
              
              class = "naiveBayes"
              )
  } else stop("naiveBayes formula interface handles data frames or arrays only")

}


print.naiveBayes <- function(x, ...) {
  cat("\nNaive Bayes Classifier for Discrete Predictors\n\n")
  cat("Call:\n")
  print(x$call)
  cat("\nA-priori probabilities:\n")
  print(x$apriori / sum(x$apriori))
  
  cat("\nConditional probabilities:\n")
  for (i in x$tables) {print(i); cat("\n")}
    
}

predict.naiveBayes <- function(object,
                               newdata,
                               type = c("class", "raw"),
                               threshold = 0.001,
                               ...) {
  type <- match.arg(type)
  nattribs <- ncol(newdata)
  isnumeric <- sapply(newdata, is.numeric)
  newdata <- data.matrix(newdata)
  L <- sapply(1:nrow(newdata), function(i) {
    ndata <- newdata[i,]
    L <- log(object$apriori) + 
      apply(log(sapply(1:nattribs, function(v) {
        nd <- ndata[v]
        if(is.na(nd))
          rep(1, length(object$apriori))
        else {
          prob <- if (isnumeric[v]) {
            msd <- object$tables[[v]]
            dnorm(nd, msd[,1], msd[,2])
          } else
            object$tables[[v]][,nd]
          prob[prob == 0] <- threshold
          prob
        }
      })), 1, sum)
    if (type == "class")
      L
    else {
      L <- exp(L)
      L / sum(L)
    }
  })
  if (type == "class")
    factor(object$levels[apply(L, 2, which.max)], levels = object$levels)
  else
    t(L)
}
