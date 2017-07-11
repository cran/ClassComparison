\name{TNoMSummary-class}
\alias{TNoMSummary}
\alias{TNoMSummary-class}
\alias{show,TNoMSummary-method}
\docType{class}
\title{Class "TNoMSummary"}
\description{
  An implementation class. Users are not expected to create these objects
  directly; they are produced as return objects from the summary method for
  \code{TNoM}.
}
\section{Slots}{
  \describe{
    \item{\code{TNoM}:}{object of class \code{TNoM} ~~ }
    \item{\code{counts}:}{object of class \code{numeric} ~~ }
  }
}
\section{Methods}{
  \describe{
    \item{show}{\code{signature(object = TNoMSummary)}:  Print the
      object, which contains a summary of the underlying \code{TNoM}
      object. In particular, the summary reports the number of genes
      achieving each possible number of misclassifications.}
  }
}
\author{
  Kevin R. Coombes \email{krc@silicovore.com}
}
\seealso{
  \code{\link{TNoM}}
}
\examples{
showClass("TNoMSummary")
}
\keyword{classes}

