## -------------------------- Overlapping SNPs ---------------------------------

#  This script focusses on identifying which SNPs are detected by multiple tests

## -----------------------------------------------------------------------------

# load in GLM significant loci 
glm_sig_snps <- glm_sig_scores_patr %>%
  dplyr::filter(`Pr(Chi)` < bon_threshold)

glm_snps_lat <-  c(glm_sig_snps$snp_pos[glm_sig_snps$covariate == 'lat'])
glm_snps_precip_yr <- c(glm_sig_snps$snp_pos[glm_sig_snps$covariate == 'precip_yr'])

alpha <- 0.01
# create vectors of treewas snps
tw_ter_snps_lat <- c(treeWAS_pvals$pos[treeWAS_pvals$lat_p0.05_ter < alpha])
tw_ter_snps_precip_yr <- c(treeWAS_pvals$pos[treeWAS_pvals$precip_yr_p0.05_ter < alpha])
tw_sim_snps_lat <- c(treeWAS_pvals$pos[treeWAS_pvals$lat_p0.05_simu < alpha])
tw_sim_snps_precip_yr <- c(treeWAS_pvals$pos[treeWAS_pvals$precip_yr_p0.05_simu< alpha])
tw_sub_snps_lat <- c(treeWAS_pvals$pos[treeWAS_pvals$lat_p0.05_sub < alpha])
tw_sub_snps_precip_yr <- c(treeWAS_pvals$pos[treeWAS_pvals$precip_yr_p0.05_sub < alpha])

# find max length
max_len <- max(
  length(glm_snps_lat), 
  length(glm_snps_precip_yr), 
  length(tw_ter_snps_lat), 
  length(tw_ter_snps_precip_yr), 
  length(tw_sim_snps_lat), 
  length(tw_sim_snps_precip_yr), 
  length(tw_sub_snps_lat), 
  length(tw_sub_snps_precip_yr)
)

# create a list of the vectors
list_snps <- list(
  glm_snps_lat, glm_snps_precip_yr, 
  tw_ter_snps_lat, tw_ter_snps_precip_yr, 
  tw_sim_snps_lat, tw_sim_snps_precip_yr, 
  tw_sub_snps_lat, tw_sub_snps_precip_yr
)
# create a vector of names
list_snps_names <- c(
  "glm_snps_lat", "glm_snps_precip_yr", 
  "tw_ter_snps_lat", "tw_ter_snps_precip_yr", 
  "tw_sim_snps_lat", "tw_sim_snps_precip_yr", 
  "tw_sub_snps_lat", "tw_sub_snps_precip_yr"
)

# loop through all vectors in the list 
 for(i in c(1:8)){
  
  #length(list_snps[[i]]) <- max_len # assign them all the same length
  
  list_snps[[i]] <- gsub(
    pattern = "pos_",  # replace preffixes
    replacement = "", 
    x = list_snps[[i]] 
  )
  
  names(list_snps)[i] <- list_snps_names[i] # assign names
}

sig_snps <- dplyr::bind_cols(list_snps)

## Intersection Plots ---------------------------------------------------------

install.packages("ggVennDiagram")
library(ggVennDiagram)
library(ggplot2)

# for lat
ggVennDiagram::ggVennDiagram(
  x = list_snps[c(1,3,5,7)],
  label_alpha = 0, 
  show_intersect = TRUE
) +
  ggplot2::scale_fill_gradient(
    low = "deepskyblue4", 
    high = "orchid2"
  ) +
  ggplot2::ggtitle(
    "Overlapping Significant SNPs - LATITUDE"
  )

# for precip
ggVennDiagram::ggVennDiagram(
  x = list_snps[c(2,4,6,8)], 
  label_alpha = 0, 
  show_intersect = TRUE
  #label_geom = "text"
) +
  ggplot2::scale_fill_gradient(
    low = "deepskyblue4", 
    high = "orchid2"
  )+
  ggplot2::ggtitle(
    "Overlapping Significant SNPs - PRECIP_YR"
  )


ggVennDiagram::ggVennDiagram(
  x = sig_snps[,c(1,2,5,6)], 
  label_alpha = 0, 
  show_intersect = TRUE
) +
  ggplot2::scale_fill_gradient(
    low = "deepskyblue4", 
    high = "orchid2"
  )+
  ggplot2::ggtitle(
    "Overlapping Significant SNPs - GLM & SIM"
  )



