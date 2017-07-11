\name{dwil}
\alias{dwil}
\title{Wilcoxon Density Function}
\description{
  Computes the density function for the Wilcoxon rank-sum distribution
  without centering.
}
\usage{
dwil(q, m, n)
}
\arguments{
  \item{q}{vector of quantiles}
  \item{m}{number of observations in the first sample}
  \item{n}{number of observations in the second sample}
}
\details{
  Computes the density function for the Wilcoxon rank-sum distribution, using
  exact values when both groups have fewer than 50 items and switching
  to a normal approximation otherwise. It was originally written for
  S-Plus, which still perversely insists that \code{m} and \code{n} must
  be less than 50. The function was retained when the OOMPA library was
  ported to R, since S-Plus keeps the actual rank-sum but R centers the
  distribution at zero. This function encapsulated the difference, allowing
  everything else to continue to work as it had worked previously.

}
\value{
  A vector of the same length as \code{q} containing (approximate or
  exact) values of the density function.
}
\author{
  Kevin R. Coombes \email{krc@silicovore.com}
}
\seealso{
  \code{\link{MultiWilcoxonTest}}
}
\examples{
dwil(51:60, 9, 3)
dwil(51:60, 9, 51)
}
\keyword{distribution}

