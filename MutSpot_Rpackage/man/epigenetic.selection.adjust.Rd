% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/epigenetic.selection.adjust.R
\name{epigenetic.selection.adjust}
\alias{epigenetic.selection.adjust}
\title{Select epigentic features through LASSO.}
\usage{
epigenetic.selection.adjust(
  feature.stabs.snv.file,
  feature.stabs.indel.file,
  continuous.features.selected.snv.url.file,
  discrete.features.selected.snv.url.file,
  continuous.features.selected.indel.url.file,
  discrete.features.selected.indel.url.file,
  new.cutoff.snv,
  new.cutoff.indel,
  top.features = NULL,
  features.sds,
  genomic.features.snv = genomic.features.snv,
  genomic.features.indel = genomic.features.indel,
  genomic.features = genomic.features,
  feature.dir = feature.dir
)
}
\arguments{
\item{feature.stabs.snv.file}{RDS file containing frequency of SNV epigenetic features selected through lasso.}

\item{feature.stabs.indel.file}{RDS file containing frequency of indel epigenetic features selected through lasso.}

\item{continuous.features.selected.snv.url.file}{Text file containing URLs of selected continuous SNV epigentic features.}

\item{discrete.features.selected.snv.url.file}{Text file containing URLs of selected discrete SNV epigenetic features.}

\item{continuous.features.selected.indel.url.file}{Text file containing URLs of selected continuous indel epigenetic features.}

\item{discrete.features.selected.indel.url.file}{Text file containing URLs of selected discrete indel epigenetic features.}

\item{new.cutoff.snv}{Updated frequency cutoff/threshold to determine SNV epigenetic features used in prediction model, ranges from 0.5 to 1.}

\item{new.cutoff.indel}{Updated frequency cutoff/threshold to determine indel epigenetic features used in prediction model, ranges from 0.5 to 1.}

\item{top.features}{Number of top genomic features to select, default = NULL.}

\item{features.sds}{RDS list containing standard deviations of each feature.}

\item{genomic.features.snv}{Text file containing URLs of potential continuous and discrete SNV epigenetic features to select from, default = NULL.}

\item{genomic.features.indel}{Text file containing URLs of potential continuous and discrete indel epigenetic features to select from, default = NULL.}

\item{genomic.features}{Text file containing URLs of potential continuous and discrete SNV and indel epigenetic features to select from, default = NULL.}

\item{feature.dir}{Directory containing binned feature bed files.}
}
\value{
Updated set of SNV/indel continuous and discrete features that passed the new threshold.
}
\description{
Select epigentic features through LASSO.
}
