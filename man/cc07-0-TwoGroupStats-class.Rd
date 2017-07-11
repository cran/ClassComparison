\name{TwoGroupStats-class}
\alias{TwoGroupStats}
\alias{TwoGroupStats-class}
\alias{as.data.frame,TwoGroupStats-method}
\alias{plot,TwoGroupStats,missing-method}
\alias{print,TwoGroupStats-method}
\alias{show,TwoGroupStats-method}
\alias{summary,TwoGroupStats-method}
\docType{class}
\title{Class "TwoGroupStats"}
\description{
  Compute row-by-row means and variances for a data matrix
  whose columns belong to two different groups of interest.
}
\usage{
TwoGroupStats(data, classes, name=comparison, name1=A, name2=B)
\S4method{as.data.frame}{TwoGroupStats}(x, row.names=NULL, optional=FALSE)
\S4method{summary}{TwoGroupStats}(object, \dots)
\S4method{print}{TwoGroupStats}(x, \dots)
\S4method{show}{TwoGroupStats}(object)
\S4method{plot}{TwoGroupStats,missing}(x, main=x@name, useLog=FALSE, \dots)
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
  \item{name}{ A character string; the name of this object }
  \item{name1}{ A character string; the name of the first group }
  \item{name2}{ A character string; the name of the second group }
  \item{x}{A \code{TwoGroupStats} object}
  \item{row.names}{See the base version of \code{\link{as.data.frame.default}}}
  \item{optional}{See the base version of \code{\link{as.data.frame.default}}}
  \item{object}{A \code{TwoGroupStats} object}
  \item{main}{Plot title}
  \item{useLog}{a logical flag; should the values be log-transformed
    before plotting?}
  \item{\dots}{The usual extra arguments to generic functions}
}
\details{
  This class was one of the earliest developments in our suite of tools
  to analyze microarrays. Its main purpose is to segregate out the
  preliminary computation of summary statistics on a row-by-row basis,
  along with a set of plots that could be generated automatically and
  used for quality control.
}
\section{Creating Objects}{
  Although objects of the class can be created by a direct call to
  \link[methods]{new}, the preferred method is to use the
  \code{TwoGroupStats} generator. The inputs to this
  function are the same as those used for row-by-row statistical tests
  throughout the ClassComparison package; a detailed description can be
  found in the \code{MultiTtest} class.

  One should note that this class serves as the front end to the
  \code{\link{SmoothTtest}} class, providing it with an interface that
  accepts \code{\link[Biobase:class.ExpressionSet]{ExpressionSet}}
  objects compatible with the other statistical tests in the
  ClassComparison package.
}
\section{Slots}{
  \describe{
    \item{\code{mean1}:}{numeric vector of means in the first group}
    \item{\code{mean2}:}{numeric vector of means in the second group}
    \item{\code{overallMean}:}{numeric vector of overall row means}
    \item{\code{var1}:}{numeric vector of variances in the first group}
    \item{\code{var2}:}{numeric vector of variances in the second group}
    \item{\code{overallVar}:}{numeric vector of variances assuming
      the two groups have the same mean}
    \item{\code{pooledVar}:}{numeric vector of row-by-row pooled variances,
      assuming the two groups have the same variance but different means}
    \item{\code{n1}:}{numeric scalar specifying number of items in the
      first group}
    \item{\code{n2}:}{numeric scalar specifying number of items in the
      second group}
    \item{\code{name1}:}{character string specifying name of the first group}
    \item{\code{name2}:}{character string specifying name of the second group}
    \item{\code{name}:}{character string specifying name of the object}
  }
}
\section{Methods}{
  \describe{
    \item{as.data.frame(x, row.names=NULL, optional=FALSE)}{Collect the
      numeric vectors from the object into a single dat fame, suitable
      for printing or exporting.}
    \item{summary(object, \dots)}{Write out a summary of the object.}
    \item{print(x, \dots)}{Print the object. (Actually, it only prints a
      summary, since the whole object is almost always more than you
      really want to see. If you insist on printing everything, use
      \code{as.data.frame}.)}
    \item{show(object)}{Print the object (same as print method).)}
    \item{plot(x, main=x@name, useLog=FALSE, \dots)}{This function
      actually produces six different plots of the data, so it is
      usually wrapped by a graphical layout command like
      \code{par(mfrow=c(2,3))}. The first two plots show the relation
      between the mean and standard deviation for the two groups
      separately; the third plot does the same for the overall mean and
      variance.  The fourth plot is a Bland-Altman plot of the difference
      between the means against the overall mean. (In the microarray
      world, this is usually called an M-vs-A plot.)  A loess fit is
      overlaid on the scatter plot, and points outside confidence bounds
      based on the fit are printed in a different color to flag them as
      highly variable. The fifth plot shows a loess fit (with confidence
      bounds) of the difference as a function of the row index (which
      often is related to the geometric position of spots on a
      microarray). Thus, this plot gives a possible indication of regions
      of an array where unusual things happen. The final plot compares
      the overall variances to the pooled variances.}
  }
}
\references{
  Altman DG, Bland JM.\cr
  \emph{Measurement in Medicine: the Analysis of Method Comparison Studies.}\cr
  The Statistician, 1983; 32: 307-317. 
}
\author{
  Kevin R. Coombes \email{krc@silicovore.com}
}
\seealso{
  \code{\link{MultiTtest}},
  \code{\link{SmoothTtest}}
}
\examples{
showClass("TwoGroupStats")
bogus <- matrix(rnorm(30*1000, 8, 3), ncol=30, nrow=1000)
splitter <- rep(FALSE, 30)
splitter[16:30] <- TRUE

x <- TwoGroupStats(bogus, splitter)
summary(x)

opar<-par(mfrow=c(2,3), pch='.')
plot(x)
par(opar)
}
\keyword{classes}
\keyword{hplot}
\keyword{univar}

