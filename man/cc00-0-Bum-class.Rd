\name{Bum-class}
\alias{Bum}
\alias{Bum-class}
\alias{countSignificant,Bum-method}
\alias{cutoffSignificant,Bum-method}
\alias{selectSignificant,Bum-method}
\alias{hist,Bum-method}
\alias{image,Bum-method}
\alias{summary,Bum-method}
\alias{likelihoodBum}
\docType{class}
\title{Class "Bum"}
\description{
  The \code{Bum} class is used to fit a beta-uniform mixture model to a
  set of p-values.
}
\usage{
Bum(pvals, \dots)
\S4method{summary}{Bum}(object, tau=0.01, \dots)
\S4method{hist}{Bum}(x, res=100, xlab='P Values', main='', \dots)
\S4method{image}{Bum}(x, \dots)
\S4method{cutoffSignificant}{Bum}(object, alpha, by='FDR', \dots)
\S4method{selectSignificant}{Bum}(object, alpha, by='FDR', \dots)
\S4method{countSignificant}{Bum}(object, alpha, by='FDR', \dots)
likelihoodBum(object)
}
\arguments{
  \item{pvals}{numeric vector containing values between \code{0} and \code{1}}
  \item{object}{object of class \code{Bum}}
  \item{tau}{numeric scalar between \code{0} and \code{1}, representing a
    cutoff on the p-values}
  \item{x}{object of class \code{Bum}}
  \item{res}{positive integer scalar specifying the resolution at which to
    plot the fitted distribution curve}
  \item{xlab}{character string specifying the label for the x axis}
  \item{main}{character string specifying the graph title}
  \item{alpha}{Either the false discovery rate (if \code{by = 'FDR'}) or
    the posterior probability (if \code{by = 'EmpiricalBayes'})}
  \item{by}{character string denoting the method to use for determining
    cutoffs. Valid values are:
    \itemize{
      \item FDR
      \item FalseDiscovery
      \item EmpiricalBayes
    }}
  \item{\dots}{extra arguments for generic or plotting routines}
}
\section{Creating Objects}{
  Although objects can be created directly using \code{new}, the most
  common usage will be to pass a vector of p-values to the
  \code{Bum} function. 
}
\section{Slots}{
  \describe{
    \item{\code{pvals}:}{numeric vector of p-values used to construct the
      object.}
    \item{\code{ahat}:}{Model parameter}
    \item{\code{lhat}:}{Model parameter}
    \item{\code{pihat}:}{Model parameter}
  }
}
\section{Methods}{
  \describe{
    \item{summary(object, tau=0.01, \dots)}{For each value of the p-value
      cutoff \code{tau}, computes estimates of the fraction of true
      positives (TP), false negatives (FN), false positives (FP), and
      true negatives (TN).}
    \item{hist(x, res=100, xlab='P Values', main='', \dots)}{Plots a
      histogram of the object, and overlays (1) a straight line to indicate
      the contribution of the uniform component and (2) the fitted
      beta-uniform distribution from the observed values. Colors in the
      plot are controlled by
      \code{\link[oompaBase:oompaColor]{oompaColor$EXPECTED}} and 
      \code{\link[oompaBase:oompaColor]{oompaColor$OBSERVED}}.
    }
    \item{image(x, \dots)}{Produces four plots in a 2x2 layout: (1) the
      histogram produced by \code{hist}; (2) a plot of cutoffs against
      the desired false discovery rate; (3) a plot of cutoffs against
      the posterior probability of coming from the beta component; and
      (4) an \acronym{ROC} curve.}
    \item{cutoffSignificant(object, alpha, by='FDR', \dots)}{Computes the
      cutoff needed for significance, which in this case means arising
      from the beta component rather than the uniform component of the
      mixture. Significance is specified either by the false discovery
      rate (when \code{by = 'FDR'} or \code{by = 'FalseDiscovery'}) or
      by the posterior probability (when \code{by = 'EmpiricalBayes'})}
    \item{selectSignificant(object, alpha, by='FDR', \dots)}{Uses
      \code{cutoffSignificant} to determine a logical vector that
      indicates which of the p-values are significant.}
    \item{countSignificant(object, alpha, by='FDR', \dots)}{Uses
      \code{selectSignificant} to count the number of significant
      p-values.}
  }
}
\value{
  Graphical functions (\code{hist} and \code{image}) invisibly return the
  object on which they were invoked.

  The \code{cutoffSignificant} method returns a real number between zero
  and one. P-values below this cutoff are considered statistically
  significant at either the specified false discovery rate or at the
  specified posterior probability.

  The \code{selectSignificant} method returns a vector of logical values
  whose length is equal to the length of the vector of p-values that was
  used to construct the \code{Bum} object.  True values in the return
  vector mark the statistically significant p-values.

  The \code{countSignificant} method returns an integer, the number of
  statistically significant p-values.

  The \code{summary} method returns an object of class
  \code{\link{BumSummary}}.
}
\details{
  The BUM method was introduced by Stan Pounds and Steve Morris,
  although it was simultaneously discovered by several other
  researchers. It is generally applicable to any analysis of microarray
  or proteomics data that performs a separate statistical hypothesis
  test for each gene or protein, where each test produces a p-value that
  would be valid if the analyst were only performing one statistical
  test. When performing thousands of statistical tests, however, those
  p-values no longer have the same interpretation as Type I error
  rates. The idea behind BUM is that, under the null hypothesis that
  none of the genes or proteins is interesting, the expected
  distribution of the set of p-values is uniform. By contrast, if some
  of the genes are interesting, then we should see an overabundance of
  small p-values (or a spike in the histogram near zero). We can model
  the alternative hypothesis with a beta distribution, and view the set
  of all p-values as a mixture distribution.

  Fitting the BUM model is straightforward, using a nonlinear optimizer
  to compute the maximum likelihood parameters. After the model has
  been fit, one can easily determine cutoffs on the p-values that
  correspond to desired false discovery rates. Alternatively, the
  original Pounds and Morris paper shows that their results can be
  reinterpreted to recover the empirical Bayes method introduced by
  Efron and Tibshirani. Thus, one can also determine cutoffs by
  specifying a desired posterior probability of significance.
}
\references{
  Pounds S, Morris SW.\cr
  \emph{Estimating the occurrence of false positives and false negatives in
  microarray studies by approximating and partitioning the empirical
  distribution of p-values.}\cr
  Bioinformatics. 2003 Jul 1;19(10):1236-42. 

  Benjamini Y, Hochberg Y.\cr
  \emph{Controlling the false discovery rate: a practical and powerful approach
  to multiple testing.}\cr
  J Roy Statist Soc B, 1995; 57: 289-300.

  Efron B, Tibshirani R.\cr
  \emph{Empirical bayes methods and false discovery rates for microarrays.}\cr
  Genet Epidemiol 2002, 23: 70-86.
}
\author{
  Kevin R. Coombes \email{krc@silicovore.com}
}
\seealso{
  Two classes that produce lists of p-values that can (and often
  should) be analyzed using BUM are \code{\link{MultiTtest}} and
  \code{\link{MultiLinearModel}}. Also see \code{\link{BumSummary}}. 
}
\examples{
showClass("Bum")
fake.data <- c(runif(700), rbeta(300, 0.3, 1))
a <- Bum(fake.data)
hist(a, res=200)

alpha <- (1:25)/100
plot(alpha, cutoffSignificant(a, alpha, by='FDR'),
     xlab='Desired False Discovery Rate', type='l',
     main='FDR Control', ylab='Significant P Value')

GAMMA <- 5*(10:19)/100
plot(GAMMA, cutoffSignificant(a, GAMMA, by='EmpiricalBayes'),
     ylab='Significant P Value', type='l',
     main='Empirical Bayes', xlab='Posterior Probability')

b <- summary(a, (0:100)/100)
be <- b@estimates
sens <- be$TP/(be$TP+be$FN)
spec <- be$TN/(be$TN+be$FP)
plot(1-spec, sens, type='l', xlim=c(0,1), ylim=c(0,1), main='ROC Curve')
points(1-spec, sens)
abline(0,1)

image(a)

countSignificant(a, 0.05, by='FDR')
countSignificant(a, 0.99, by='Emp')
}
\keyword{multivariate}
\keyword{htest}
\keyword{classes}

