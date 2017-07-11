\name{MultiWilcoxonTest-class}
\alias{MultiWilcoxonTest}
\alias{MultiWilcoxonTest-class}
\alias{countSignificant,MultiWilcoxonTest-method}
\alias{cutoffSignificant,MultiWilcoxonTest-method}
\alias{hist,MultiWilcoxonTest-method}
\alias{plot,MultiWilcoxonTest,missing-method}
\alias{selectSignificant,MultiWilcoxonTest-method}
\alias{summary,MultiWilcoxonTest-method}
\docType{class}
\title{Class "MultiWilcoxonTest"}
\description{
  The \code{MultiWilcoxonTest} class is used to perform row-by-row Wilcoxon
  rank-sum tests on a data matrix. Significance cutoffs are determined by the
  empirical Bayes method of Efron and Tibshirani.
}
\usage{
MultiWilcoxonTest(data, classes, histsize=NULL)
\S4method{summary}{MultiWilcoxonTest}(object, prior=1, significance=0.9, \dots)
\S4method{hist}{MultiWilcoxonTest}(x, xlab='Rank Sum',
 ylab='Prob(Different | Y)', main='', \dots)
\S4method{plot}{MultiWilcoxonTest,missing}(x, prior=1, significance=0.9,
 ylim=c(-0.5, 1), xlab='Rank Sum', ylab='Prob(Different | Y)', \dots)
\S4method{cutoffSignificant}{MultiWilcoxonTest}(object, prior, significance, \dots)
\S4method{selectSignificant}{MultiWilcoxonTest}(object, prior, significance, \dots)
\S4method{countSignificant}{MultiWilcoxonTest}(object, prior, significance, \dots)
}
\arguments{
  \item{data}{either a data frame or matrix with numeric values, or an
    \code{\link[Biobase:class.ExpressionSet]{ExpressionSet}} as defined
    in the BioConductor tools for analyzing microarray data.}
  \item{classes}{ If \code{data} is a data frame or matrix, then classes
    must be either a logical vector or a factor. If \code{data} is an
    \code{ExpressionSet}, then \code{classes} can be a character string that
    names one of the factor columns in the associated
    \code{\link[Biobase]{phenoData}} subobject.}
  \item{histsize}{An integer; the number of bins used for the histogram
    summarizing the Wilcoxon statistics. When \code{NULL}, each discrete
    rank-sum value gets its own bin.}
  \item{object}{an object of the \code{MultiWilcoxonTest} class.}
  \item{x}{an object of the \code{MultiWilcoxonTest} class.}
  \item{xlab}{character string specifying label for the x axis}
  \item{ylab}{character string specifying label for the y axis}
  \item{ylim}{Plotting limits on the y-axis}
  \item{main}{character string specifying graph title}
  \item{prior}{Prior probability that an arbitrary gene is not differentially
    expressed, or that an arbitrary row does not yield a significant
    Wilcoxon rank-sum statistic. }
  \item{significance}{Desired level of posterior probability}
  \item{\dots}{extra arguments for generic or plotting routines}
}
\section{Creating Objects}{
  As usual, objects can be created by \code{new}, but better methods are
  available in the form of the \code{MultiWilcoxonTest} function. The
  inputs to this function are the same as those used for row-by-row
  statistical tests throughout the ClassComparison package; a detailed
  description can be found in the \code{\link{MultiTtest}} class.

  The constructor computes row-by-row Wilcoxon rank-sum statistics on
  the input \code{data}, comparing the two groups defined by the
  \code{classes} argument. It also estimates the observed and
  theoretical (expected) density functions for the collection of
  rank-sum statistics.

  The additional input argument, \code{histsize} is usually best left to
  its default value. In certain pathological cases, we have found it
  necessary to use fewer bins; one suspects that the underlying model
  does not adequately capture the complexity of those situations.
}
\section{Slots}{
  \describe{
    \item{\code{rank.sum.statistics}:}{numeric vector containing the
      computed rank-sum statistics.}
    \item{\code{xvals}:}{numeric vector, best thought of as the vector
      of possible rank-sum statistics given the sizes of the two groups.}
    \item{\code{theoretical.pdf}:}{numeric vector containing the
      theoretical density function evaluated at the points of
      \code{xvals}.}
    \item{\code{pdf}:}{numeric vector containing the empirical density
      function computed at the points of \code{xvals}.}
    \item{\code{unravel}:}{numeric vector containing a smoothed
      estimate (by Poisson regression using B-splines) of the empirical
      density function evaluated at \code{xvals}.}
    \item{\code{groups}:}{A vector containing the names of the groups
      defined by \code{classes}.}
    \item{\code{call}:}{object of class \code{call} representing the
      function call that created the object.}
  }
}
\section{Methods}{
  \describe{
    \item{summary(object, prior=1, significance=0.9, \dots)}{
      Write out a summary of the object. For a given value of the
      \code{prior} probability of not being differentially expressed and
      a given significance cutoff on the posterior probability, reports
      the cutoffs and number of items in both tails of the distribution.}
    \item{hist(x, xlab='Rank Sum', ylab='Prob(Different|Y)', main='', \dots)}{
      Plot a histogram of the rank-sum statistics, with overlaid curves
      representing the expected and observed distributions.  Colors of
      the curves are controlled by
      \code{\link[oompaBase:oompaColor]{oompaColor$EXPECTED}} and 
      \code{\link[oompaBase:oompaColor]{oompaColor$OBSERVED}}.
    }
    \item{plot(x, prior=1, significance=0.9, ylim=c(-0.5, 1), xlab='Rank
      Sum', ylab='Prob(Different | Y)', \dots)}{
      Plots the posterior probability of being differentially expressed
      for given values of the \code{prior}.  Horizontal lines are added
      at each specified \code{significance} level for the posterior
      probability.
    } 
    \item{cutoffSignificant(object, prior, significance, \dots)}{Determine
    cutoffs on the rank-sum statistic at the desired significance level.}
    \item{selectSignificant(object, prior, significance, \dots)}{Compute a
      logical vector for selecting significant test results.}
    \item{countSignificant(object, prior, significance, \dots)}{Count the
      number of significant test results.}
  }
}
\value{
  The standard methods \code{summary}, \code{hist}, and \code{plot}
  return what you would expect.

  The \code{cutoffSignificant} method returns a list of two
  integers. Rank-sum values smaller than the first value or larger than
  the second value are statistically significant in the sense that their
  posterior probability exceeds the specified \code{significance} level
  given the assumptions about the \code{prior} probability of not being
  significant.

  The \code{selectSignificant} method returns a vector of logical values
  identifying the significant test results, and \code{countSignificant}
  returns an integer counting the number of significant test results.
}
\details{
  See the paper by Efron and Tibshirani.
}
\references{
  Efron B, Tibshirani R.\cr
  \emph{Empirical bayes methods and false discovery rates for microarrays.}\cr
  Genet Epidemiol 2002, 23: 70-86.

  Pounds S, Morris SW.\cr
  \emph{Estimating the occurrence of false positives and false negatives in
  microarray studies by approximating and partitioning the empirical
  distribution of p-values.}\cr
  Bioinformatics. 2003 Jul 1;19(10):1236-42. 
}
\author{
  Kevin R. Coombes \email{krc@silicovore.com}
}
\seealso{
  Implementation is handled in part by the functions \code{\link{dwil}}
  and \code{\link{rankSum}}. The empirical Bayes results for
  alternative tests (such as \code{\link{MultiTtest}}) can be obtained
  using the beta-uniform mixture model in the \code{\link{Bum}} class.
}
\examples{
showClass("MultiWilcoxonTest")
ng <- 10000
ns <- 15
nd <- 200
fake.class <- factor(rep(c('A', 'B'), each=ns))
fake.data <- matrix(rnorm(ng*ns*2), nrow=ng, ncol=2*ns)
fake.data[1:nd, 1:ns] <- fake.data[1:nd, 1:ns] + 2
fake.data[(nd+1):(2*nd), 1:ns] <- fake.data[(nd+1):(2*nd), 1:ns] - 2

a <- MultiWilcoxonTest(fake.data, fake.class)
hist(a)
plot(a)
plot(a, prior=0.85)
abline(h=0)

cutoffSignificant(a, prior=0.85, signif=0.95)
countSignificant(a, prior=0.85, signif=0.95)
}
\keyword{classes}
\keyword{htest}
\keyword{multivariate}

