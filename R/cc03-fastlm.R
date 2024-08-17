# Copyright (C) Kevin R. Coombes, 2007-2012

setClass('MultiLinearModel',
         slots = c(call='call',
                   model='formula',
                   F.statistics='numeric',
                   p.values='numeric',
                   coefficients='matrix',
                   predictions='matrix',
                   sse='numeric',
                   ssr='numeric',
                   df='numeric'))


MultiLinearModel <- function(form, clindata, arraydata) {
  call <- match.call()			# how did i get here?
  if(inherits(clindata, 'ExpressionSet')) {
    arraydata <- exprs(clindata)
    clindata <- pData(clindata)
  }
  YY <- t(arraydata)			# the data matrix
  EY <- apply(YY, 2, mean)		# its mean vector
  SYY <- apply(YY, 2, function(y) {sum(y^2)}) - nrow(YY)*EY^2	# sum of squares after centering
  clindata <- data.frame(y=YY[,1], clindata)
  dimnames(clindata)[[2]][1] <- 'Y'
  X <- model.matrix(form, clindata)	# contrasts matrix
  XtX <- t(X) %*% X
  ixtx <- solve(XtX)
  bhat <- ixtx %*% t(X) %*% YY		# Use the pseudo-inverse to estimate the parameters
  yhat <- X %*% bhat			# Figure out what is predicted by the model
                                        # Now we partition the sum-of-square errors
  rdf <- ncol(X)-1			# number of parameters in the model
  edf <- nrow(YY)-rdf-1			# additional degrees of freedom
  errors <- YY - yhat			# difference between observed and model predictions
  sse <- apply(errors^2, 2, sum)	# sum of squared errors over the samples
  mse <- sse/edf			# mean squared error
  ssr <- SYY - sse			# regression error
  msr <- ssr/rdf			# mean regression error
  fval <- msr/mse			# f-test for the overall regression
  pfval <- 1-pf(fval, rdf, edf)		# f-test p-values
  new('MultiLinearModel', call=call,
      model=form,
      coefficients=bhat,
      predictions=yhat,
      df=c(rdf, edf),
      sse=sse,
      ssr=ssr,
      F.statistics=fval,
      p.values=pfval)
}

setMethod('summary', signature(object='MultiLinearModel'),
          function(object,...) {
  cat(paste('Row-by-row linear models with',
            length(object@F.statistics), 'rows\n\n'))
  cat(paste('Call:', as.character(list(object@call)),'\n\nF-statistics:\n'))
  print(summary(object@F.statistics))
  cat('\nP-values:\n')
  summary(object@p.values)
})

setMethod('hist', signature(x='MultiLinearModel'),
          function(x, xlab='F Statistics', main=NULL, ...) {
  hist(x@F.statistics, xlab=xlab, main=main, ...)
})

setMethod('plot', signature('MultiLinearModel', 'missing'),
          function(x, y, ylab='F Statistics', ...) {
  plot(x@F.statistics, ylab=ylab, ...)
})

setMethod('plot', signature('MultiLinearModel', 'ANY'),
          function(x, y,
                   xlab='F Statistics',
                   ylab=deparse(substitute(y)),
                   ...) {
  plot(x@F.statistics, y, xlab=xlab, ylab=ylab, ...)
})

setMethod("as.data.frame", signature(x="MultiLinearModel"),
          function (x, row.names=NULL, optional=FALSE, ...) {
  data.frame(t(x@coefficients),
             Fstats = x@F.statistics,
             Pvalues = x@p.values,
             DF1 = x@df[1],
             DF2 = x@df[2])
})

multiTukey <- function(object, alpha) {
  mse <- object@sse/object@df[2]
  r <- 1 + object@df[1]
  n <- (r + object@df[2])/r
  qtukey(1-alpha, r, object@df[2])*sqrt(mse/n)
}

##########################################################
# this has been verified, all too painfully
setMethod('anova', signature(object='MultiLinearModel'),
          function(object, ob2, ...) {
  df1 <- object@df[2]+1
  df2 <- ob2@df[2]+1
  if (df1 < df2) {
    tmp <- object
    object <- ob2
    ob2 <- tmp
    df1 <- object@df[2]+1
    df2 <- ob2@df[2]+1
  }
  dev0 <- ob2@sse - object@sse
  Df0 <- df2 - df1
  scaler0 <- ob2@sse/df2
  Fs0 <- abs((dev0/Df0)/scaler0)
  Ps0 <- 1-pf(Fs0, abs(Df0), df2)
  data.frame(F.statistics=Fs0, p.values=Ps0)
})

