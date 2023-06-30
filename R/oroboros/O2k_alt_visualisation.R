################################################################################

#  MSci reanalysis 2023 -- O2 & ROS visualisation ------------------------------

################################################################################

#  The purpose of this script is to visualise oxygen and ROS flux in new and
#  convient visual ways, predominately through PCAs and correlation heatmaps.

#  Written by FiG-T in June 2023

################################################################################

# The following data builds upon the 'O2k_O2_analysis.R' and 'O2k_ROS.R' scripts.

# Check that o2data and rosdata (imported in their respective scripts) have
# matching variables and classes.

str(o2data)
str(rosdata)

# Here sample and subsample are numeric in o2data but characters in rosdata
rosdata$sample <- as.numeric(rosdata$sample)
rosdata$subsample <- as.numeric(rosdata$subsample)

# Now join the two datasets
#  inner_join is used to only keep matching rows (runs measuring ATP will thus
#  be lost)
o2rosdata <- dplyr::inner_join(
  x = rosdata,
  y = o2data,
  by = c("mt", "tr", "age", "sex", "sample", "subsample"),
  suffix = c(".ros", ".o2")
  )

# check the resulting dataframe
str(o2rosdata)

## PCA analysis ---------------------------------------------------------------

## Looking how to impute missing values
# http://juliejosse.com/wp-content/uploads/2018/05/DataAnalysisMissingR.html

library(VIM)
library(FactoMineR)
library(naniar)

# identify where variables are missing
naniar::gg_miss_var(o2rosdata[,c(10:25)])

# impute missing values
ro2_imp <- missMDA::estim_ncpPCA(
  o2rosdata[,c(10:25, 28:32)],   # only inc. continous variables
  method.cv = "Kfold",
  verbose = FALSE
  )

ro2_imp$ncp
  # this will show the number of dimensions imputed

ro2 <- missMDA::imputePCA(
  o2rosdata[,c(10:25)],
  ncp = ro2_imp$ncp) # iterativePCA algorithm

ro2 <- ro2$completeObs
head(ro2)

# values imputed, continue as normal...
ro2 <- stats::prcomp(
  ro2,
  scale. = TRUE
)


library(ggfortify)

ggplot2::autoplot(
  ro2,
  x = 1, y = 2,
  data = o2rosdata,
  colour = "mt",
  shape = "sex",
  label.size = 12,
  loadings = TRUE,
  loadings.colour = "white",
  loadings.label = TRUE,
  loadings.label.colour = "navyblue",
  frame = FALSE,
  frame.type = 'euclid',
  position = position_dodge(2)
 ) +
  scale_colour_manual(
    values = c("steelblue3", "firebrick3", "palegreen4"),
    name = NULL,
    labels = c("WT", "BAR", "COX")
    ) +
  scale_fill_manual(
    values = c("steelblue3", "firebrick3", "palegreen4"),
    name = NULL,
    labels = c("WT", "BAR", "COX")
  )

## Heatmap production ----------------------------------------------------------

# Calculating the correlations between values
#  Hmisc package used as this automatically drops missing pairs and calculates
#  p-values
library(ggplot2)

heater <- function(
        data,
        filter1,
        value1,
        value2,
        value3,
        col = 10,
        col2 = 26,
        tri_plot
  ){

  d <- data %>%
    filter( mt == value1) %>%
    filter( sex == value2 ) %>%
    filter( age == value3 )

  ro2.cor <- Hmisc::rcorr(
    as.matrix(
     d[,col:col2]
     )
  )

  if (value2 == "F"){
   ro2.cor$r[lower.tri(ro2.cor$r)] <- NA
   } else if ( value3 == "D31") {
     ro2.cor$r[upper.tri(ro2.cor$r)] <- NA
     }



  ro2.cor <- reshape2::melt(
    ro2.cor$r,
    na.rm = TRUE
  )

#head(ro2.cor)

p <-  ggplot2::ggplot(
    data = ro2.cor,
    ggplot2::aes(
      x = Var1,
      y = Var2,
      fill = value
      )
    ) +
    geom_tile(
      colour = "white"
    ) +
    scale_fill_gradient2(
      low = "orchid3",
      high = "springgreen4",
      mid = "white",
      midpoint = 0,
      limit = c(-1,1),
      space = "Lab",
      name="Pearson\nCorrelation") +
   ggtitle(
     paste(value1, value2, value3)
   ) +
   theme(
     axis.text.x = element_text(
       angle = 45,
       vjust = 1,
       hjust = 1
       )
    )

print(p)
}

heater(
  o2rosdata,
  #filter1 = "mt",
  value1 = "WT",
  value2 = "F",
  value3 = "D31",

)

par(
  mfrow = c(2,2)
)
