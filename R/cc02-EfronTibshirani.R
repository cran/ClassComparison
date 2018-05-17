# Copyright (C) Kevin R. Coombes, 2007-2012

# EfronTibshirani.R

rankSum <- function(data, selector) {
  x <- data[selector]
  y <- data[!selector]
  n.x <- length(x)
  n.y <- length(y)
  xy <- c(x, y)
  rnk <- rank(xy)
  sum(rnk[1:n.x])
}

.probDiff <- function(object, p0) {
  1-p0*object@theoretical.pdf/object@unravel
}

dwil <- function(q, m, n) {
  q <- q -sum(1:m)
  if (m < 50 & n < 50) {
    dwilcox(q, m, n)
  } else {
#    aver <- m*(m+n+1)/2
    aver <- m*n/2
    varn <- m*n*(m+n+1)/12
    dnorm(q, aver, sqrt(varn))
  }
}

setClass('MultiWilcoxonTest',
         slots = c(xvals='numeric',
                   rank.sum.statistics='numeric',
                   pdf='numeric',
                   theoretical.pdf='numeric',
                   unravel='numeric',
                   groups='character',
                   call='call'))


MultiWilcoxonTest <- function(data, classes, histsize=NULL) {
  call <- match.call()
  if(inherits(data, 'ExpressionSet')) {
    if(is.character(classes)) {
      classes <- as.factor(pData(data)[,classes])
    }
    data <- exprs(data)
  }
  if (is.logical(classes)) {
    selector <- classes
    classes <- as.factor(classes)
  } else {
    selector <- classes == levels(classes)[1]
  }
  wilstats <- apply(data, 1, rankSum, selector)	# row-by-row Wilcoxon test
  num.selected <- sum(selector)
  num.unselected <- length(selector)-num.selected
  minsum <- sum(1:num.selected)
  maxsum <- sum((length(selector)-num.selected+1):length(selector))
  if (is.null(histsize )) {
    histbreaks <- 0.5 + (minsum-1):maxsum
    pdf <- hist(wilstats, breaks=histbreaks, plot=FALSE, probability=TRUE)$density
    xvals <- minsum:maxsum
  } else {
    tmp <- hist(wilstats, breaks=histsize, plot=FALSE, probability=TRUE)
    L <- length(tmp$breaks)
    pdf <- tmp$density
    xvals <- (tmp$breaks[1:(L-1)] + tmp$breaks[2:L])/2
  }
  theoretical.pdf <- dwil(xvals, num.selected, num.unselected)
  
  Y <- log(pdf) - log(theoretical.pdf)
  click <- !is.infinite(Y)
  Y <- Y[click]
  X <- xvals[click]
  Z <- lm(Y ~ bs(X, df=5))	
  YP <- predict(Z, data.frame(X=xvals))
  
  unravel <- exp(YP+log(theoretical.pdf))
  new('MultiWilcoxonTest', call=call, groups=levels(classes),
      xvals=xvals, rank.sum.statistics=wilstats, pdf=pdf,
      theoretical.pdf=theoretical.pdf, unravel=unravel)
}

setMethod('hist', signature(x='MultiWilcoxonTest'),
          function(x,
                   xlab='Rank Sum',
                   ylab='Prob(Different | Y)',
                   main='',
                   ...) {
  top <- max(c(x@unravel, x@theoretical.pdf))
  hist(x@rank.sum.statistics, probability=TRUE, breaks=100, ylim=c(0, top),
       xlim=c(min(x@xvals), max(x@xvals)), xlab=xlab, main=main)
  lines(x@xvals, x@theoretical.pdf, col=oompaColor$EXPECTED, lwd=2)
  lines(x@xvals, x@unravel, col=oompaColor$OBSERVED, lwd=2)
  legend(min(x@xvals), max(x@unravel), c('Empirical', 'Theoretical'),
         col=c(oompaColor$OBSERVED, oompaColor$EXPECTED), lwd=2)
  invisible(x)
})

setMethod('plot', signature('MultiWilcoxonTest', 'missing'),
          function(x,
                   prior=1,
                   significance=0.9,
                   ylim=c(-0.5, 1),
                   xlab='Rank Sum',
                   ylab='Prob(Different | Y)',
                   ...) {
  plot(c(min(x@xvals), max(x@xvals)), c(-0.5,1), type='n',
       xlab=xlab, ylab=ylab, ylim=ylim, ...)
  toss <- unlist(lapply(prior, function(p, o) {
    lines(o@xvals, .probDiff(o, p), err=-1)
  }, x))
  abline(h=significance, col=oompaColor$OBSERVED)
  invisible(x)
})

setMethod('cutoffSignificant', signature(object='MultiWilcoxonTest'),
          function(object, prior, significance, ...) {
            z <- .probDiff(object, prior)
            x <- object@xvals[z < significance]
            list(low=min(x), high=max(x))
          })

setMethod('selectSignificant', signature(object='MultiWilcoxonTest'),
          function(object, prior, significance, ...) {
            stats <- object@rank.sum.statistics
            lh <- cutoffSignificant(object, prior, significance)
            (stats < lh$low) | (stats > lh$high)
          })

setMethod('countSignificant', signature(object='MultiWilcoxonTest'),
          function(object, prior, significance, ...) {
            sum(selectSignificant(object, prior, significance))
          })

setMethod('summary', signature(object='MultiWilcoxonTest'),
          function(object, prior=1, significance=0.9, ...) {
  lh <- cutoffSignificant(object, prior, significance)
  cat(paste('Call:', as.character(list(object@call)),'\n'))
  cat(paste('Row-by-row Wilcoxon rank-sum tests with',
            length(object@rank.sum.statistics), 'rows\n\nRank-sum statistics:\n'))
  print(summary(object@rank.sum.statistics))
  cat(paste('\nLarge values indicate an increase in class:',
            object@groups[1],'\n\n'))
  cat(paste('With prior =', prior, 'and alpha =', significance, '\n'))
  cat(paste('\tthe upper tail contains', sum(object@rank.sum.statistics > lh$high),
            'values above', lh$high, '\n'))
  cat(paste('\tthe lower tail contains', sum(object@rank.sum.statistics < lh$low),
            'values below', lh$low, '\n'))
})
