% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mutPredict.snv.R
\name{mutPredict.snv}
\alias{mutPredict.snv}
\title{Mutation hotspot recurrence prediction for SNV.}
\usage{
mutPredict.snv(
  mask.regions.file = system.file("extdata", "mask_regions.RDS", package = "MutSpot"),
  nucleotide.selected.file,
  continuous.features.selected.snv.url.file,
  discrete.features.selected.snv.url.file,
  sample.specific.features.url.file = NULL,
  snv.mutations.file,
  snv.mutations.file2,
  collapse.regions = FALSE,
  region.of.interest,
  cores = 1,
  snv.model.file,
  min.count = 2,
  hotspot.size = 21,
  genome.size = 2533374732,
  hotspots = TRUE,
  merge.hotspots = TRUE,
  output.dir,
  fdr.cutoff = 0.05,
  color.line = "red",
  color.dots = "maroon1",
  color.muts = "orange",
  top.no = 3,
  promoter.file = system.file("extdata", "Ensembl75.promoters.coding.bed", package =
    "MutSpot"),
  utr3.file = system.file("extdata", "Ensembl75.3UTR.coding.bed", package = "MutSpot"),
  utr5.file = system.file("extdata", "Ensembl75.5UTR.coding.bed", package = "MutSpot"),
  other.annotations = NULL,
  debug = FALSE,
  genome.build = "Ch37"
)
}
\arguments{
\item{mask.regions.file}{Regions to mask in genome, for example, non-mappable regions/immunoglobin loci/CDS regions RDS file, depends on genome build, default file = mask_regions.RDS, Ch37.}

\item{nucleotide.selected.file}{Nucleotide context selected for model RDS file.}

\item{continuous.features.selected.snv.url.file}{Text file containing URLs of SNV continuous features selected for model.}

\item{discrete.features.selected.snv.url.file}{Text file containing URLs of SNV discrete features selected for model.}

\item{sample.specific.features.url.file}{Text file containing URLs of sample specific features, default = NULL.}

\item{snv.mutations.file}{SNV mutations found in region of interest MAF file.}

\item{snv.mutations.file2}{SNV mutations MAF file.}

\item{collapse.regions}{To collapse region of interest or not, default = FALSE.}

\item{region.of.interest}{Region of interest bed file, default = NULL.}

\item{cores}{Number of cores, default = 1.}

\item{snv.model.file}{SNV model.}

\item{min.count}{Minimum number of mutated samples in each hotspot, default = 2.}

\item{hotspot.size}{Size of each hotspot, default = 21.}

\item{genome.size}{Genome size, depends on genome build, default = 2533374732, Ch37.}

\item{hotspots}{To run hotspot analysis or region-based analysis, default = TRUE.}

\item{merge.hotspots}{To plot overlapping hotspots as 1 hotspot or individual hotspots, default = TRUE.}

\item{output.dir}{Save plot in given output directory.}

\item{fdr.cutoff}{FDR cutoff, default = 0.05.}

\item{color.line}{Color given FDR cutoff, default = red.}

\item{color.dots}{Color hotspots that passed given FDR cutoff, default = maroon1.}

\item{color.muts}{Color points, default = orange.}

\item{top.no}{Number of top hotspots to plot, default = 3.}

\item{promoter.file}{Promoter regions bed file, depends on genome build, default file = Ensembl75.promoters.coding.bed, Ch37.}

\item{utr3.file}{3'UTR regions bed file, depends on genome build, default file = Ensembl75.3UTR.coding.bed, Ch37.}

\item{utr5.file}{5'UTR regions bed file, depends on genome build, default file = Ensembl75.5UTR.coding.bed, Ch37.}

\item{other.annotations}{Text file containing URLs of additional regions to be annotated, default = NULL.}

\item{debug}{To delete temporary files or not, default = FALSE.}

\item{genome.build}{Reference genome build, default = Ch37.}
}
\value{
Dataframe containing predicted hotspots significance with hotspots information for SNV/merged/annotated and hotspots manhattan and top hits figures.
}
\description{
Mutation hotspot recurrence prediction for SNV.
}
