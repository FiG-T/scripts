##   -------------------- Processing VCF files ---------------------------------
#                     ----------------------------

#   Visuallising the output from VCFtools (see vcftools_processing.txt for 
#   details of which parameters were used.). This code analyses the allele 
#   frequencies and shows how to import the sample names into R (and process any
#   country names)

#   ----------------------------------------------------------------------------

## Libraries required:    ------
library(dplyr)
#

#  Looking at the amount of missing data ------
#   Not sure why this is all 0...
var_miss <- readr::read_delim(
  "~/Documents/data/lhf_d/vcf/missing_site.lmiss", 
  delim = "\t",
  col_names = c(
    "chr", "pos", "nchr", "nfiltered", "nmiss", "fmiss"
  ), 
  skip = 1)

ggplot2::ggplot(
  data = var_miss, 
  mapping = ggplot2::aes(fmiss)
) + 
ggplot2::geom_density(
  fill = "orchid3", 
  colour = "black", 
  alpha = 0.3)
## no missing data is reported...? 

## Looking at allele frequencies: -----
var_freq <- readr::read_delim(
  file = "~/Documents/data/lhf_d/vcf/lhf_allele_freq_nobase.frq", 
  delim = "\t", 
  col_names = c("chr", "pos", "nalleles", "nchr", "a1", "a2", "a3"), 
  skip = 1
)

# to get the frequency of the minor allele...
var_freq$maf <- var_freq %>% 
  select(a1, a2,, a3) %>% 
  apply(1, function(z) min(z, na.rm = TRUE))

ggplot2::ggplot(
  data = var_freq, 
  mapping = ggplot2::aes(maf)
) + 
  ggplot2::geom_density(
    fill = "orchid3", 
    colour = "black", 
    alpha = 0.3
  ) 

# to get the frequency of the maximum allele...

var_freq$maxmaf <- var_freq %>% 
  select(a1, a2, a3) %>% 
  apply(1, function(z) max(z, na.rm = TRUE))

# to plot: 

ggplot2::ggplot(
  data = var_freq, 
  mapping = ggplot2::aes(maxmaf)
) + 
  ggplot2::geom_density(
    fill = "orchid3", 
    colour = "black", 
    alpha = 0.3
  ) 

summary(var_freq$maf)

## generating a list of sample names -----

#  using bcftools (in the terminal)
'bcftools query -l snp_sites_filtered_vcf_maf0.005_092023.recode.vcf > 
lhf_filtered_maf0.005_sampleNames.txt'

# import into R
lhf_names <- readr::read_delim(
  file = "~/Documents/data/lhf_d/vcf/lhf_filtered_maf0.005_sampleNames.txt", 
  delim = "/t", 
  col_names = "samples"
)

str(lhf_names)

lhf_names <- tidyr::separate(
  data = lhf_names, 
  col = samples, 
  into = c("acc", "a", "b", "c", "d" , "e", "f"), 
  sep = "_"
) 
lhf_names <- tidyr::unite(
  data = lhf_names, 
  col = "country", 
  a, b, c, d, e , f, 
  sep = " ", 
  na.rm = TRUE
)

lhf_names <- unique(lhf_names$country)
lhf_names <- lhf_names[-1]
lhf_names <- sort(lhf_names)
lhf_names <- gsub(
  pattern = "USA", 
  replacement = "United States",
  x = lhf_names
)
lhf_names <- gsub(
  pattern = "Great Britain", 
  replacement = "United Kingdom",
  x = lhf_names
)

