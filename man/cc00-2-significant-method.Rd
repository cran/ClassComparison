\name{significant}
\alias{cutoffSignificant}
\alias{cutoffSignificant-method}
\alias{cutoffSignificant,ANY-method}
\alias{selectSignificant}
\alias{selectSignificant-method}
\alias{selectSignificant,ANY-method}
\alias{countSignificant}
\alias{countSignificant-method}
\alias{countSignificant,ANY-method}
\docType{methods}
\title{Generic Methods for Significance}
\description{
  In the world of multiple testing that is inhabited by most microarray
  or protein profiling experiments, analysts frequently perform separate
  statistical tests for each gene or protein in the experiment.
  Determining cutoffs that achieve statistical significance (in a
  meaningful way) is an inherent part of the procedure. It is then
  common to select the significant items for further processing or for
  preparing reports, or at least to count the number of significant
  items. These generic functions provide a standard set of tools for
  selecting and counting the significant items, which can be used with
  various statistical tests and various ways to account for multiple
  testing.
}
\usage{
\S4method{cutoffSignificant}{ANY}(object, \dots)
\S4method{selectSignificant}{ANY}(object, \dots)
\S4method{countSignificant}{ANY}(object, \dots)
}
\arguments{
  \item{object}{an object that performs multiple statistical tests on
    microarray or proteomics data}
  \item{\dots}{additional arguments affecting these generic methods}
}
\value{
  \code{cutoffSignificant} returns appropriate cutoff values that achieve
  specified significance criteria.

  \code{selectSignificant} returns a logical vector, with \code{TRUE} values
  indicating items that satisfy the cutoff making them statistically
  significant.

  \code{countSignificant} returns an integer, representing the number of
  significant items.
}
\author{
  Kevin R. Coombes \email{krc@silicovore.com}
}
\keyword{methods}
\keyword{htest}

