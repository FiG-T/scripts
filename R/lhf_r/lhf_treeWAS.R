## ----------------------- Looking to Run treeWAS ------------------------------

# After presenting an (earlier) version of the GLM analysis in the 'Alliance' 
# group meeting there was some skepticism about the results... 

# An alternative (additional) approach using tree-informed GWAS approaches was 
# suggested - this script runs through the process of formatting the data to 
# fit, as well as running the different analyses. 

## -----------------------------------------------------------------------------

## Libraries -------------------------------------------------------------------

library(dplyr)

install.packages("treeWAS")

library(devtools)
remove.packages("withr")
## install treeWAS from github:
remotes::install_github(
  "caitiecollins/treeWAS", 
  build_vignettes = FALSE, # installing vignettes not working
  force = TRUE)

library(treeWAS)

## -----------------------------------------------------------------------------
# this uses the same genotype matrix used in the GLM analysis 
gt_data_bi <- glm_gt_data[,-c(1:2, 4:20)]

# loop through all positions and remove tri-allelic indv. 
for (i in 2:ncol(gt_data_bi)){ # for all positions
  
  gt_data_bi <- gt_data_bi %>%
    filter_at(
      vars(i), # select position
      all_vars(. == 1 | . == 0) # only include rows where the gt is 1 or 0
    )
  
}

# save sample names as a vector
rownames_gt <- gt_data_bi$samples

length(rownames_gt)
 # 21090 indv included. 

# convert to a matrix (from a tibble)
gt_data_bi <- as.matrix(gt_data_bi[,-1])

# define rownames
rownames(gt_data_bi) <- rownames_gt
  # This results in a genotype matrix for each SNP per individual

## Loading in the "phenotype" data ---------------------------------------------

#  Here environmental data is used instead of phenotype... 
#  the lhf_meta2 data is used (as in the GLM approach)

# if required: 
lhf_meta2 <- feather::read_feather(
#  path = "~/Documents/data/lhf_d/lhf_meta2_0.005_data_11_2023.feather"
)

str(lhf_meta2)

# starting off with LAT and PRECIP_YR (as these are used in the GLM approach)

# create a vector for the variate of interest
phen_lat <- c(lhf_meta2$lat)
phen_precip_yr <- c(lhf_meta2$precip_yr)
phen_tmp_max <- c(lhf_meta2$tmp_max)
phen_tmp_min <- c(lhf_meta2$tmp_min)
str(phen_precip_yr)

# add sample names
names(phen_lat) <- c(lhf_meta2$samples)
names(phen_precip_yr) <- c(lhf_meta2$samples)
names(phen_tmp_max) <- c(lhf_meta2$samples)
names(phen_tmp_min) <- c(lhf_meta2$samples)

# remove indv filtered out of genotype data (see above)
phen_lat <- phen_lat[names(phen_lat) %in% rownames_gt]
phen_precip_yr <- phen_precip_yr[names(phen_precip_yr) %in% rownames_gt]
phen_tmp_max <- phen_tmp_max[names(phen_tmp_max) %in% rownames_gt]
phen_tmp_min <- phen_tmp_min[names(phen_tmp_min) %in% rownames_gt]

# check distributions
hist(phen_lat)              # NOT UNIFORM
hist(phen_precip_yr)        # NOT UNIFORM.  Left skew (can increase FDR)
hist(phen_tmp_max)
hist(phen_tmp_min)

# As this data is not uniform this may lead to false positives.  This can be 
# dealt with in a manner of ways including converting to rank (and I suspect 
# downsampling).  For now I will convert to rank as I want to use the same tree
# as in the GLM approach. 

# convert to rank 
phen_lat_rank <- rank(
  phen_lat, 
  ties.method = "average"
)
hist(phen_lat_rank)  # More uniform, a few outliers present

phen_precip_yr_rank <- rank(
  phen_precip_yr, 
  ties.method = "average"
)
hist(phen_precip_yr_rank)  # More uniform - still a number of outliers 

phen_tmp_max_rank <- rank(
  phen_tmp_max, 
  ties.method = "average"
)
hist(phen_tmp_max_rank)

phen_tmp_min_rank <- rank(
  phen_tmp_min, 
  ties.method = "average"
)
hist(phen_tmp_min_rank)
#
#gt_data_tmp_min <- as.vector(unlist(glm_gt_data$tmp_min))
#gt_data_precip_yr <- as.vector(unlist(glm_gt_data$precip_yr))
# add names
#names(gt_data_tmp_min) <- c(glm_gt_data$samples)
#names(gt_data_precip_yr) <- c(glm_gt_data$samples)

# remove individuals filtered out above... 
#gt_data_tmp_min <- gt_data_tmp_min[names(gt_data_tmp_min) %in% rownames_gt]
#gt_data_precip_yr <- gt_data_precip_yr[names(gt_data_precip_yr) %in% rownames_gt]

# quickly check the distribution (ensure it is not left-skewed)
#hist(gt_data_tmp_min)
#hist(gt_data_precip_yr)
#nrow(gt_data_bi)
#length(rownames_gt)

#length(gt_data_tmp_min)

# ----------------------------------------------------------------------
# note: no downsampling is used at this stage
# ----------------------------------------------------------------------

# Create test dataset ----------------------------------------------------------

# sample positions
test_treeWAS_snps <- sample(
  1:ncol(gt_data_bi), 
  100, 
  replace = FALSE
)
# sample individuals
test_treeWAS_indv <- sample(
  1:nrow(gt_data_bi), 
  4000, 
  replace = FALSE
)
# create test matrix
test_treeWAS <- gt_data_bi[
  c(test_treeWAS_indv), 
  #c(test_treeWAS_snps)
  ]

# get sample names
test_treeWAS_indv <- rownames(gt_data_bi)[test_treeWAS_indv]

#test_treeWAS <- gt_data_bi[c(1:20), c(1:20)]

# create test vector
test_treeWAS_data_tmp_min <- gt_data_tmp_min[names(gt_data_tmp_min) %in% test_treeWAS_indv]

## Running treeWAS -------------------------------------------------------------

# Note: As there are a very large number of samples the tree takes a LONG time 
# to be constructed.  As I have already built the tree while running an earlier 
# test (see below), I will call that in here rather than building a new tree each 
# time. 

lhf_tree_full <- ape::read.tree( # built in an earlier TreeWAS run
  file = "~/Documents/data/lhf_d/treeWAS_tree_full_122023.txt" 
)

sig_snps_note <- unique(glm_sig_scores_patr[glm_sig_scores_patr$covariate == "lat",]$snp_pos)



# looking at LAT first 
treeWAS_out_full_LAT_bonf_p0.05 <- treeWAS::treeWAS(
  snps = gt_data_bi,              # created above
  phen = phen_lat_rank,           # using ranked data 
  tree = lhf_tree_full,           # loaded above
  #phen.type = "continous",        # specify that the 'phenotype' is a continous variable
  test = c(                       # specify which association tests to run
    "terminal",       # broad patterns based on branch tips only
    "simultaneous",   # branch specific changes in phen and geno
    "subsequent"#,     # broad patterns from branch nodes and tips
    #"cor"             # looks for "simple" correlations
  ), 
  correct.prop = TRUE,       # correct for skewed phenotype distributions
  #snps.reconstruction = "ML",  # how to construct the ancestral state data
  #snps.sim.reconstruction = "ML",
 # phen.reconstruction = "ML", 
  #na.rm = TRUE, 
  p.value = 0.05,      # the significance threshold to use (same here as GLM)
  p.value.correct = "bonf", # how to correct for multiple testing
  plot.tree = FALSE, 
  plot.dist = TRUE, 
  snps.assoc = sig_snps_note  # snps to be marked in plots 
)

treeWAS_out_full_LAT_FDR_p0.05 <- treeWAS::treeWAS(
  snps = gt_data_bi,              # created above
  phen = phen_lat_rank,           # using ranked data 
  tree = lhf_tree_full,           # loaded above
  test = c(                       # specify which association tests to run
    "terminal",       # broad patterns based on branch tips only
    "simultaneous",   # branch specific changes in phen and geno
    "subsequent"#,     # broad patterns from branch nodes and tips
    #"cor"             # looks for "simple" correlations
  ), 
  correct.prop = TRUE,       # correct for skewed phenotype distributions
  #snps.reconstruction = "ML",  # how to construct the ancestral state data
  #snps.sim.reconstruction = "ML",
  #phen.reconstruction = "ML", 
  #na.rm = TRUE, 
  p.value = 0.05,      # the significance threshold to use (same here as GLM)
  p.value.correct = "FDR", # how to correct for multiple testing
  plot.tree = FALSE, 
  plot.dist = TRUE, 
  snps.assoc = sig_snps_note  # snps to be marked in plots 
)

print(treeWAS_out_full_LAT_FDR_p0.05)

treeWAS_out_full_LAT_p0.05 <- treeWAS::treeWAS(
  snps = gt_data_bi,              # created above
  phen = phen_lat_rank,           # using ranked data 
  tree = lhf_tree_full,           # loaded above
  test = c(                       # specify which association tests to run
    "terminal",       # broad patterns based on branch tips only
    "simultaneous",   # branch specific changes in phen and geno
    "subsequent"#,     # broad patterns from branch nodes and tips
    #"cor"             # looks for "simple" correlations
  ), 
  correct.prop = TRUE,       # correct for skewed phenotype distributions
  p.value = 0.05,      # the significance threshold to use (same here as GLM)
  p.value.correct = FALSE, # how to correct for multiple testing
  plot.tree = FALSE, 
  plot.dist = TRUE, 
  snps.assoc = sig_snps_note  # snps to be marked in plots 
)
print(treeWAS_out_full_LAT_p0.05)

# looking at precip_yr.   ------------------------------------------------------
treeWAS_out_full_PRECIP_YR_bonf_p0.05 <- treeWAS::treeWAS(
  snps = gt_data_bi,              # created above
  phen = phen_precip_yr_rank,           # using ranked data 
  tree = lhf_tree_full,           # loaded above
  #phen.type = "continous",        # specify that the 'phenotype' is a continous variable
  test = c(                       # specify which association tests to run
    "terminal",       # broad patterns based on branch tips only
    "simultaneous",   # branch specific changes in phen and geno
    "subsequent"#,     # broad patterns from branch nodes and tips
    #"cor"             # looks for "simple" correlations
  ), 
  correct.prop = TRUE,       # correct for skewed phenotype distributions
  #snps.reconstruction = "ML",  # how to construct the ancestral state data
  #snps.sim.reconstruction = "ML",
  #phen.reconstruction = "ML", 
  #na.rm = TRUE, 
  p.value = 0.05,      # the significance threshold to use (same here as GLM)
  p.value.correct = "bonf", # how to correct for multiple testing
  plot.tree = FALSE, 
  plot.dist = TRUE, 
  snps.assoc = sig_snps_note  # snps to be marked in plots 
)

treeWAS_out_full_PRECIP_YR_FDR_p0.05 <- treeWAS::treeWAS(
  snps = gt_data_bi,              # created above
  phen = phen_precip_yr_rank,           # using ranked data 
  tree = lhf_tree_full,           # loaded above
  #phen.type = "continous",        # specify that the 'phenotype' is a continous variable
  test = c(                       # specify which association tests to run
    "terminal",       # broad patterns based on branch tips only
    "simultaneous",   # branch specific changes in phen and geno
    "subsequent"#,     # broad patterns from branch nodes and tips
    #"cor"             # looks for "simple" correlations
  ), 
  correct.prop = TRUE,       # correct for skewed phenotype distributions
  #snps.reconstruction = "ML",  # how to construct the ancestral state data
  #snps.sim.reconstruction = "ML",
  #phen.reconstruction = "ML", 
  #na.rm = TRUE, 
  p.value = 0.05,      # the significance threshold to use (same here as GLM)
  p.value.correct = "FDR", # how to correct for multiple testing
  plot.tree = FALSE, 
  plot.dist = TRUE, 
  snps.assoc = sig_snps_note  # snps to be marked in plots 
)

treeWAS_out_full_PRECIP_YR_p0.05 <- treeWAS::treeWAS(
  snps = gt_data_bi,              # created above
  phen = phen_precip_yr_rank,           # using ranked data 
  tree = lhf_tree_full,           # loaded above
  #phen.type = "continous",        # specify that the 'phenotype' is a continous variable
  test = c(                       # specify which association tests to run
    "terminal",       # broad patterns based on branch tips only
    "simultaneous",   # branch specific changes in phen and geno
    "subsequent"#,     # broad patterns from branch nodes and tips
    #"cor"             # looks for "simple" correlations
  ), 
  correct.prop = TRUE,       # correct for skewed phenotype distributions
  #snps.reconstruction = "ML",  # how to construct the ancestral state data
  #snps.sim.reconstruction = "ML",
  #phen.reconstruction = "ML", 
  #na.rm = TRUE, 
  p.value = 0.05,      # the significance threshold to use (same here as GLM)
  p.value.correct = "FALSE", # how to correct for multiple testing
  plot.tree = FALSE, 
  plot.dist = TRUE, 
  snps.assoc = sig_snps_note  # snps to be marked in plots 
)


# looking at maximum temp ------------------------------------------------------
treeWAS_out_full_TMP_MAX_bonf_p0.05 <- treeWAS::treeWAS(
  snps = gt_data_bi,              # created above
  phen = phen_tmp_max_rank,           # using ranked data 
  tree = lhf_tree_full,           # loaded above
  test = c(                       # specify which association tests to run
    "terminal",       # broad patterns based on branch tips only
    "simultaneous",   # branch specific changes in phen and geno
    "subsequent"#,     # broad patterns from branch nodes and tips
    #"cor"             # looks for "simple" correlations
  ), 
  correct.prop = TRUE,       # correct for skewed phenotype distributions
  p.value = 0.05,      # the significance threshold to use (same here as GLM)
  p.value.correct = "bonf", # how to correct for multiple testing
  plot.tree = FALSE, 
  plot.dist = TRUE, 
  snps.assoc = sig_snps_note  # snps to be marked in plots 
)

treeWAS_out_full_TMP_MAX_bonf_p0.05$simultaneous$sig.snps

treeWAS_out_full_TMP_MAX_p0.05 <- treeWAS::treeWAS(
  snps = gt_data_bi,              # created above
  phen = phen_tmp_max_rank,           # using ranked data 
  tree = lhf_tree_full,           # loaded above
  test = c(                       # specify which association tests to run
    "terminal",       # broad patterns based on branch tips only
    "simultaneous",   # branch specific changes in phen and geno
    "subsequent"#,     # broad patterns from branch nodes and tips
    #"cor"             # looks for "simple" correlations
  ), 
  correct.prop = TRUE,       # correct for skewed phenotype distributions
  p.value = 0.05,      # the significance threshold to use (same here as GLM)
  p.value.correct = "bonf", # how to correct for multiple testing
  plot.tree = FALSE, 
  plot.dist = TRUE, 
  filename.plot = "/Users/finleythomas/Library/CloudStorage/OneDrive-UniversityCollegeLondon/Results/lhf/figures/treeWAS_out_full_TMP_MAX_p0.05_01_2024.pdf",
  snps.assoc = sig_snps_note  # snps to be marked in plots 
)

# looking at minimum temp ------------------------------------------------------
treeWAS_out_full_TMP_MIN_bonf_p0.05 <- treeWAS::treeWAS(
  snps = gt_data_bi,              # created above
  phen = phen_tmp_min_rank,           # using ranked data 
  tree = lhf_tree_full,           # loaded above
  test = c(                       # specify which association tests to run
    "terminal",       # broad patterns based on branch tips only
    "simultaneous",   # branch specific changes in phen and geno
    "subsequent"#,     # broad patterns from branch nodes and tips
    #"cor"             # looks for "simple" correlations
  ), 
  correct.prop = TRUE,       # correct for skewed phenotype distributions
  p.value = 0.05,      # the significance threshold to use (same here as GLM)
  p.value.correct = "bonf", # how to correct for multiple testing
  plot.tree = FALSE, 
  plot.dist = TRUE, 
  snps.assoc = sig_snps_note,  # snps to be marked in plots 
  filename.plot = "/Users/finleythomas/Library/CloudStorage/OneDrive-UniversityCollegeLondon/Results/lhf/figures/treeWAS_out_full_TMP_MIN_bonf_p0.05_01_2024.pdf"
)

## try running (without supplying the tree):   --------------------------------

# on test data: 
treeWAS_out <- treeWAS::treeWAS(
  snps = test_treeWAS, 
  phen = test_treeWAS_data_tmp_min, 
  tree = "BIONJ",
  p.value = 0.05, 
  phen.reconstruction = "ML"
)

head(treeWAS_out$dat$tree)

# on full data: (without downsampling)

treeWAS_out_full_tmp_min <- treeWAS::treeWAS(
  snps = gt_data_bi, 
  phen = gt_data_tmp_min, 
  tree = "BIONJ",
  p.value = 0.05, 
  phen.reconstruction = "ML"
)

treeWAS_tree_full <- treeWAS_out_full_tmp_min$dat$tree

ape::write.tree(
  phy = treeWAS_tree_full, 
  file = "~/Documents/data/lhf_d/treeWAS_tree_full_122023.txt"
)

## Analysing TreeWAS outputs --------------------------------------------------

#  Given that Bonferroni is a very strict test, it is not typically used in human 
#  GWAS studies - instead a significance threshold is calculated from the 
#  distribution. 

#  This section is focused on using the calculated p.values to assess significance

## ----------------------------------------------------------------------------

# Starting with LAT & simultaneous scores
tw_p.vals_lat_simu <- treeWAS_out_full_LAT_p0.05$simultaneous$p.vals 
  # NOTE: it does not matter that this had the bonf applied - it does not alter 
  # the p.values themselves

tw_p.vals_lat_simu_sorted <- sort(tw_p.vals_lat_simu)
tw_p.vals_lat_simu_expt <- seq(
  1, length(tw_p.vals_lat_simu)
) / length(tw_p.vals_lat_simu)

# make qqplot
qqplot(
  -log(tw_p.vals_lat_simu_expt), 
  -log(tw_p.vals_lat_simu_sorted)
)
abline(a = 0, b = 1 , col = "darkorchid3")

hist(
  tw_p.vals_lat_simu_sorted, 
  breaks = 25
  )

## Creating a table... 

treeWAS_pvals <- dplyr::tibble(
  pos = names(treeWAS_out_full_LAT_p0.05$terminal$p.vals),
  lat_p0.05_ter = treeWAS_out_full_LAT_p0.05$terminal$p.vals, 
  precip_yr_p0.05_ter = treeWAS_out_full_PRECIP_YR_p0.05$terminal$p.vals,
  lat_p0.05_simu = treeWAS_out_full_LAT_p0.05$simultaneous$p.vals, 
  precip_yr_p0.05_simu = treeWAS_out_full_PRECIP_YR_p0.05$simultaneous$p.vals, 
  lat_p0.05_sub = treeWAS_out_full_LAT_p0.05$subsequent$p.vals, 
  precip_yr_p0.05_sub = treeWAS_out_full_PRECIP_YR_p0.05$subsequent$p.vals
)

str(treeWAS_pvals)
