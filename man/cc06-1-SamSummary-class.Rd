\name{SamSummary-class}
\alias{SamSummary}
\alias{SamSummary-class}
\alias{show,SamSummary-method}
\docType{class}
\title{Class "SamSummary"}
\description{
  An implementation class. Users are not expected to create these objects
  directly; they are produced as return objects from the summary method
  for \code{Sam}.
}
\section{Slots}{
  \describe{
    \item{\code{fdr}:}{numeric scalar between \code{0} and \code{1} specifying
      the expected false discovery rate}
    \item{\code{hi}:}{Upper threshold for significance}
    \item{\code{lo}:}{Lower threshold for significance}
    \item{\code{cutoff}:}{numeric scalar specified in the call to the
      \code{Sam} \code{summary} method.}
    \item{\code{significant.calls}:}{vector of logical values}
    \item{\code{average.false.count}:}{The average number of false
      positives in the permuted data at this cutoff level.}
  }
}
\section{Methods}{
  \describe{
    \item{show}{\code{signature(object = SamSummary)}:  Print the
      object, which contains a summary of the underlying \code{Sam}
      object.}
  }
}
\author{
  Kevin R. Coombes \email{krc@silicovore.com}
}
\seealso{
 \code{\link{Sam}}
}
\examples{
showClass("SamSummary")
}
\keyword{classes}

