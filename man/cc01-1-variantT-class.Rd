\name{variantT}
\alias{MultiTtestPaired}
\alias{MultiTtestUnequal}
\alias{MultiTtestPaired-class}
\alias{MultiTtestUnequal-class}
\alias{summary,MultiTtestPaired-method}
\alias{summary,MultiTtestUnequal-method}
\docType{class}
\title{Classes for Variant T-tests}
\description{
  Classes to perform row-by-row paired or unequal variance t-tests on
  microarray or proteomics data.
}
\usage{
MultiTtestPaired(data, classes, pairing)
MultiTtestUnequal(data, classes)
\S4method{summary}{MultiTtestPaired}(object, \dots)
\S4method{summary}{MultiTtestUnequal}(object, \dots)
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
  \item{pairing}{A numerical vector indicating which samples are
    paired.}
  \item{object}{A \code{MultiTtest} object}
  \item{\dots}{Unused; optional extra parameters for \code{summary}.}
}
\section{Creating objects}{
  Although objects can be created using \code{new}, the better method is
  to use the \code{MultiTtestPaired} or \code{MultiTtestUnequal}
  functions. In the simplest case, you simply pass in a data matrix
  and a logical vector assigning classes to the columns (and, in the
  case of a paired t-test, a numeric vector describing the pairing), and
  the constructor performs row-by-row two-sample t-tests and computes
  the associated (single test) p-values.  To adjust for multiple
  testing, you can pass the p-values on to the \code{\link{Bum}} class.

  If you use a factor instead of a logical vector, then the t-test
  compares the first level of the factor to everything else.  To handle
  the case of multiple classes, see the \code{\link{MultiLinearModel}}
  class.

  As with other class comparison functions that are part of the OOMPA,
  we can also perform statistical tests on
  \code{\link[Biobase:class.ExpressionSet]{ExpressionSet}} objects from
  the BioConductor libraries. In this case, we pass in an
  \code{ExpressionSet} object along with the name of a factor to use for
  splitting the data.
}
\section{Extends}{
Both classes extend class \code{\link{MultiTtest}}, directly. See that
class for descriptions of the inherited methods and slots.
}
\section{Slots}{
  \describe{
    \item{\code{df}:}{The \code{MultiTtestUnequal} class adds a slot to
      record e gene-by-gene degrees of freedom, which can change along
      with the variances.}
  }
}
\section{Methods}{
  \describe{
    \item{summary}{\code{signature(object = MultiTtestPaired)}:
      Write out a summary of the object. }
    \item{summary}{\code{signature(object = MultiTtestUnequal)}:
      Write out a summary of the object. }
  }
}
\references{OOMPA}
\author{
  Kevin R. Coombes \email{krc@silicovore.com}
}
\seealso{
  \code{\link{Bum}},
  \code{\link{MultiTtest}}
}
\examples{
showClass("MultiTtestPaired")
showClass("MultiTtestUnequal")
ng <- 10000
ns <- 50
dat <- matrix(rnorm(ng*ns), ncol=ns)
cla <- factor(rep(c('A', 'B'), each=25))
res <- MultiTtestUnequal(dat, cla)
summary(res)
hist(res, breaks=101)
plot(res, res@p.values)

pairing <- rep(1:25, 2)
res <- MultiTtestPaired(dat, cla, pairing)
summary(res)
plot(res)
hist(res@p.values, breaks=101)
}
\keyword{classes}
\keyword{multivariate}
\keyword{htest}

