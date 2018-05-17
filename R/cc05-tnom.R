# Copyright (C) Kevin R. Coombes, 2007-2012

TNoM <- function(data, classes, verbose=TRUE) {
  call <- match.call()
  if(is.logical(classes)) classes <- factor(classes)
  if(inherits(data, 'ExpressionSet')) {
    if(is.character(classes)) {
      classes <- as.factor(pData(data)[,classes])
    }
    data <- exprs(data)
  }
  selector <- as.numeric(classes==levels(classes)[[1]])
  n1 <- length(classes) - sum(selector)
  nr <- nrow(data)
  nc <- ncol(data)
  data <- jitter(data, amount=0.001)
  if(verbose) print('ordering...')
  zo <- t(apply(data, 1, order))
  if(verbose) print('matrifying...')
  zlog <- matrix(rep(selector, nr), nr, nc, byrow=TRUE)
  if(verbose) print('lapplying...')
  zlap <- data.frame(lapply(1:dim(data)[1], function(i, d, ord) {
    d[i, ord[i,]]
  }, zlog, zo))
  if(verbose) print('cumsuming...')
  zcs <- t(cumsum(zlap))
  if(verbose) print('more matrifying...')
  zk <- matrix(rep(1:nc, nr), nr, nc, byrow=TRUE)
  base <- n1 - zk +2*zcs
  altern <- length(classes) - base
  combo <- (base + altern - abs(base-altern))/2
  if(verbose) print('another apply...')
  tnomData <- apply(combo, 1, min)
  new('TNoM',
      data=as.matrix(data),
      tnomData=tnomData,
      nCol=nc,
      nRow=nr,
      classifier=classes,
      call=call)
}

setClass('TNoM',
         slots = c(data='matrix',
                   tnomData='numeric',
                   nCol='numeric',
                   nRow='numeric',
                   classifier='factor',
                   call='call'))

setClass('TNoMSummary',
         slots = c(TNoM='TNoM',
                   counts='numeric'))

setMethod('show', signature(object='TNoMSummary'),
          function(object) {
  cat(paste('TNoM object with', object@TNoM@nRow,
            'rows and', object@TNoM@nCol, 'columns\n'))
  cat(paste('Call:', as.character(list(object@TNoM@call)),'\n\n'))
  counts <- object@counts
  names(counts) <- as.character((1:length(counts))-1)
  cat('Number of genes with maximum number of misclassifications:\n')
  print(counts)
})

setMethod('summary', signature(object='TNoM'),
          function(object, ...) {
  temp <- hist(object@tnomData, breaks=(-1:((object@nCol+1)/2)+0.5), plot=FALSE)
  new('TNoMSummary', TNoM=object, counts=temp$counts)
})

.simulate.genes.TNoM <- function(object, verbose=TRUE) {
  classes <- object@classifier
  nRow <- object@nRow
  nCol <- object@nCol
  stupid <- lapply(1:nRow, function(i, z, n) { sample(z, n) }, classes, nCol)
  xx <- matrix(as.numeric(unlist(stupid)), nRow, nCol, byrow=TRUE)
  xnom <- TNoM(xx, classes, verbose=verbose)
  summary(xnom)@counts
}

.scramble.samples.TNoM <- function(data, classifier, verbose=TRUE) {
  eggs <- sample(classifier, length(classifier))
  x <- TNoM(data, eggs, verbose=verbose)
  summary(x)@counts
}

setClass('fullTNoM',
         slots = c(dex='numeric',
                   fakir='numeric',
                   obs='numeric',
                   scr='numeric',
                   name='character'))

setMethod('update', signature(object='TNoM'),
          function(object, nPerm=10, verbose=FALSE, ...)  {
  temp <- matrix(0, nPerm, length(summary(object)@counts))
  cat('Simulation number: ')
  for (i in 1:nPerm) {
    cat(paste(i, '. '))
    temp[i,] <- .simulate.genes.TNoM(object, verbose=verbose)
  }
  cat('\n')
  ct <- data.frame(t(apply(temp, 1, cumsum)))
  fakir <- apply(ct, 2, mean)
  dex <- 0:(length(fakir)-1)
  scram <- .scramble.samples.TNoM(object@data, object@classifier, verbose=verbose)
  obs <- cumsum(summary(object)@counts)
  scr <- cumsum(scram)
  new('fullTNoM',
      dex=dex,
      fakir=fakir,
      obs=obs,
      scr=scr,
      name=deparse(substitute(object)))
})

setMethod('plot', signature('fullTNoM', 'missing'),
          function(x, y, ...) {
  plot(x@dex, x@fakir, type='n',
       xlab='Maximum Number of Misclassifications', ylab='Number of Genes')
  points(x@dex, x@fakir, type='b', col=oompaColor$EXPECTED, pch=1)
  points(x@dex, x@obs, type='b', col=oompaColor$OBSERVED, pch=16)
  points(x@dex, x@scr, type='b', col=oompaColor$PERMTEST, pch=17)
  title(paste('TNoM', x@name))
  xx <- 0 #length(x@dex)/2
  yy <- max(x@fakir)# /4
  legend(xx, yy, c('observed', 'expected', 'scrambled'),
         col=c(oompaColor$OBSERVED, oompaColor$EXPECTED, oompaColor$PERMTEST),
         pch=c(16, 1, 17))
  invisible(x)
})

setMethod('hist', signature(x='fullTNoM'),
          function(x, ...) {
  plot(x@dex, x@obs-x@fakir, type='h',
       xlab='Excess Number of Misclassifications', ylab='Number of Genes')
  title(paste('TNoM', x@name))
  invisible(x)
})

setMethod('selectSignificant', signature(object='TNoM'),
          function(object, cutoff, ...) {
            object@tnomData < cutoff
          })

setMethod('countSignificant', signature(object='TNoM'),
          function(object, cutoff, ...) {
            sum(selectSignificant(object, cutoff))
          })

