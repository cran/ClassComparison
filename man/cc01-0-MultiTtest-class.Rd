\name{MultiTtest-class}
\alias{MultiTtest}
\alias{MultiTtest-class}
\alias{hist,MultiTtest-method}
\alias{plot,MultiTtest,missing-method}
\alias{plot,MultiTtest,ANY-method}
\alias{summary,MultiTtest-method}
\alias{as.data.frame,MultiTtest-method}
\docType{class}
\title{Class "MultiTtest"}
\description{
  Class to perform row-by-row t-tests on microarray or proteomics data.
}
\usage{
MultiTtest(data, classes, na.rm=TRUE)
\S4method{summary}{MultiTtest}(object, \dots)
\S4method{as.data.frame}{MultiTtest}(x, row.names=NULL, optional=FALSE, \dots)
\S4method{hist}{MultiTtest}(x, xlab='T Statistics', main=NULL, \dots)
\S4method{plot}{MultiTtest,missing}(x, y, ylab='T Statistics', \dots)
\S4method{plot}{MultiTtest,ANY}(x, y, xlab='T Statistics', ylab=deparse(substitute(y)), \dots)
}
\arguments{
  \item{data}{either a data frame or matrix with numeric values, or an
    \code{\link[Biobase]{ExpressionSet}} as defined
    in the BioConductor tools for analyzing microarray data} 
  \item{classes}{If \code{data} is a data frame or matrix, then classes
    must be either a logical vector or a factor. If \code{data} is an
    \code{ExpressionSet}, then \code{classes} can be a character string that
    names one of the factor columns in the associated
    \code{\link[Biobase]{phenoData}} subobject.}
  \item{na.rm}{logical scalar. If \code{TRUE}, compute t-statistics after
    omitting \code{NA} values from individual rows of the data matrix} 
  \item{object}{object of class \code{MultiTtest}}
  \item{x}{object of class \code{MultiTtest}}
  \item{y}{numeric vector}
  \item{xlab}{character string specifying the label for the x axis}
  \item{ylab}{character string specifying the label for the y axis}
  \item{main}{character string specifying the plot title}
  \item{row.names}{see the base version}
  \item{optional}{see the base version}
  \item{\dots}{extra arguments for generic or plotting routines}
}
\section{Creating objects}{
  Although objects can be created using \code{new}, the preferred method is
  to use the \code{MultiTtest} generator. In the simplest case, you
  simply pass in a data matrix and a logical vector assigning classes to
  the columns, and the constructor performs row-by-row two-sample
  t-tests and computes the associated (single test) p-values. To adjust
  for multiple testing, you can pass the p-values on to the
  \code{\link{Bum}} class.

  If you use a factor instead of a logical vector, then the t-test
  compares the first level of the factor to everything else. To handle
  the case of multiple classes, see the \code{\link{MultiLinearModel}}
  class.

  As with other class comparison functions that are part of the OOMPA,
  we can also perform statistical tests on
  \code{\link[Biobase]{ExpressionSet}} objects from
  the BioConductor libraries. In this case, we pass in an
  \code{ExpressionSet} object along with the name of a factor to use for
  splitting the data.
}
\section{Slots}{
  \describe{
    \item{\code{t.statistics}:}{Object of class \code{numeric}
      containing the computed t-statistics. }
    \item{\code{p.values}:}{Object of class \code{numeric} containing
      the computed p-values. }
    \item{\code{df}:}{Numeric vector of the degrees of freedom per
      gene. Introduced to allow for missing data.}
    \item{\code{groups}:}{Object of class \code{character} containing
      the names of the classes being compared. }
    \item{\code{call}:}{Object of class \code{call} containing the
      function call that created the object.}
  }
}
\section{Methods}{
  \describe{
    \item{summary(object, \dots)}{Write out a summary of the object.}
    \item{hist(x, xlab='T Statistics', main=NULL, \dots)}{Produce a
      histogram of the t-statistics.}
    \item{plot(x)}{Produces a scatter plot of the t-statistics against
      their index.}
    \item{plot(x,y)}{Produces a scatter plot of the t-statistics in the
      object \code{x} against the numeric vector \code{y}.}
  }
}
\value{
  The graphical routines invisibly return the object against which
  they were invoked.
}
\author{
  Kevin R. Coombes \email{krc@silicovore.com}
}
\seealso{
  \code{\link[oompaBase]{matrixT}},
  \code{\link{Bum}},
  \code{\link{Dudoit}},
  \code{\link{MultiLinearModel}}
}
\examples{
showClass("MultiTtest")
ng <- 10000
ns <- 50
dat <- matrix(rnorm(ng*ns), ncol=ns)
cla <- factor(rep(c('A', 'B'), each=25))
res <- MultiTtest(dat, cla)
summary(res)
hist(res, breaks=101)
plot(res)
plot(res, res@p.values)
hist(res@p.values, breaks=101)

dat[1,1] <- NA
mm <- matrixMean(dat, na.rm=TRUE)
vv <- matrixVar(dat, mm, na.rm=TRUE)
tt <- matrixT(dat, cla, na.rm=TRUE)
mtt <- MultiTtest(dat,cla)
}
\keyword{classes}
\keyword{multivariate}
\keyword{htest}

