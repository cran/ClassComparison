# Copyright (C) Kevin R. Coombes, 2007-2012

# twoGroupStats.R

setClass('TwoGroupStats',
         representation(mean1 = 'numeric',
                        mean2 = 'numeric',
                        overallMean = 'numeric',
                        var1 = 'numeric',
                        var2 = 'numeric',
                        overallVar = 'numeric',
                        pooledVar = 'numeric',
                        n1 = 'numeric',
                        n2 = 'numeric',
                        name1='character',
                        name2='character',
                        name='character'))

TwoGroupStats <- function(data, classes, name='comparison', name1='A', name2='B') {
  if (is.logical(classes)) classes <- factor(classes)
  if(inherits(data, 'ExpressionSet')) {
    if(is.character(classes)) {
      classes <- as.factor(pData(data)[,classes])
    }
    data <- exprs(data)
  }
  type1 <- classes == levels(classes)[1]
  type2 <- !type1
  n1 <- sum(type1)
  n2 <- sum(type2)
  mean1 <- matrixMean(data[, type1])
  mean2 <- matrixMean(data[, type2])
  overallMean <- matrixMean(data)
  var1 <- matrixVar(data[,type1], mean1)
  var2 <- matrixVar(data[,type2], mean2)
  overallVar <- matrixVar(data, overallMean)
  pooledVar <- as.vector((var1*(n1-1) + var2*(n2-1))/(n1+n2-2))
  new('TwoGroupStats',
      mean1=as.vector(mean1), mean2=as.vector(mean2),
      var1=as.vector(var1), var2=as.vector(var2),
      overallMean=as.vector(overallMean), overallVar=as.vector(overallVar),
      pooledVar=pooledVar, n1=n1, n2=n2, name1=name1, name2=name2)
}

setMethod('as.data.frame', signature(x='TwoGroupStats'),
          function(x, row.names=NULL, optional=FALSE) {
            data.frame(mean1=x@mean1,
                       mean2=x@mean2,
                       overallMean=x@overallMean,
                       var1=x@var1,
                       var2=x@var2,
                       overallVar=x@overallVar,
                       pooledVar=x@pooledVar)
          })


setMethod('summary', signature(object='TwoGroupStats'),
          function(object, ...) {
	cat('first group: ', object@n1, 'second group:', object@n2, '\n')
	summary(as.data.frame(object), ...)
})

setMethod('print', signature(x='TwoGroupStats'),
          function(x, ...) {
	cat('first group: ', x@n1, 'second group:', x@n2, '\n')
	summary(as.data.frame(x), ...)
})

setMethod('show', signature(object='TwoGroupStats'),
          function(object) {
	cat('first group: ', object@n1, 'second group:', object@n2, '\n')
	summary(as.data.frame(object))
})

.screwyPlot <- function(A, B, name='', mult=1) {
# Input is two vectors of log expression data.  Produces a loess fit to
# the difference in vectors as a function of position on the miroarray
# to see if there is systematic variation.
	my.diff <- A-B
	z <- 1:length(my.diff)
	smooth <- loess(my.diff ~ z)
	y <- fitted(smooth)
	plot(smooth, ylim=range(my.diff), xlab='position', ylab='difference',
		main=name)
	points(z, y+mult, type='l', col=oompaColor$BAD.REPLICATE)
	points(z, y-mult, type='l', col=oompaColor$BAD.REPLICATE)
	points(z, my.diff, pch='.')
	abline(h=0, col=oompaColor$CENTRAL.LINE)
	hi <- my.diff > y + mult
	lo <- my.diff < y - mult
	points(z[hi], my.diff[hi], pch=2, col=oompaColor$SIGNIFICANT)
	points(z[lo], my.diff[lo], pch=3, col=oompaColor$SIGNIFICANT)
	invisible(list(hi=hi, lo=lo))
}

.lo.sho <- function(x, y, xname = deparse(substitute(x)),
	 yname = deparse(substitute(y)), t='') {
# Input is two vectors (usually the mean and difference of two
# log-expression vectors, but it can be something else). Produces
# a loess plot of the two vectors.
	z <- loess(y ~ x)
	ox <- order(x)
	plot(z, xlab=xname, ylab=yname, ylim=range(y))
	points(x, y, pch='.')
	points(x[ox], z$fitted.values[ox], type='l', col=oompaColor$FITTED)
	abline(h=0)
	title(t)
	invisible(0)
}

.lo.front <- function(x, y) {
# Input is two vectors of expression data. Produces a loess plot of the
# mean against the difference. Implemented as a front end to f.lo.sho.
	.lo.sho((x+y)/2, x-y, 'mean', 'diff', paste(deparse(substitute(x)),
	 'vs', deparse(substitute(y)) ))
}


setMethod('plot', signature('TwoGroupStats', 'missing'),
          function(x, main=x@name, useLog=FALSE, ...) {
# plot 1:
            plot(x@mean1, sqrt(x@var1), xlab='mean', ylab='std dev', main=x@name1)
# plot 2:
            plot(x@mean2, sqrt(x@var2), xlab='mean', ylab='std dev', main=x@name2)
# plot 3:
            plot(x@overallMean, sqrt(x@overallVar), xlab='mean', ylab='std dev',
                 main='Both')
# plot 4:
            .lo.sho(x@overallMean, x@mean1-x@mean2, 'overall mean',
                     'difference', x@name)
# plot 5:
            .screwyPlot(x@mean1, x@mean2, name=x@name)
# plot 6:
            plot(x@pooledVar, x@overallVar, main='Variance Estimates')
            abline(0, 1, col=oompaColor$CENTRAL.LINE)
            invisible(x)
})


