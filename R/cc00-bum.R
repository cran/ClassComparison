# Copyright (C) Kevin R. Coombes, 2007-2016

# bum.R

########################################################################
## Beta-uniform mixture model of Pounds and Morris

####################################
# new generic methods
if (!isGeneric("countSignificant"))
  setGeneric("countSignificant",
             function(object, ...) { standardGeneric("countSignificant") }
             )

if (!isGeneric("selectSignificant"))
  setGeneric("selectSignificant",
             function(object, ...) { standardGeneric("selectSignificant") }
             )

if (!isGeneric("cutoffSignificant"))
  setGeneric("cutoffSignificant",
             function(object, ...) { standardGeneric("cutoffSignificant") }
             )

if (!isGeneric("anova"))
  setGeneric("anova", function(object, ...) standardGeneric("anova"))

if (!isGeneric("update"))
  setGeneric("update", function(object, ...) standardGeneric("update"))


####################################
## heart of the model

.lp <- function(p) { log(p/(1-p)) }
.ea <- function(a) { exp(a)/(1+exp(a)) }

# log likelihood of mixture with parameters a and L
.pounds <- function(vec, pvals) {
  psi <- vec[1]
  phi <- vec[2]
  a <- .ea(psi)
  L <- .ea(phi)
  -sum(log(L+(1-L)*a*pvals^(a-1)))
}


setClass('Bum',
         slots = c(pvals='numeric',
                   ahat='numeric', 
                   lhat='numeric', 
                   pihat='numeric'))

Bum <- function(pvals, ...) {
  if (all(is.na(pvals))) {
    stop("all p-values were NA; nothing to compuite")
  }
  orig.pvals <- pvals
  if (any(is.na(pvals))) {
    pvals <- pvals[!is.na(pvals)]
  }
  if (any(pvals < 0) || any(pvals > 1)) {
    stop("all p-values must be between 0 and 1")
  }
  if(min(pvals)==0) {
    min.nonzero <- min(pvals[pvals>0])
    pvals[pvals==0] <- min.nonzero/2
  }
  whatever <- optim(c(1/2, 1/2), .pounds, ..., 
                    method='L-BFGS-B', pvals=pvals)	# least squares fit
  psi <- whatever$par[1]
  phi <- whatever$par[2]
  ahat <- .ea(psi)	# MLE estimate of a
  lhat <- .ea(phi)	# MLE estimate of L
  pihat <- lhat + (1-lhat)*ahat	# upper bound on percent unchanged
  new('Bum', ahat=ahat, lhat=lhat, pihat=pihat, pvals=orig.pvals)
}

# given a desired false discovery rate, alpha, what is the cutoff
# for a significant p-value?
.cutoffByFDR <- function(object, alpha) {
  ((object@pihat - alpha*object@lhat)/(alpha*(1-object@lhat)))^(1/(object@ahat-1))
}

# Where do we set the cutoff on the p-values to obtain a desired posterior
# probability, gamma, that this value comes from the beta part of the mixture?
.cutoffByEB <- function(object, gamma) {
  ((gamma*object@lhat + object@ahat*(1-object@lhat))/
   (object@ahat*(1-gamma)*(1-object@lhat)))^(1/(object@ahat-1))
}

# public interface to the private methods

setMethod('cutoffSignificant', signature(object='Bum'),
          function(object, alpha, by='FDR', ...) {
            by <- match.arg(by, c('FDR', 'FalseDiscovery', 'falsediscovery',
                                  'EmpiricalBayes', 'empiricalbayes'))
            switch(by,
                   FDR = .cutoffByFDR(object, alpha),
                   FalseDiscovery = .cutoffByFDR(object, alpha),
                   falsediscovery = .cutoffByFDR(object, alpha),
                   EmpiricalBayes = .cutoffByEB(object, alpha),
                   empiricalbayes = .cutoffByEB(object, alpha))
          })

setMethod('selectSignificant', signature(object='Bum'),
          function(object, alpha, by='FDR', ...) {
            object@pvals < cutoffSignificant(object, by=by, alpha=alpha)
          })

setMethod('countSignificant', signature(object='Bum'),
          function(object, alpha, by='FDR', ...) {
            sum(selectSignificant(object, by=by, alpha=alpha), na.rm=TRUE)
          })

# plot and print routines

setMethod('hist', signature(x='Bum'),
          function(x, res=100, xlab='P Values', main='', ...) {
  hist(x@pvals, nclass=100, probability=TRUE, xlab=xlab, main=main, ...)
  xvals <- (0:res)/res
  fit <- x@lhat + (1-x@lhat)*dbeta(xvals, x@ahat, 1)
  lines(xvals, fit, col=oompaColor$OBSERVED, lwd=2)
  abline(h=x@pihat, col=oompaColor$EXPECTED, lwd=2)
  invisible(x)
})

setClass('BumSummary',
         slots = c(bum='Bum',
                   estimates='data.frame',
                   Fhat='numeric'))

setMethod('summary', signature(object='Bum'),
          function(object, tau=0.01, ...) {
  if (any(tau < 0) || any (tau > 1)) {
    stop("tau must be between 0 and 1")
  }
  Fhat <- object@lhat*tau + (1-object@lhat)*tau^object@ahat
  PA <- Fhat - object@pihat*tau
  PB <- 1 - Fhat - (1-tau)*object@pihat
  PC <- object@pihat*tau
  PD <- (1-tau)*object@pihat
  estimates <- data.frame(tau=tau, TP=PA, FN=PB, FP=PC, TN=PD)
  new('BumSummary', bum=object, estimates = estimates, Fhat=Fhat)
})

setMethod('show', signature(object='BumSummary'),
          function(object) {
  cat('\nBeta-Uniform Mixture Model\n\n')
  cat(paste('MLE Estimates: ahat =', format(object@bum@ahat, digits=5),
            ', lhat =', format(object@bum@lhat, digits=5), '\n'))
  cat('Upper Bound on Fraction Unchanged: pihat =',
      format(object@bum@pihat, digits=5), '\n\n')
  print(object@estimates)
})

likelihoodBum <- function(object) {
  object@lhat + (1-object@lhat)*object@ahat*object@pvals^(object@ahat-1)
}

setMethod('image', signature(x='Bum'),
         function(x, ...) {
  opar <- par(mfrow=c(2,2))
  hist(x, res=200, main='Beta-Uniform Mixture')
  alpha <- (1:25)/100
  plot(alpha, cutoffSignificant(x, alpha, by='FDR'),
       xlab='Desired False Discovery Rate', type='l',
       main='FDR Control', ylab='Significant P Value')
  GAMMA <- 5*(10:19)/100
  plot(GAMMA, cutoffSignificant(x, GAMMA, by='Emp'),
       ylab='Significant P Value', type='l',
       main='Empirical Bayes', xlab='Posterior Probability')
  b <- summary(x, (0:100)/100)@estimates
  sens <- b$TP/(b$TP+b$FN)
  spec <- b$TN/(b$TN+b$FP)
  plot(1-spec, sens, type='l', xlim=c(0,1), ylim=c(0,1), main='ROC Curve')
  points(1-spec, sens)
  area <- sum(sens)/100
  text(0.4, 0.2, paste('ROC area =',
                       format(area, digits=4)), adj=0)
  abline(0,1)
  par(opar)
  invisible(x)
})

