# Copyright (C) Kevin R. Coombes, 2007-2012

# cc08-singleGroup.R

#########################################################################
## Utilities

# The functions .smu and .compute.score form a pair; they have to work
# cooperatively to produce valid estimates. A 'score' is a signed deviation
# measured in units of the standard deviation.
.smu <- function(a, b, span = 0.55, verbose=FALSE)
{
  fit <- loess(b ~ a, span = span, normalize = FALSE)
  oa <- order(a)
  x <- a[oa]
  y <- predict(fit, x)
  yleft <- y[1:(length(y) - 1)]
  yright <- y[2:length(y)]
  ydecreasing <- c(FALSE, ((yright - yleft) < 0))
  left.end <- min(grep("TRUE", as.character(ydecreasing)))
  if(is.na(left.end)) {
    left.end <- 1
  }
  right.end <- max(grep("TRUE", as.character(ydecreasing)))
  if(is.na(right.end)) {
    right.end <- length(y)
  }
  y[1:left.end] <- rep(y[left.end], left.end)
  if(right.end < length(y)) {
    y[(right.end:length(y))] <- y[right.end]
  }
  ychange <- c(0,diff(y))
  dropoff <- mean(ychange) - 3 * sqrt(var(ychange))
  x95 <- x[as.integer(length(x) * 0.95)]
  extreme <- (ychange < dropoff) & (x > x95)
  if(sum(extreme) > 0) {
    leftmost.extreme <- grep("TRUE", as.character(extreme))[1]
    y[leftmost.extreme:length(y)] <- y[leftmost.extreme - 1]
    if(verbose) print(paste(length(y), leftmost.extreme))
  }
  list(x=x, y=y)
}


.compute.score <- function(m, d, z) {
  om <- order(m)
  score <- m/m
  score[om] <- d[om]/z$y
  return(score)
}

#########################################################################
## CLASS: SingleGroup
## Fits curve to sd vs mean, and scores pointwise estimates.

setClass('SingleGroup',
         slots = c(score='numeric',
                   fit='list',
                   avg='numeric',
                   sd='numeric',
                   span='numeric',
                   name='character'))

SingleGroup <- function(avg, sd, span=0.5, name='')
{
# Creates an object of class 'SingleGroup'. Required inputs are vectors
# representing the mean and standard deviation. These are smoothed and
# then scored.
  z <- .smu(avg, sd, span)
  score <- .compute.score(avg, abs(sd), z)
  new('SingleGroup', score=score, fit=z, avg=avg, sd=sd, span=span, name=name)
}

.scored.coding <- function(sg, multiple, span=1.6) {
  s <- abs(sg@score)
  list(ColorCoding(s < multiple, oompaColor$BORING, 16),
       ColorCoding(s > multiple, oompaColor$BAD.REPLICATE, 8),
       ColorCoding(s  > span*multiple, oompaColor$WORST.REPLICATE, 8))
}

setMethod('plot', signature('SingleGroup', 'missing'),
          function(x, multiple=3, ccl=0, main=x@name,
                   xlab='Mean', ylab='Std Dev', xlim=0, ylim=0, ...) {
# Plot method for objects of class 'SingleGroup'. The plot flags
# bad replicates, which means those replicates whose standard deviation
# exceeds the expected value by some given multiple.
            m <- x@avg
            d <- x@sd
            z <- x@fit
            s <- x@score
            if(!is.list(ccl)) {
              ccl <- .scored.coding(x, multiple)
            }
            if (length(xlim) != 2) {
              xlim <- c(min(m), max(m))
            }
            if (length(ylim) != 2) {
              ylim <- c(min(d), max(d))
            }
            plot(ColorCodedPair(m, d, ccl), xlab='', ylab='', xlim=xlim, ylim=ylim, ...)
            title(main, xlab=xlab, ylab=ylab)
            points(z$x, multiple*z$y, type='l', col=oompaColor$CONFIDENCE.CURVE, err=-1, ...)
            points(z$x, -multiple*z$y, type='l', col=oompaColor$CONFIDENCE.CURVE, err=-1, ...)
            abline(h=0, col=oompaColor$CENTRAL.LINE, lwd=1, ...)
            invisible(x)
          })

setMethod('as.data.frame', signature(x='SingleGroup'),
          function(x, row.names=NULL, optional=FALSE) {
            x <- data.frame(x@avg, x@sd, x@score, x@fit$x, x@fit$y)
            dimnames(x)[[2]] <- c('avg', 'sd', 'score', 'fit.x', 'fit.y')
            x
          })

setMethod('summary', signature(object='SingleGroup'),
          function(object, ...) {
	cat('Name:', object@name, '\n')
	summary(as.data.frame(object), ...)
      })

setMethod('print', signature(x='SingleGroup'),
          function(x, ...) {
	cat('Name:', x@name, '\n')
        xdf <- as.data.frame(x)
	print(xdf, ...)
      })

setMethod('show', signature(object='SingleGroup'),
          function(object) {
	cat('Name:', object@name, '\n')
        xdf <- as.data.frame(object)
	print(xdf)
      })

