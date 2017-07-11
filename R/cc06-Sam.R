# Copyright (C) Kevin R. Coombes, 2007-2012

# Sam
#	significance analysis of microarrays (Tusher et al)

# requires oompa ttest for "matrixT"
# require(ttest)

setClass('Sam',
         representation(expected='numeric',
                        observed='numeric',
                        t.statistics='numeric',
                        sim.data='matrix',
                        call='call'))

Sam <- function(data, classes, nPerm=100, verbose=TRUE) {
  call <- match.call()
  if(inherits(data, 'ExpressionSet')) {
    if(is.character(classes)) {
      classes <- as.factor(pData(data)[,classes])
    }
    data <- exprs(data)
  }
  if (is.logical(classes)) {
    selector <- classes
    classes <- factor(classes)
  } else {
    selector <- classes == levels(classes)[[1]]
  }
  num.selected <- sum(selector)
  num.unselected <- length(selector)-sum(selector)
  class.Sam <- c(rep(TRUE, num.selected), rep(FALSE, num.unselected))
  data.Sam <- cbind(data[, selector], data[,!selector])
  t.values <- as.vector(matrixT(data, classes))
  base.t <- sort(t.values)
  
  motorway <- matrix(0, nrow(data), nPerm)
  for(i in 1:nPerm) {
    if(verbose) cat(paste(i, '. '))
    y <- rep(FALSE, length(classes))
    y[sample(1:num.selected, num.selected/2)] <- TRUE
    y[num.selected+sample(1:num.unselected, num.unselected/2)] <- TRUE
    y <- (1:length(classes))[order(order(y))]
    x <- as.vector(matrixT(data[,y], classes))
    motorway[,i] <- sort(x)
  }
  if(verbose) cat('\n')
  motors <- apply(motorway, 1, sum)/nPerm
  new('Sam', call=call, t.statistics=t.values,
      expected=motors, sim.data=motorway, observed=base.t)
}

setMethod('plot', signature(x='Sam', y='missing'),
          function(x, y,
                   tracks=NULL,
                   xlab='Expected T Statistics (Empirical)',
                   ylab='Observed T Statistics',
                   ...) {
  plot(x@expected, x@observed, xlab=xlab, ylab=ylab, ...)
  abline(0,1, col=oompaColor$CENTRAL.LINE)
  if (!is.null(tracks)) {
    tracks=unique(c(tracks, -tracks))
    lapply(tracks, abline, 1, col=oompaColor$CONFIDENCE.CURVE)
  }
  invisible(x)
})

setClass('SamSummary',
         representation(fdr='numeric',
                        hi='numeric',
                        lo='numeric',
                        cutoff='numeric',
                        significant.calls='logical',
                        average.false.count='numeric'))

setMethod('show', signature(object='SamSummary'),
          function(object) {
  cat(paste('Using a cutoff of', format(object@cutoff, digits=3), ', we '))
  cat(paste('called', sum(object@significant.calls), 'genes significant '))
  cat(paste('with expected FDR =', format(object@fdr, digits=3),
            ' (', object@average.false.count,')\n'))
})

setMethod('summary', signature(object='Sam'),
          function(object, cutoff=1, ...) {
  positive <- object@observed - object@expected > cutoff
  negative <- object@observed - object@expected < -cutoff
  hi.limit <- min(object@observed[positive])
  if (is.na(hi.limit)) {
    hi.limit <- max(object@observed)
  }
  lo.limit <- max(object@observed[negative])
  if (is.na(lo.limit)) {
    lo.limit <- min(object@observed)
  }
  false.count <- apply(object@sim.data, 2, function(x, lo, hi) {
    sum(x < lo | x > hi)
  }, lo.limit, hi.limit)
  average.false.count <- mean(false.count)
  significant.calls <- (object@t.statistics > hi.limit ) | (object@t.statistics < lo.limit)
  fdr <- average.false.count/sum(significant.calls)
  new('SamSummary',
      hi=hi.limit,
      lo=lo.limit,
      fdr=fdr,
      cutoff=cutoff,
      significant.calls=significant.calls,
      average.false.count=average.false.count)
})

setMethod('selectSignificant', signature(object='Sam'),
          function(object, cutoff=1, ...) {
            a <- summary(object, cutoff)
            a@significant.calls
          })

setMethod('countSignificant', signature(object='Sam'),
          function(object, cutoff=1, ...) {
            sum(selectSignificant(object, cutoff=cutoff))
          })

