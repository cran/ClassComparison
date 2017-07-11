# Copyright (C) Kevin R. Coombes, 2007-2016

setClass('MultiTtest',
         representation(t.statistics='numeric',
                        p.values='numeric',
                        df='numeric',
                        groups='character',
                        call='call'))

MultiTtest <- function(data, classes, na.rm=TRUE) {
  call <- match.call()
  if(is.logical(classes)) classes <- factor(classes)
  if(inherits(data, 'ExpressionSet')) {
    if(is.character(classes)) {
      classes <- as.factor(pData(data)[,classes])
    }
    data <- exprs(data)
  }
  t.statistics <- as.vector(matrixT(data, classes, na.rm=na.rm))
  df <- apply(data, 1, function(x) sum(!is.na(x))-2)
#  p.values <- sapply(t.statistics, function(tv, df){
#    2*(1-pt(abs(tv), df))
#  }, length(classes)-2)
  p.values <- 2*(1-pt(abs(t.statistics), df))
  new('MultiTtest',
      t.statistics=t.statistics,
      p.values=p.values,
      df=df,
      groups=levels(classes),
      call=call)
}

setMethod('summary', signature(object='MultiTtest'),
          function(object, ...) {
  cat(paste('Row-by-row two-sample t-tests with',
            length(object@t.statistics), 'rows\n'))
  cat(paste('Positive sign indicates an increase in class:',
            object@groups[1],'\n\n'))
  cat(paste('Call:', as.character(list(object@call)),'\n\nT-statistics:\n'))
  print(summary(object@t.statistics))
  cat('\nP-values:\n')
  summary(object@p.values)
})

setMethod('hist', signature(x='MultiTtest'),
          function(x, xlab='T Statistics', main=NULL, ...) {
  hist(x@t.statistics, xlab=xlab, main=main, ...)
})

setMethod('plot', signature('MultiTtest', 'missing'),
          function(x, y, ylab='T Statistics', ...) {
  plot(x@t.statistics, ylab=ylab, ...)
})

setMethod('plot', signature('MultiTtest', 'ANY'),
          function(x, y,
                   xlab='T Statistics',
                   ylab=deparse(substitute(y)), ...) {
  plot(x@t.statistics, y, xlab=xlab, ylab=ylab, ...)
})

setMethod("as.data.frame", signature(x="MultiTtest"),
          function (x, row.names=NULL, optional=FALSE, ...) {
  data.frame(Tstats=x@t.statistics,
             Pvalues=x@p.values,
             DF=x@df)
})

