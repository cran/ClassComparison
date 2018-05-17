# Copyright (C) Kevin R. Coombes, 2007-2012

#########################################################################
## CLASS: two.groups
## Computes t-statistics using smoothed estimates of sd vs mean.

# The function .merge takes two smoothings (as produced by .smu)
# and pools them. It does this in a possibly stupid manner, since
# the supposedly independent x-values are averaged.
.merge <- function(z1, z2, n1=2, n2=2) {
	z <- data.frame((z1$x+z2$x)/2,
		sqrt( ((n1 - 1)*z1$y^2 + (n2 - 1)*z2$y^2) / (n1 + n2 - 2) ))
	dimnames(z)[[2]] <- c('x', 'y')
	return(z)
}

setClass('SmoothTtest',
         slots = c(one='SingleGroup',
                   two='SingleGroup',
                   smooth.t.statistics='numeric',
                   fit='data.frame',
                   dif='numeric',
                   avg='numeric',
                   aname='character',
                   bname='character',
                   name='character',
                   stats='TwoGroupStats'))


SmoothTtest <- function(stats, aname='Group One', bname='Group Two',
                        name=paste(aname, 'vs.', bname))
{
  one <- SingleGroup(stats@mean1, sqrt(stats@var1), name = aname)
  two <- SingleGroup(stats@mean2, sqrt(stats@var2), name = bname)
  fit <- .merge(one@fit, two@fit, stats@n1, stats@n2)
  dif <- stats@mean2-stats@mean1
  avg <- stats@overallMean
  smooth.t.statistics <- .compute.score(avg, dif, fit)	# the score is NOT the t-statistic
  smooth.t.statistics <- smooth.t.statistics / sqrt(1/stats@n1 + 1/stats@n2) # now it is.
  new('SmoothTtest', one=one, two=two, smooth.t.statistics=smooth.t.statistics,
      fit=fit, dif=dif, avg=avg, aname=aname, bname=bname, name=name, stats=stats)
}

setMethod('as.data.frame', signature(x='SmoothTtest'),
          function(x, row.names=NULL, optional=FALSE) {
            val <- data.frame(x@avg, x@dif, x@smooth.t.statistics,
                              x@one@score, x@two@score)
            dimnames(val)[[2]] <- c('AverageLogIntensity', 'LogRatio',
                                    'SmoothedTStatistic', 'FirstBadFlag', 'SecondBadFlag')
            val
          })

setMethod('summary', signature(object='SmoothTtest'),
          function(object, ...) {
  cat(paste('Smooth T test of', object@aname, 'versus', object@bname, '\n\n', sep=' '))
  summary(as.data.frame(object))
})

.group.coding <- function(tg, goodflag=2, badch=4, folddiff=3) {
  bad.one <- (abs(tg@one@score) > badch)
  bad.two <- (abs(tg@two@score) > badch)
  good.guy <- (abs(tg@smooth.t.statistics) > goodflag) & !(bad.one | bad.two)
  big.fold <- (abs(tg@dif) > logb(folddiff,2))
  boring <- !bad.one & !bad.two & !good.guy & !big.fold 
  list(ColorCoding(boring, oompaColor$BORING, '.'),
       ColorCoding(bad.one, oompaColor$BAD.REPLICATE, 8),
       ColorCoding(bad.two, oompaColor$WORST.REPLICATE, 8),
       ColorCoding(big.fold, oompaColor$FOLD.DIFFERENCE, '.'),
       ColorCoding(good.guy, oompaColor$SIGNIFICANT, 15))
}

setMethod('plot', signature('SmoothTtest', 'missing'),
          function(x,
                   folddiff=3,
                   goodflag=2,
                   badch=4,
                   ccl=0,
                   name=x@name,
                   pch='.',
                   xlab='log intensity',
                   ylab='log ratio',
                   ...) {
            r <- x@stats@mean1
            R <- x@stats@mean2
            xx <- x@fit$x
            yy <- x@fit$y
            if (!is.list(ccl)) {
              ccl <- .group.coding(x, goodflag, badch, folddiff)
            }
            goodflag <- goodflag * sqrt(1/x@stats@n1 + 1/x@stats@n2)
### plot1
            plot(x@one, multiple=badch, pch=pch, xlab=xlab, ylab=ylab, ...)
### plot2
            plot(x@two, multiple=badch, pch=pch, xlab=xlab, ylab=ylab, ...)
### plot3
            plot(ColorCodedPair(R, r, ccl), pch=pch,
                 xlab=x@aname,
                 ylab=x@bname,
                 main=paste(name, 'Direct Comparison'), ...)
            abline(0, 1, col=oompaColor$CENTRAL.LINE, lwd=1)
### plot4
            plot(ColorCodedPair(x@avg, x@dif, ccl),
                 main=paste(x@bname, '-', x@aname),
                 xlab=xlab, ylab=ylab, pch=pch, ...)
            abline(h=0,col=oompaColor$CENTRAL.LINE, lwd=1)
            points(xx, +goodflag*yy, col=oompaColor$CONFIDENCE.CURVE, type='l')
            points(xx, -goodflag*yy, col=oompaColor$CONFIDENCE.CURVE, type='l')
### plot5
            hist(x@smooth.t.statistics, nclass=53,
                 xlab='T-statistics', ylab='Frequency', main='Histogram of T-statistics')
### plot6
            plot(ColorCodedPair(x@avg, x@smooth.t.statistics, ccl),
                 pch=pch, xlab=xlab, ylab='smooth t statistic')
            abline(v=1)
            invisible(x)
          })


