\name{rankSum}
\alias{rankSum}
\title{Wilcoxon Rank-Sum Statistic}
\description{
  Compute the Wilcoxon rank-sum statistic.
}
\usage{
rankSum(data, selector)
}
\arguments{
  \item{data}{numeric vector}
  \item{selector}{logical vector the same length as \code{data}}
}
\details{
  This is an efficient function to compute the value of the Wilcoxon
  rank-sum statistic without the extra overhead of the full
  \code{wilcox.test} function. It is used internally by the
  \code{\link{MultiWilcoxonTest}} class to perform row-by-row Wilcoxon
  tests.
}
\value{
  Returns an integer, the rank-sum of the subset of the
  \code{data} for which the \code{selector} is true. 
}
\author{
  Kevin R. Coombes \email{krc@silicovore.com}
}
\seealso{
  \code{\link{dwil}},
  \code{\link{MultiWilcoxonTest}}
}
\examples{
dd <- rnorm(100)
cc <- rep(c(TRUE, FALSE), each=50)
rankSum(dd, cc)
}
\keyword{htest}

