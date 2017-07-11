\name{Sam-class}
\alias{Sam}
\alias{Sam-class}
\alias{countSignificant,Sam-method}
\alias{plot,Sam,missing-method}
\alias{selectSignificant,Sam-method}
\alias{summary,Sam-method}
\docType{class}
\title{Class "Sam"}
\description{
  Implements the "Significance Analysis of Microarrays" approach to
  detecting differentially expressed genes.
}
\usage{
Sam(data, classes, nPerm=100, verbose=TRUE)
\S4method{plot}{Sam,missing}(x, y, tracks=NULL, xlab='Expected T Statistics (Empirical)',
 ylab='Observed T Statistics', \dots)
\S4method{summary}{Sam}(object, cutoff=1, \dots)
\S4method{selectSignificant}{Sam}(object, cutoff=1, \dots)
\S4method{countSignificant}{Sam}(object, cutoff=1, \dots)
}
\arguments{
  \item{data}{ Either a data frame or matrix with numeric values or an
    \code{\link[Biobase:class.ExpressionSet]{ExpressionSet}} as defined
    in the BioConductor tools for analyzing microarray data.}
  \item{classes}{ If \code{data} is a data frame or matrix, then classes
    must be either a logical vector or a factor. If \code{data} is an
    \code{ExpressionSet}, then \code{classes} can be a character string that
    names one of the factor columns in the associated
    \code{\link[Biobase]{phenoData}} subobject.}
  \item{nPerm}{An integer; the number of permutations}
  \item{verbose}{A logical flag}
  \item{x}{A \code{Sam} object}
  \item{y}{Nothing, since it is supposed to be missing. Changes to the Rd
    processor require documenting the missing entry.}
  \item{tracks}{a numeric vector}
  \item{xlab}{Label for the x axis}
  \item{ylab}{Label for the y axis}
  \item{object}{A \code{Sam} object}
  \item{cutoff}{A numeric value}
  \item{\dots}{The usual extra arguments to generic functions}
}
\details{
  The SAM approach to analyzing microarray data was developed by Tusher
  and colleagues; their implementation is widely available.  This is an
  independent implementation based on the description in their original
  paper, customized to use the same interface (and thus work with
  \code{\link[Biobase:class.ExpressionSet]{ExpressionSet}} objects) used
  by the rest of the ClassComparison package. The fundamental idea
  behind SAM is that the observed distribution of row-by-row two-sample
  t-tests should be compared not to the theoretical null distribution
  but to a null distribution estimated by a permutation test. The
  \code{Sam} constructor performs the permutation test.
}
\section{Creating Objects}{
  As usual, objects can be created by \code{new}, but better methods are
  available in the form of the \code{Sam} function. The inputs to this
  function are the same as those used for row-by-row statistical tests
  throughout the ClassComparison package; a detailed description can be
  found in the \code{MultiTtest} class.

}
\section{Slots}{
  \describe{
    \item{\code{t.statistics}:}{numeric vector containing the observed
      t-statistics.} 
    \item{\code{observed}:}{numeric vector containing the sorted
      observed t-statistics.}
    \item{\code{expected}:}{numeric vector of the expected
      distribution of t-statistics based on a permutation test.}
    \item{\code{sim.data}:}{numeric matrix containing all the t-statistics
      from all the permutations.}
    \item{\code{call}:}{object of class \code{call} specifying the function
      call that was used to create this object.}
  }
}
\section{Methods}{
  \describe{
    \item{summary(object, cutoff=1, \dots)}{Compute a summary of the object. }
    \item{plot(x, tracks=NULL, xlab='Expected T Statistics (Empirical)',
      ylab='Observed t Statistics', \dots)}{Plot the observed and expected
      t-statistics. The \code{tracks} argument causes parallel lines to be
      drawn on either side of the quantile-quantile central line, at the
      specified offsets. Colors in the plot are controlled by the current
      values of \code{\link[oompaBase:oompaColor]{oompaColor$CENTRAL.LINE}} and
	\code{\link[oompaBase:oompaColor]{oompaColor$CONFIDENCE.CURVE}} }
    \item{selectSignificant(object, cutoff=1, \dots)}{Compute a vector
      that selects significant values}
    \item{countSignificant(object, cutoff=1, \dots)}{Count the number of
      significant values}
  }
}
\value{
  \code{summary} returns an object of class \code{\link{SamSummary}}.

  \code{selectSignificant} returns a vector of logical values.

  \code{countSignificant} returns an integer.
}
\references{
  Tusher VG, Tibshirani R, Chu G.\cr
  \emph{Significance analysis of microarrays applied to the ionizing radiation
  response.}\cr
  Proc Natl Acad Sci U S A (2001) 98, 5116-5121.
}
\author{
  Kevin R. Coombes \email{krc@silicovore.com}
}
\seealso{
  \code{\link{Bum}},
  \code{\link{MultiTtest}}
}
\examples{
showClass("Sam")
ng <- 10000
ns <- 50
nd <- 100
dat <- matrix(rnorm(ng*ns), ncol=ns)
dat[1:nd, 1:(ns/2)] <- dat[1:nd, 1:(ns/2)] + 2
dat[(nd+1):(2*nd), 1:(ns/2)] <- dat[(nd+1):(2*nd), 1:(ns/2)] - 2
cla <- factor(rep(c('A', 'B'), each=25))

res <- Sam(dat, cla)
plot(res)

plot(res, tracks=1:3)

summary(res)
summary(res, cutoff=2)

a <- summary(res)
plot(a@significant.calls)
plot(a@significant.calls[1:300])

countSignificant(res, 1)
}
\keyword{classes}

