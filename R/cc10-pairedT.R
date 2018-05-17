# Copyright (C) Kevin R. Coombes, 2007-2012

## paired t-tests, vectorized
## basic code for the paired t-test was contributed by Roland Bassett.

## class definition
setClass('MultiTtestPaired',
         contains = 'MultiTtest')

MultiTtestPaired <- function (data, classes, pairing)
{
  call <- match.call()
  if (is.logical(classes))
    classes <- factor(classes)
  if (inherits(data, "ExpressionSet")) {
    if (is.character(classes)) {
      classes <- as.factor(pData(data)[, classes])
    }
    data <- exprs(data)
  }
  t.statistics <- as.vector(matrixPairedT(data, classes, pairing))
  p.values <- sapply(t.statistics, function(tv, df) {
    2 * (1 - pt(abs(tv), df))
  }, length(unique(pairing)) - 1)
  new("MultiTtestPaired", t.statistics = t.statistics, p.values = p.values,
      groups = levels(classes), call = call)
}

setMethod('summary', signature(object='MultiTtestPaired'),
          function(object, ...) {
  cat('Results of a paired t-test\n')
  callNextMethod(...)
})

##########################################
## unequal variance t tests

## class definition
setClass('MultiTtestUnequal',
         contains ='MultiTtest', 
         slots = c(df='numeric'))

MultiTtestUnequal <- function (data, classes)
{
  call <- match.call()
  if (is.logical(classes))
    classes <- factor(classes)
  if (inherits(data, "ExpressionSet")) {
    if (is.character(classes)) {
      classes <- as.factor(pData(data)[, classes])
    }
    data <- exprs(data)
  }
  temp <- matrixUnequalT(data,classes)
  t.statistics <- as.vector(temp$tt)
  df <- as.vector(temp$df)
  p.values <- 2 * (1 - pt(abs(t.statistics), df))
  new("MultiTtestUnequal", t.statistics = t.statistics, p.values = p.values,
      groups = levels(classes), call = call, df=df)
}

setMethod('summary', signature(object='MultiTtestUnequal'),
          function(object, ...) {
  cat('Results of an unequal variance t-test\n')
  callNextMethod(...)
})

