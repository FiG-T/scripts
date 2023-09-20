##  ------------------ vcf Visualisation & Correlations  -----------------------

#    This script is designed to use the formatted vcf file (see vcf_processing.R)
#    and the associated metadata (see extract_climatic_variables.R) to explore 
#    allele frequency and environmental data. It is intended to be used as a 
#    precursor to PGLS analysis. 

#  -----------------------------------------------------------------------------
##  Required libraries ---------------------------------------------------------

if (!require("adegenet")) install.packages("adegenet")
if (!require("parallel")) install.packages("parallel")
if (!require("mapplots")) install.packages("mapplots")

library(vcfR)
library(feather)
library(adegenet)
library(parallel)
library(ggplot2)
library(tidyr)
library(dplyr)
library(maps)
library(mapplots)

## Load data -------------------------------------------------------------------

#  read vcf file 
lhf_vcf <- vcfR::read.vcfR(
  file = "~/Documents/data/lhf_d/vcf/snp_sites_filtered_vcf_maf0.005_noRef_092023.recode.vcf", 
  # this file is the same as the one used for vcf processing
  verbose = TRUE
)

#  read in metadata (feather used for speed)
lhf_meta <- feather::read_feather(
  path = "~/Documents/data/lhf_d/lhf_meta_data_09_2023.feather"
)

lhf_meta2 <- feather::read_feather(
  path = "~/Documents/data/lhf_d/lhf_meta2_data_09_2023.feather"
)

## Converting to Genlight data format 

#  Genlight data format is an additional S4 class data format in R used by the 
#  adegenet and poppr packages. 

vcf.gl <- vcfR::vcfR2genlight(
  x = lhf_vcf
) # this will omit any non-biallelic sites

#  Specify the country IDs
adegenet::pop(vcf.gl) <- lhf_meta$country

adegenet::ploidy(vcf.gl) <- 1 # is this a correct assumption?

# view genlight object 
vcf.gl

## Genetic diversity PCA plots -------------------------------------------------

# calculate the eigenvalues and PCs (this may take some time)
vcf.pca <- adegenet::glPca(
  x = vcf.gl, 
  nf = 4, # how many PCs to retain
  parallel = TRUE,
)
vcf.pca

# assign scores to a new tibble
vcf.pca.scores <- tidyr::as_tibble(vcf.pca$scores)

# as the pca takes a long time to run ... save these scores... 
feather::write_feather(
  x = vcf.pca.scores, 
  path = "~/Documents/data/lhf_d/lhf_pca_scores.feather"
)

# add in continental data 
vcf.pca.scores$country <- lhf_meta$country

# add in env data (edit to chose)
vcf.pca.scores$lat <- lhf_meta$lat

# this plots what % of the variance is explained by each PC
graphics::barplot(
  100 * vcf.pca$eig / sum(vcf.pca$eig),
  space = 0.1,
  col = "darkseagreen")

# calculate the sum of all eigenvalues
 eig.total <- sum(vcf.pca$eig)

# check the % for each of the primary PCs
 formatC(head(vcf.pca$eig)[i]/eig.total * 100)
 # where i is the number of the PC you wish to show...
 
## Plotting PCAs --------------------------------------------------------------
  
 ggplot2::ggplot(
   data = vcf.pca.scores, 
   mapping = ggplot2::aes(
     x = PC1, 
     y = PC2, 
     col = country, 
     shape = continent
   )
) +
ggplot2::geom_point(
) #+
#ggplot2::stat_ellipse(
 # level = 0.95, size = 1
#)

## Identifying relevant SNPs ---------------------------------------------------

# We can use the SNPs with the lightest load as a proxy for havinf an influence 
# on the PCs...
 
snp_loadings <- tidyr::as_tibble(
  data.frame(
  vcf.gl@loc.names, 
  vcf.pca$loadings[,1:2]
  )
)

 # rank the snps by their weighting for PC1 (Axis 1)
snp_loadings <- dplyr::arrange(
  .data = snp_loadings, 
  desc(Axis1)
)

## Calculating allele frequencies ----------------------------------------------

## decide how you are grouping the populations (done here by subcontinent)
adegenet::pop(vcf.gl) <- lhf_meta$subcontinent
head(vcf.gl@pop)

# to calculate the allele frequencies: 
pop_diffs <- vcfR::genetic_diff(
  vcf = lhf_vcf, 
  pops = vcf.gl@pop
  # uses Nei's distance as standard
)

# select relevant columns 
allele_freq <- pop_diffs[,c(1:47)] # change ncol to fit the data 

allele_freq <- reshape2::melt(
  allele_freq
)
allele_freq$variable <- gsub(
  pattern = "Hs_", 
  replacement = "", 
  x = allele_freq$variable
)

allele_freq$variable <- gsub(
  pattern = "n_", 
  replacement = "", 
  x = allele_freq$variable
)

# latitudes for each subcontinent: 
subcontinent_coords <- data.frame(
  lhf_meta$subcontinent, lhf_meta$lat, lhf_meta$long
)

# requires dplyr to be loaded...
subcontinent_coords <- subcontinent_coords %>%
  group_by(lhf_meta.subcontinent) %>%
  mutate(lat = mean(lhf_meta.lat)) %>%
  mutate(long = mean(lhf_meta.long))

subcontinent_coords <- subcontinent_coords[,-c(2,3)]
subcontinent_coords <- unique(subcontinent_coords)
names(subcontinent_coords)[1] <- "variable"

## Combining the allele frequency data and latitudes...

allele_freq_subcon <- dplyr::left_join(
  x = allele_freq, 
  y = subcontinent_coords, 
  by = join_by("variable" == "variable")
)

head(allele_freq_subcon)

## Plotting allele frequencies on a map ----------------------------------------

# Specific alleles have to be chosen here... 
# 9616 has been chosen here as it has the highest weighting for PC1 (0.294)

allele_freq_9616 <- allele_freq_subcon[allele_freq_subcon$POS == "215",]
head(allele_freq_9616)


# plot map... 
# if not already in the environment... 
world_coord <- geodata::world(
  resolution = 5, 
  level = 0, 
  path = tempdir()
)

plot(
  world_coord, 
  col = 'snow3', 
  border = "snow3"
)

#maps::map("world", col = "grey85", fill = TRUE, border = FALSE)

for (i in 1:nrow(allele_freq_9616)) {
  mapplots::add.pie(
    z = c(
      allele_freq_9616$value[i], 
      1-allele_freq_9616$value[i]
      ), 
    x = allele_freq_9616$long[i]+sample(-10:10, 1), 
    y = allele_freq_9616$lat[i]+sample(10:5, 1), 
    radius = 5, 
    col = c(
      ggplot2::alpha("cadetblue3", 0.8), ggplot2::alpha("orchid2", 0.8)
    ), 
    labels = allele_freq_9616$variable[i], 
    label.dist = 1.1
  )
}


