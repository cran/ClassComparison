\name{TNoM-class}
\alias{TNoM}
\alias{TNoM-class}
\alias{countSignificant,TNoM-method}
\alias{selectSignificant,TNoM-method}
\alias{summary,TNoM-method}
\alias{update,TNoM-method}
\alias{fullTNoM-class}
\alias{hist,fullTNoM-method}
\alias{plot,fullTNoM,missing-method}
\docType{class}
\title{Classes "TNoM" and "fullTNoM"}
\description{
  Implements the "Total Number of Misclassifications" method for finding
  differentially expressed genes.
}
\usage{
TNoM(data, classes, verbose=TRUE)
\S4method{summary}{TNoM}(object, \dots)
\S4method{update}{TNoM}(object, nPerm, verbose=FALSE, \dots)
\S4method{selectSignificant}{TNoM}(object, cutoff, \dots)
\S4method{countSignificant}{TNoM}(object, cutoff, \dots)
\S4method{plot}{fullTNoM,missing}(x, y, \dots)
\S4method{hist}{fullTNoM}(x, \dots)
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
  \item{verbose}{logical scalar. If \code{TRUE}, print out intermediate results}
  \item{object}{object of class \code{TNoM}}
  \item{nPerm}{integer scalar specifying the number of permutations to perform}
  \item{cutoff}{integer scalar}
  \item{x}{object of class \code{fullTNoM}}
  \item{y}{Nothing, since it is supposed to be missing. Changes to the Rd
    processor require documenting the missing entry.}
  \item{\dots}{extra arguments to generic or plotting routines}
}
\details{
  The TNoM method was developed by Yakhini and Ben-Dor and first
  applied in the melanoma microarray study by Bittner and colleagues
  (see references). The goal of the method is to detect genes that are
  differentially expressed between two groups of samples. The idea is
  that each gene serves as a potential classifier to distinguish the two
  groups. One starts by determining an optimal cutoff on the expression
  of each gene and counting the number of misclassifications that gene
  makes. Next, we bin genes based on the total number of
  misclassifications. This distribution can be compared with the expected
  value (by simulating normal data sets of the same size).
  Alternatively, one can estimate the null distribution directly by
  scrambling the sample labels to perform a permutation test.

  The \code{TNoM} constructor computes the optimal cutoffs and the
  misclassification rates. The \code{update} method performs the
  simulations and permutation tests, producing an object of the
  \code{fullTNoM} class.
}
\value{
  \code{summary} returns a \code{\link{TNoMSummary}} object.

  \code{update} returns a \code{fullTNoM} object.

  \code{selectSignificant} returns a vector of logical values.

  \code{countSignificant} returns an integer.
}
\section{Creating Objects}{
  Although objects of the class can be created by a direct call to
  \link[methods]{new}, the preferred method is to use the
  \code{TNoM} generator. The inputs to this function are the same as those
  used for row-by-row statistical tests throughout the \pkg{ClassComparison}
  package; a detailed description can be found in the \code{MultiTtest} class.
}
\section{Slots}{
  Objects of the \code{TNoM} class have the following slots:
  \describe{
    \item{\code{data}:}{The data matrix used to construct the object}
    \item{\code{tnomData}:}{numeric vector, whose length is the number
      of rows in \code{data}, recording the minimum number of
      misclassification  achieved using this data row.} 
    \item{\code{nCol}:}{The number of columns in \code{data}}
    \item{\code{nRow}:}{The number of rows in \code{data}}
    \item{\code{classifier}:}{The classification vector used to create
      the object.}
    \item{\code{call}:}{The function \code{call} that created the object }
  }

  Objects of the \code{fullTNoM} class have the following slots:  
  \describe{
    \item{\code{dex}:}{Numeric vector of the different possible numbers
      of misclassifications}
    \item{\code{fakir}:}{Numeric vector of expected values based on simulations}
    \item{\code{obs}:}{Numeric vector of observed values}
    \item{\code{scr}:}{Numeric vector of values based on a permutation test}
    \item{\code{name}:}{A character string with a name for the object}
  }
}
\section{Methods}{
  Objects of the \code{TNoM} class have the following methods:
  \describe{
    \item{summary(object, \dots)}{Write out a summary of the object,
      including the number of genes achieving each possible number of
      misclassifications.}
    \item{countSignificant(object, cutoff, \dots)}{Count the number of
      significant genes at the given \code{cutoff}.}
    \item{selectSignificant(object, cutoff, \dots)}{Get a vector for
      selecting the number of significant genes at the given
      \code{cutoff}.}
    \item{update(object, nPerm, verbose=FALSE, \dots)}{Perform
      simulation and permutation tests on the \code{TNoM} object.}
  }
  
  Objects of the \code{fullTNoM} class have the following methods:
  \describe{
    \item{plot(x, \dots)}{Plot a summary of the TNoM object. This consists
      of three curves: the observed cumulative number of genes at each
      misclassification level, along with the corresponding numbers
      expected based on simulations or permutation tests.
      The colors of the curves are controlled by the values of
      \code{\link[oompaBase:oompaColor]{oompaColor$OBSERVED}}, 
      \code{\link[oompaBase:oompaColor]{oompaColor$EXPECTED}}, and
      \code{\link[oompaBase:oompaColor]{oompaColor$PERMTEST}} }
    \item{hist(x, \dots)}{Plot a not terribly useful nor informative
      histogram of the results.}
  }
}
\references{
  Bittner M, Meltzer P, Chen Y, Jiang Y, Seftor E, Hendrix M, Radmacher M,
  Simon R, Yakhini Z, Ben-Dor A, Sampas N, Dougherty E, Wang E, Marincola
  F, Gooden C, Lueders J, Glatfelter A, Pollock P, Carpten J, Gillanders
  E, Leja D, Dietrich K, Beaudry C, Berens M, Alberts D, Sondak V.\cr
  \emph{Molecular classification of cutaneous malignant melanoma by gene
  expression profiling.}\cr
  Nature. 2000 Aug 3;406(6795):536-40.
}
\author{
  Kevin R. Coombes \email{krc@silicovore.com}
}
\seealso{
  \code{\link{Bum}},
  \code{\link{MultiTtest}},
  \code{\link{MultiWilcoxonTest}}
}
\examples{
showClass("TNoM")
showClass("fullTNoM")
n.genes <- 200
n.samples <- 10

bogus <- matrix(rnorm(n.samples*n.genes, 0, 3), ncol=n.samples)
splitter <- rep(FALSE, n.samples)
splitter[sample(1:n.samples, trunc(n.samples/2))] <- TRUE

tn <- TNoM(bogus, splitter)
summary(tn)

tnf <- update(tn)
plot(tnf)
hist(tnf)
}
\keyword{classes}
\keyword{multivariate}
\keyword{htest}

