#' Compile covariates matrix for all chromosomes together.
#' 
#' @param mask.regions.file Regions to mask in genome, for example, non-mappable regions/immunoglobin loci/CDS regions RDS file, depends on genome build, default file = mask_regions.RDS, Ch37.
#' @param all.sites.file All sites in whole genome RDS file, depends on genome build, default file = all_sites.RDS, Ch37.
#' @param indel.mutations.file Indel mutations found in region of interest MAF file.
#' @param sample.specific.features.url.file Text file containing sample specific indel features, default = NULL.
#' @param region.of.interest Region of interest bed file, default = NULL.
#' @param cores Number of cores, default = 1.
#' @param indel.mutations.file2 Indel mutations MAF file.
#' @param chrom.dir Directory containing feature matrix of each chromosome.
#' @param genome.build Reference genome build, default = Ch37.
#' @return Full covariates matrix for all chromosomes together.
#' @export
 
mutCovariate.indel.compile = function(mask.regions.file = system.file("extdata", "mask_regions.RDS", package = "MutSpot"), all.sites.file = system.file("extdata", "all_sites.RDS", package = "MutSpot"), indel.mutations.file, sample.specific.features.url.file = NULL, region.of.interest, cores = 1, indel.mutations.file2, chrom.dir, genome.build = "Ch37"){

  # Chr1-X
  chrOrder <- c(paste("chr", 1:22, sep = ""), "chrX")
  if (genome.build == "Ch37") {
    
seqi = GenomeInfoDb::seqinfo(BSgenome.Hsapiens.UCSC.hg19::Hsapiens)[GenomeInfoDb::seqnames(BSgenome.Hsapiens.UCSC.hg19::Hsapiens)[1:23]]
seqnames = GenomeInfoDb::seqnames(GenomeInfoDb::seqinfo(BSgenome.Hsapiens.UCSC.hg19::Hsapiens))[1:23]

  } else if (genome.build == "Ch38") {
  
    seqi = GenomeInfoDb::seqinfo(BSgenome.Hsapiens.UCSC.hg38::Hsapiens)[GenomeInfoDb::seqnames(BSgenome.Hsapiens.UCSC.hg38::Hsapiens)[1:23]]
    seqnames = GenomeInfoDb::seqnames(GenomeInfoDb::seqinfo(BSgenome.Hsapiens.UCSC.hg38::Hsapiens))[1:23]
    
  }
  
# Define masked region i.e. CDS, immunoglobulin loci and nonmappable
mask.regions = readRDS(mask.regions.file)
mask.regions = mask.regions[as.character(GenomeInfoDb::seqnames(mask.regions)) %in% seqnames]

# Define all sites in whole genome
all.sites = readRDS(all.sites.file)
all.sites = all.sites[as.character(GenomeInfoDb::seqnames(all.sites)) %in% seqnames]
all.sites.masked = subtract.regions.from.roi(all.sites, mask.regions, cores = cores)
# sum(as.numeric(GenomicRanges::width(all.sites.masked)))

if (!is.null(region.of.interest)) {
  
  print("specified region")
  
  all.sites = bed.to.granges(region.of.interest)
  all.sites.masked = subtract.regions.from.roi(all.sites, mask.regions, cores = cores)
  all.sites.masked = all.sites.masked[as.character(GenomeInfoDb::seqnames(all.sites.masked)) %in% seqnames]
  
}

# Define indel mutations
maf.mutations <- maf.to.granges(indel.mutations.file)
mut.masked <- maf.mutations[S4Vectors::subjectHits(IRanges::findOverlaps(all.sites.masked, maf.mutations))]
mut.masked.sites = mut.masked
GenomicRanges::start(mut.masked.sites) = GenomicRanges::start(mut.masked.sites) + ceiling((GenomicRanges::width(mut.masked.sites) - 1) / 2)
GenomicRanges::end(mut.masked.sites) = GenomicRanges::start(mut.masked.sites)

# Define indel sample mutation count based on full indel mutations file
maf.mutations2 <- maf.to.granges(indel.mutations.file2)
maf.ind = GenomicRanges::split(maf.mutations2, maf.mutations2$sid)
ind.mut.count = sapply(maf.ind, length)
nind = length(ind.mut.count) 

# Define sample-specific features e.g. CIN index, COSMIC signatures
if (!is.null(sample.specific.features.url.file)) {
  
  sample.specific.features = read.delim(sample.specific.features.url.file, stringsAsFactors = FALSE)
  rownames(sample.specific.features) = as.character(sample.specific.features$SampleID)
  sample.specific.features = sample.specific.features[which(sample.specific.features$SampleID %in% names(ind.mut.count)), ]
  sample.specific.features$ind.mut.count = ind.mut.count[rownames(sample.specific.features)]
  sample.specific.features = sample.specific.features[ ,-which(colnames(sample.specific.features) == "SampleID")]
  
  sample.specific.features2 = parallel::mclapply(1:ncol(sample.specific.features), FUN = function(x) {
    
    print(colnames(sample.specific.features)[x])
    if(class(sample.specific.features[,x]) == "character") {
      
      t = factor(sample.specific.features[ ,x])
      t = model.matrix( ~ t)[ ,-1]
      if (class(t) == "matrix") {
        
      colnames(t) = substr(colnames(t), 2, nchar(colnames(t)))
      colnames(t) = paste(colnames(sample.specific.features)[x], colnames(t), sep = "")
      rownames(t) = rownames(sample.specific.features)
      
      } else {
        
        t = as.data.frame(t)
        colnames(t) = paste(colnames(sample.specific.features)[x], levels(factor(sample.specific.features[ ,x]))[2], sep = "")
        rownames(t) = rownames(sample.specific.features)
        
      }
    } else {
      
      t = as.data.frame(sample.specific.features[ ,x])
      colnames(t) = colnames(sample.specific.features)[x]
      rownames(t) = rownames(sample.specific.features)
      
    }
    return(t)
    
  }, mc.cores = cores)
  
  sample.specific.features=do.call(cbind,sample.specific.features2)
  
} else {
  
  sample.specific.features=as.data.frame(ind.mut.count)
  colnames(sample.specific.features)="ind.mut.count"
  
}

# Remove larger objects before tabulating
sort(sapply(ls(), function(x) { object.size(get(x)) / 10 ^ 6 } ))
rm(list = c("maf.mutations", "maf.ind", "mask.regions", "all.sites", "maf.mutations2"))
gc(reset = T)

files = Sys.glob(paste(chrom.dir, "mutCovariate_indel_chr*.RDS", sep = ""))

# Tabulate covariates for mutations
mut.freq = parallel::mclapply(files, FUN = function(x) readRDS(x)[[1]], mc.cores = cores)

mut.freq = data.table::rbindlist(mut.freq)
mut.freq = data.frame(mut.freq, check.names = F)
mutfreq.aggregated = aggregate(mut.freq$freq, by = mut.freq[ ,colnames(mut.freq) != "freq"], FUN = sum)
mutfreq.aggregated = data.table::setDT(mutfreq.aggregated)
sort(sapply(ls(), function(x) { object.size(get(x)) / 10 ^ 6 } ))
rm(list = c("mut.freq"))
gc(reset = T)

# Tabulate covariates for indels
indel.freq = parallel::mclapply(files, FUN = function(x) readRDS(x)[[2]], mc.cores = cores)

indel.freq = data.table::rbindlist(indel.freq)
indel.freq = data.frame(indel.freq, check.names = F)
indel.aggregated = aggregate(indel.freq$freq, by = indel.freq[ ,colnames(indel.freq) != "freq"], FUN = sum)
indel.aggregated = data.table::setDT(indel.aggregated)
sort(sapply(ls(), function(x) { object.size(get(x)) / 10 ^ 6 } ))
rm(list = c("indel.freq"))
gc(reset = T)

# Tabulate covariates for all sites in whole genome/specified region
genome.freq = parallel::mclapply(files, FUN = function(x) readRDS(x)[[3]], mc.cores = cores)

genome.freq = data.table::rbindlist(genome.freq)
genome.freq = data.frame(genome.freq, check.names = F)
if (ncol(genome.freq) > 2) {
  
  genome.freq.aggregated = aggregate(genome.freq$x, by = genome.freq[ ,colnames(genome.freq) != "x"], FUN = sum)
  
} else {
  
  genome.freq.aggregated = aggregate(genome.freq$x ~ genome.freq[ ,colnames(genome.freq)[1]], FUN = sum)
  colnames(genome.freq.aggregated) = c(colnames(genome.freq)[1], "x")
  
}
genome.freq.aggregated = data.table::setDT(genome.freq.aggregated)
sort(sapply(ls(), function(x) { object.size(get(x)) / 10 ^ 6 } ))
rm(list = c("genome.freq", "files"))
gc(reset = T)

# Add sample-specific features to genome table
if (!is.null(sample.specific.features.url.file)) {
  
  rownames(sample.specific.features) = NULL
  
  nind = nrow(sample.specific.features)
  sample.specific.features = sample.specific.features[rep(1:nrow(sample.specific.features), each = nrow(genome.freq.aggregated)), ]
  
} else {
  
  rownames(sample.specific.features) = NULL
  nind = nrow(sample.specific.features)
  sample.specific.features = sample.specific.features[rep(1:nrow(sample.specific.features), each = nrow(genome.freq.aggregated)),]
  sample.specific.features = as.data.frame(sample.specific.features)
  colnames(sample.specific.features) = "ind.mut.count"
  
}

genome.freq.aggregated = genome.freq.aggregated[rep(1:nrow(genome.freq.aggregated), nind), ]
genome.freq.aggregated = data.frame(genome.freq.aggregated[ ,1:(ncol(genome.freq.aggregated) - 1)], sample.specific.features, tot.count = genome.freq.aggregated[ ,ncol(genome.freq.aggregated):ncol(genome.freq.aggregated)], check.names = FALSE)
if (ncol(genome.freq.aggregated) <= 3) {
  
  colnames(genome.freq.aggregated)[1] = colnames(mutfreq.aggregated)[!colnames(mutfreq.aggregated) %in% c("ind.mut.count", "x")]
  
}
colnames(genome.freq.aggregated)[ncol(genome.freq.aggregated)] = "x.tot"

if (ncol(genome.freq.aggregated) > 2) {
  
  genome.freq.aggregated = aggregate(genome.freq.aggregated$x.tot, by = genome.freq.aggregated[ ,colnames(genome.freq.aggregated) != "x.tot"], FUN = sum)
  
} else {
  
  genome.freq.aggregated = aggregate(genome.freq.aggregated$x.tot ~ genome.freq.aggregated[ ,colnames(genome.freq.aggregated)[1]], FUN = sum)
  colnames(genome.freq.aggregated) = c(colnames(genome.freq.aggregated)[1], "x.tot")
  
}
colnames(genome.freq.aggregated)[ncol(genome.freq.aggregated)] = "x.tot"

genome.freq.aggregated = data.table::setDT(genome.freq.aggregated)
aggregated.table = merge(mutfreq.aggregated, genome.freq.aggregated, all = TRUE)
sort(sapply(ls(), function(x) { object.size(get(x)) / 10 ^ 6 } ))
rm(list = c("genome.freq.aggregated", "mutfreq.aggregated"))
gc(reset = T)
names(aggregated.table)[(ncol(aggregated.table) - 1):ncol(aggregated.table)] = c("mut.count", "tot.count")
aggregated.table[is.na(aggregated.table)] = 0

aggregated.table = merge(aggregated.table, indel.aggregated, all = T)
names(aggregated.table)[ncol(aggregated.table)] = "indel.length"
aggregated.table[is.na(aggregated.table)] = 0

# Non-mutated bases count = tot.count - indel width
aggregated.table$nonmut.count = aggregated.table$tot.count - aggregated.table$indel.length

aggregated.table = aggregated.table[which(aggregated.table$tot.count != 0), ]

return(aggregated.table)

}
