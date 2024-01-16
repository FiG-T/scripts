## ----------------    GLM & Patristic distances    ----------------------------

#  Following lab group discussions it was suggested that I collect individual 
#  genetic distance data (rather than use the population tree) and use this for 
#  the GLM... 

#  This code is largely copied from "lhf_glm.R" with the necessary tweaks to run
#  on the computed partristic distances. 

## -----------------------------------------------------------------------------

# Calculating Patristic distances ----------------------------------------------
# ------------------------------------------------------------------------------

# Note: This is using the tree as supplied by the TreeWAS program. 
# Import tree

lhf_tree_full <- ape::read.tree(
  file = "~/Documents/data/lhf_d/treeWAS_tree_full_122023.txt"
)
  
base_indv <- "KJ185465_Zambia"

# Find the node corresponding to the target individual
target_node <- which(
  lhf_tree_full$tip.label == base_indv
)

# Calculate patristic distances from the target individual to all other tips
patr_dist<- ape::cophenetic.phylo(lhf_tree_full)[target_node, ]

patr_dist_df <- tidyr::tibble(
  sample = names(patr_dist),
  patr_KJ185465 = patr_dist
)

head(patr_dist_df) # check format 

## -----------------------------------------------------------------------------
# Data Wrangling ----------------------------------------------------------------
# ------------------------------------------------------------------------------

# the ID values here should match the names in the lhf_meta files... 
# this means they can be joined together 
glm_gt_data_patr <- dplyr::left_join(
  x = lhf_meta2, 
  y = lhf_gt_t, 
  by = dplyr::join_by(samples == id)
)

# add in the Patristic distance data 
# as you join with the filtered country list - this simultaneously filters out 
# problematic samples... 
#                       ... do you need to do this??? 
glm_gt_data_patr <- dplyr::left_join(
  x = patr_dist_df, 
  y = glm_gt_data_patr, 
  by = dplyr::join_by(sample == samples)
) 
# This results in a combined dataframe 

# format column names 
names(glm_gt_data_patr) <- gsub(
  pattern = "1_", 
  replacement = "pos_", 
  x = names(glm_gt_data_patr)
)

# Convert genotype data to numeric 
for (x in 21:ncol(glm_gt_data_patr)){

col <- names(glm_gt_data_patr)[x]

glm_gt_data_patr[[col]] <- as.numeric(glm_gt_data_patr[[col]])
}

# Scale the values 
col_to_scale <- c(2,5,6,12:20)
for (x in col_to_scale){
  
  col <- names(glm_gt_data_patr)[x]
  
  glm_gt_data_patr[[col]] <- scale(glm_gt_data_patr[[col]])
}

# Save this file 
feather::write_feather(
  x = glm_gt_data_patr, 
  path = "~/Documents/data/lhf_d/lhf_gt_patr_KJ185456_meta.feather"
)


# This file can then be used for the GLMs 
glm_mod_patr <- lme4::glmer( 
  data = glm_gt_data_patr,
  formula = pos_10617 ~ patr_KJ185465 + tmp_min + precip_yr + (1|iso2) ,
  family = "binomial", 
  control = lme4::glmerControl(
    optimizer = "bobyqa", 
    optCtrl = list(maxfun = 100000)
  )
)

summary(glm_mod_patr)

# Running the GLM across multiple sites ----------------------------------------
# ------------------------------------------------------------------------------

# Run this on a small test set first: 
test_snps <- sample(
  22:(ncol(glm_gt_data)-1), 
  2 # number of test samples wanted -2 
)

test_snps <- c(21, test_snps, 466)

for (i in 21:ncol(glm_gt_data_patr)){
  
  library(dplyr)
  
  glm_gt_data_bi <- glm_gt_data_patr %>%
    filter_at(
      vars(i), 
      all_vars(. == 1 | . == 0)
    )
  
  # select position
  snp <- names(  # test data without 2s... 
    glm_gt_data_bi
  )[i]
  
  snp_pos <- stringr::str_extract(
    string = snp, 
    pattern = "\\d+"
  )
  
  # create formula
  formula <- as.formula(
    paste(
      snp,"~ patr_KJ185465 + lat + precip_yr + (1|iso2)"
    )
  )
  
  # run model
  mod <- lme4::glmer( 
    data = glm_gt_data_bi,
    formula = formula ,
    family = "binomial", 
    control = lme4::glmerControl(
      optimizer = "bobyqa", 
      optCtrl = list(maxfun = 10000)
    )
  )
  
  # create anova table:
  chisq_df <- as.data.frame(
    drop1(
      mod, 
      test="Chisq", 
      na.rm = TRUE
    )
  )
  
  # create Null formula
  formula_null <- as.formula(
    paste(
      snp,"~ patr_KJ185465 + (1|iso2)"
    )
  )
  
  # create null model with patristic distance
  null_mod <- lme4::glmer( 
    data = glm_gt_data_bi,
    formula = formula_null ,
    family = "binomial", 
    control = lme4::glmerControl(
      optimizer = "bobyqa", 
      optCtrl = list(maxfun = 10000)
    )
  )
  
  # compare null and full model 
  null_df <- as.data.frame(
    anova(
      null_mod, 
      mod, 
      test = "Chisq"
    )
  )
  
  # calculate overdispersion
  glm_overdisp <- overdisp_fun(mod)
  
  # combine with snp value
  chisq_df <- cbind(
    chisq_df, 
    snp_pos, 
    glm_overdisp[2], 
    null_df$`Pr(>Chisq)`[2]
  )   
  
  # include the covariates
  chisq_df <- chisq_df %>%
    mutate(covariate = rownames(chisq_df))
  
  if (i == 21){
    # for the first SNP make a new table of scores
    chisq_scores_patr <- chisq_df
  } else {
    # for subsequent SNPs append to this table
    chisq_scores_patr <- rbind(
      chisq_scores_patr, 
      chisq_df
    )
  }
  if (i == ncol(glm_gt_data_patr)){
    
    # for the last SNP append then return the table
    chisq_scores_patr$snp_pos <- as.numeric(chisq_scores_patr$snp_pos)
    
    chisq_scores_patr_lat_precip <- chisq_scores_patr
    
    return(chisq_scores_patr_lat_precip)
    return(formula)
  }
  
  message(
    paste(
      snp , " - Chi Squared scores calculated"
    )
  )
  
}

# Formatting the model outputs -------------------------------------------------
# ------------------------------------------------------------------------------

# create a column of names (for plotting later)
chisq_scores_patr_lat_precip$labels <- chisq_scores_patr_lat_precip$snp_pos

# determine the top 10% cutoff
cutoff <- as.numeric(
  quantile(
    chisq_scores_patr_lat_precip$`Pr(Chi)`, 
    0.10, 
    na.rm = TRUE
  )
)
# only include the labels for those above this threshold 
chisq_scores_patr_lat_precip$labels[chisq_scores_patr_lat_precip$`Pr(Chi)` >= cutoff ] <- ""

# rename annoying columns
names(chisq_scores_patr_lat_precip)[c(6,7)] <- c("overdisp", "null_chisq")

chisq_scores_patr_lat_precip$null_label[chisq_scores_patr_lat_precip$null_chisq <= bon_threshold] <- "T"
chisq_scores_patr_lat_precip$null_label[chisq_scores_patr_lat_precip$null_chisq >= bon_threshold] <- "F"

bon_threshold <- 0.05/(79*5) 
# 0.05 : standard threshold significance value 
# 5 : number of predictor variables 

# filter results to neaten plot
glm_sig_scores_patr <- chisq_scores_patr_lat_precip %>%
  filter(null_label == "T") %>%   # only include SNPs where the full model is 
  # significantly better than the null (just patr)
  filter(covariate != "patr_KJ185465") %>%  # remove the points for patr_KJ185465
  # (captured by comparison to the null)
  filter(overdisp >= 0.75 & overdisp <= 1.25) # remove under and overdispersed sites

unique(glm_sig_scores_patr$snp_pos)
## left with: 36 sites


# plotting Chi Squared values --------------------------------------------------
# ------------------------------------------------------------------------------
ggplot2::ggplot(
  data = glm_sig_scores_patr,  # table created above
  mapping = ggplot2::aes(
    x = snp_pos, 
    y = log(`Pr(Chi)`), 
    #y = log(null_chisq),
    colour = covariate
  )
) +
  ggplot2::geom_point(
    # mapping = ggplot2::aes(
    #shape = covariate
    # )
  ) +
  ggplot2::geom_text(
    mapping = ggplot2::aes(
      label = labels
    ), 
    size = 4,
    nudge_x = sample(1:3, 1), 
    nudge_y = 0.3, 
    na.rm = TRUE, 
    show.legend = FALSE
  ) + 
  ggplot2::scale_colour_manual(
    #  values = c("chartreuse4","darkorange3", "deepskyblue2",
    #             "lightgrey", "darkorchid3","orchid1", "black")
    # values = c(
    # #"snow4", 
    #"darkorchid", "firebrick3", "deepskyblue3", 
    #  "darkorange2", "black"
    #   )
    values = c( "snow4",
                "darkorange2","orchid", "darkorchid", "darkorchid4",
                "firebrick3", "deepskyblue4", 
                #"darkorchid", 
                "firebrick3",
                "snow3", "snow4",
                "deepskyblue3",
                "chartreuse3", 
                #"firebrick3", "darkorange2",
                #"orchid4",
                "chartreuse4", "deepskyblue4", "lightgrey", "deepskyblue3"
    )
  ) +
  ggplot2::geom_line(
    y = -1*log(bon_threshold), 
    colour = "black", 
    linewidth = 1
  ) + 
  ggplot2::scale_x_continuous(
    breaks = seq(0,17000, 1000)
  ) +
  ggplot2::ylim(c(0, -30)
  ) +
  ggplot2::ylab(
    "Logged P-value"
  ) +
  ggplot2::geom_segment(
    data = mt_loci_pos,
    ggplot2::aes(
      # x = Starting, 
      x = aln_start,
      # xend = Ending, 
      xend = aln_end,
      y = -25, 
      yend = -25, 
      col = classification
    ),
    size = 4, 
    alpha = 0.6, 
    position = ggplot2::position_jitter(
      height = 1
    )
  ) +
  ggplot2::theme(
    legend.position = "right", 
    axis.line = ggplot2::element_line(
      linewidth = 1, 
      colour = "black"
    ), 
    plot.background = ggplot2::element_rect(
      fill = "snow"
    ), 
    panel.grid = ggplot2::element_line(
      colour = "snow", 
      linetype = "dotdash"
    ),
    panel.grid.major.x = ggplot2::element_line(
      colour = "snow4", 
      linetype = "dashed"
    ), 
    legend.background = ggplot2::element_rect(
      fill = "snow"
    )
  )

# Looking at where these significant hits fall ---------------------------------
# ------------------------------------------------------------------------------
glm_sig_loci_pos_patr <- dplyr::left_join(
  x = glm_sig_scores_patr, 
  y = mt_loci_pos, 
  by = join_by(snp_pos >= aln_start, snp_pos <= aln_end)
)

glm_loci_stat_patr <- glm_sig_loci_pos_patr %>%
  #  filter(covariate != "Residuals") %>% # remove to prevent double counting
  # Note: if multiple covariates filter for a singular one
  filter(`Pr(Chi)` <= bon_threshold) %>%
  group_by(classification, covariate) %>%
  summarise(
    N = n()
  )

# add in the total length
glm_loci_stat_patr <- dplyr::full_join(
  x = glm_loci_stat_patr, 
  y = classification_length, 
  by = join_by(classification)
)

# normalise the significant SNPs by the total length of each category
glm_loci_stat_patr <- glm_loci_stat_patr %>%
  dplyr::mutate(per_snp = (N/total_length)*100)

# convert to factor
glm_loci_stat_patr$classification <- as.factor(glm_loci_stat_patr$classification)

glm_loci_stat_patr$classification <- factor(
  x = glm_loci_stat_patr$classification, 
  levels = c(
    "ATT", "C_I", "C_III", "C_IV", "C_V", "C_R", "NC", "other", "rRNA", "tRNA" 
  )      
)
# check levels
levels(glm_loci_stat_patr$classification)

glm_loci_stat_patr <- glm_loci_stat_patr %>%
  filter(
    classification != "NC" &
    classification != "other" & 
    classification != "NA"
  )

# plot results 
ggplot2::ggplot(
  data = glm_loci_stat_patr, 
  mapping = ggplot2::aes(
    x = covariate, 
    y = per_snp, 
    fill = covariate
  )
) +
  ggplot2::geom_bar(
    stat = "identity"
  ) +
  ggplot2::facet_grid(
    cols = vars(classification)
  ) +
  ggplot2::scale_fill_manual(
    values = c(
      # "snow4","darkorchid", 
      "firebrick3", "deepskyblue4", "darkorange2", "black"
    )
  ) +
  ggplot2::ylab(
    "Percentage of Region with significant SNPs"
  ) +
  #ggplot2::ylim(
  #  c(0,0.5)
  #) +
  ggplot2::theme_minimal(
  ) +
  ggplot2::theme_light(
  ) +
  ggplot2::theme(
    axis.text.x = ggplot2::element_text(
      angle = 55,
      vjust = 0.5,
      hjust = 0.5,
      size = 10
    )
  )

# Plotting overdispersion ratios  ----------------------------------------------
# ------------------------------------------------------------------------------

ggplot2::ggplot(
  data = glm_sig_loci_pos_patr,  
  # so that only a single point is plotted per position
  mapping = ggplot2::aes(
    x = snp_pos, 
    y = overdisp, 
    colour = classification
  )
) +
  ggplot2::geom_point(
  ) +
  ggplot2::ylab(
    "Overdispersion ratio \n sum(resid^2) / DFresid"
  ) +
  ggplot2::theme_bw()

