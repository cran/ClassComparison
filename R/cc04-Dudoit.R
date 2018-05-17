# Copyright (C) Kevin R. Coombes, 2007-2012

# dudoit.ssc

setClass('Dudoit',
         contains = 'MultiTtest',
         slots = c(adjusted.p = 'numeric'))

Dudoit <- function(data, classes, nPerm=1000, verbose=TRUE) {
  if(is.logical(classes)) classes <- factor(classes)
  if(inherits(data, 'ExpressionSet')) {
    if(is.character(classes)) {
      classes <- as.factor(pData(data)[,classes])
    }
    data <- exprs(data)
  }
  zzt <- MultiTtest(data, classes)
  zzt@call <- match.call()
  tor <- rev(order(abs(zzt@t.statistics)))
  dudoit.data <- data[tor,]
  grounded <- abs(zzt@t.statistics[tor])
  num.gene <- nrow(data)
  num.sample <- length(classes)
  num.group1 <- sum(classes==levels(classes)[1])
  counter <- rep(0, num.gene)
  for (i in 1:nPerm) {
    if(verbose) cat(paste(i,'.', sep=''))
    fake <- rep(FALSE, num.sample)
    fake[sample(num.sample, num.group1)] <- TRUE
    dudoit.temp <- MultiTtest(dudoit.data, fake)
    dudoit.t <- abs(dudoit.temp@t.statistics)
    dudoit.u <- rep(dudoit.t[num.gene], num.gene)
    trigger <- sum(dudoit.t > dudoit.u)
    while(trigger > 0) {
      dudoit.t <- (dudoit.u + dudoit.t + abs(dudoit.u - dudoit.t))/2
      trigger <- sum(dudoit.t > dudoit.u)
      if (trigger > 0) {
        target <- (1:num.gene)[dudoit.t >dudoit.u][trigger]
        dudoit.u[1:target] <- dudoit.t[target]
      }
    }
    counter <- counter + (dudoit.u >= grounded)
  }
  if(verbose) cat('\n')
  adjusted.p <- counter/nPerm
  ox <- order(rev(order(abs(zzt@t.statistics))))
  new('Dudoit', zzt, adjusted.p=adjusted.p[ox])
}

setMethod('plot', signature('Dudoit', 'missing'), function(x, y,
                  xlab='T-Statistic', ylab='P-Value', ...) {
  or <- order(x@t.statistics)
  plot(x@t.statistics[or], x@adjusted.p[or], xlab=xlab, ylab=ylab, type='l', ...)
  points(x@t.statistics, x@adjusted.p)
  lines(x@t.statistics[or], x@p.values[or], pch='.', col=oompaColor$CENTRAL.LINE)
  invisible(x)
})

setMethod('cutoffSignificant', signature('Dudoit'),
          function(object, alpha, ...) {
            alpha
          })

setMethod('selectSignificant', signature('Dudoit'),
          function(object, alpha, ...) {
            object@adjusted.p < alpha
          })

setMethod('countSignificant', signature('Dudoit'),
          function(object, alpha, ...) {
            sum(selectSignificant(object, alpha))
          })

