#  MSci reanalysis 2023 -- ROS
################################################################################

#  This script is a record of exactly what has been done to reanalyse data from
#  my master's project (last looked at in 2021).

################################################################################

## Loking at ROS flux

#  Importing and format data --------------------------------------------------
H2O2import(
  path = c("ROS Females High P Thrx.xlsx",
           "ROS Males High P Thrx.xlsx"
           ),
  outfile = "2023_data/ROS_raw.xlsx"
)
#  Bring in edited data values:

rosdata <- readxl::read_excel("2023_data/ROS_raw_edit.xlsx")

# Check the data looks about right:
head(rosdata)
str(rosdata)

rosdata$`Sample type` <- gsub(
  pattern = "WTP",
  replacement = "WT P",
  x = rosdata$`Sample type`
)
rosdata$`Sample type` <- gsub(
  pattern = "Wt",
  replacement = "WT",
  x = rosdata$`Sample type`
)

# Separate mt and tr (can be done in updated O2import function)
rosdata <- tidyr::separate(
  rosdata,
  col = `Sample type`,
  sep = " ",
  into = c("mt", "tr")
)
#  Rename columns
names(rosdata) <- c("sheet", "measure", "unit",
                   "mt",
                   "tr",
                   "age",
                   "sex",
                   "sample",
                   "subsample",
                   "N_L", "N_P", "NPro_P", "NProS_P", "NProSGp_P",
                   "NProSGp_E", "ProSGp_E", "ProGp_E", "ROX"
)

#  Filtering data to slim it down:  only include D10 and D31.
rosdata <- rosdata %>%
  dplyr::filter(age != "D20") %>% # need to make more efficient...
  dplyr::filter(age != "D45") %>%
  dplyr::filter(sex =="F") # for female only analysis! --------------------

rosdata[,c(10:18)][rosdata[,c(10:18)] < 0.005] <- NA

states <- names(rosdata)[10:18]

rosdata$mt <- factor(
  rosdata$mt,
  levels = c("WT", "BAR", "COX")
)

# Create long form of data
rosdata_l <- tidyr::pivot_longer(
  data = rosdata,
  cols = 10:18,
  names_to = "state",
  values_to = "flux"
)
head(rosdata_l)

rosdata_l <- rosdata_l %>%
  filter(
    #state == "N_P" |
      state == "NPro_P" |
      state == "NProSGp_P"
  )

# Plotting data roughly -------------------------------------------------------
library(ggplot2)


##  Comparing sexes: ----------------------------------------------------------
for(i in states){
  p <-  ggplot(
    data = rosdata,
    mapping = aes(
      x = sex,
      y = .data[[i]],
      fill = sex)
  ) +
    geom_boxplot()+
    scale_fill_manual(
      values = c("orchid3", "indianred4"),
      name = NULL,
      labels = c("Females", "Males")
    )
  print(p)
}

ggplot2::ggplot(
  data = rosdata_l,
  mapping = aes(
    x = state,
    y = flux,
    fill = sex)
) +
  geom_boxplot() +
  scale_fill_manual(
    values = c("orchid3", "indianred4"),
    name = NULL,
    labels = c("Females", "Males")
  ) +
  facet_grid(
    rows = vars(mt)
  ) +
  theme(
    strip.background = element_rect(
      fill = "rosybrown"
    )
  )


##  Comparing ages: ----------------------------------------------------------

# loop through states and plot
for(i in states){
  p <-  ggplot(
    data = rosdata,
    mapping = aes(
      x = age,
      y = .data[[i]],
      fill = age)
  ) +
    geom_boxplot()+
    scale_fill_manual(
      values = c("wheat1", "wheat4"),
      name = NULL,
      labels = c("Day 10", "Day 31")
    )
  print(p)
}

# Plotting with states on the x axis...
ggplot2::ggplot(
  data = rosdata_l,
  mapping = aes(
    x = state,
    y = flux,
    fill = age)
) +
  geom_boxplot()+
  scale_fill_manual(
    values = c("wheat1", "wheat4"),
    name = NULL,
    labels = c("Day 10", "Day 31")
  ) +
  facet_grid(
    rows = vars(sex, )
  ) +
  theme(
    strip.background = element_rect(
      fill = "rosybrown"
    )
  )


##  Comparing treatments: ------------------------------------------------------

# loop through states and plot
for(i in states){
  p <-  ggplot(
    data = rosdata,
    mapping = aes(
      x = mt,
      y = .data[[i]],
      fill = tr)
  ) +
    geom_boxplot()+
    scale_fill_manual(
      values = c("aquamarine4", "cyan4"),
      name = NULL,
      labels = c("Control", "High Protein")
    ) +
    facet_grid(
      cols = vars(age)
    ) +
    theme(
      strip.background = element_rect(
        fill = "rosybrown"
      )
    )
  print(p)
}

# Plotting with states on the x axis...
ggplot2::ggplot(
  data = rosdata_l,
  mapping = aes(
    x = state,
    y = flux,
    fill = tr)
) +
  geom_boxplot() +
  scale_fill_manual(
    values = c("aquamarine4", "cyan3"),
    name = NULL,
    labels = c("Control", "High Protein")
  ) +
  facet_grid(
    rows = vars(sex)
  ) +
  theme(
    strip.background = element_rect(
      fill = "rosybrown"
    )
  )



##  Comparing batches: ------------------------------------------------------

# Plotting with states on the x axis...
ggplot2::ggplot(
  data = rosdata_l,
  mapping = aes(
    x = state,
    y = flux,
    fill = as.factor(sample)
  )
) +
  geom_boxplot() +
  scale_fill_manual(
    values = c( "grey25","grey50", "grey75","grey", "grey100" ),
    name = NULL
  ) +
  facet_grid(
    rows = vars(sex)
  ) +
  theme(
    strip.background = element_rect(
      fill = "rosybrown"
    )
  )
#


##  Comparing mitochondria: ----------------------------------------------------

# loop through states and plot
for(i in states){
  p <-  ggplot(
    data = rosdata,
    mapping = aes(
      x = mt,
      y = .data[[i]],
      fill = mt,
      alpha = age
    )
  ) +
    geom_boxplot()+
    scale_fill_manual(
      values = c( "steelblue3", "firebrick3", "palegreen4"),
      name = NULL,
      #labels = c("WT", "BAR", "COX")
    ) +
    scale_alpha_discrete(
      range = c(1,0.5)
    ) +
    facet_grid(
      #rows = vars(sex),
      cols = vars(sex)
    ) +
    theme(
      strip.background = element_rect(
        fill = "rosybrown"
      )
    )
  print(p)
}

# Plotting with states on the x axis...
ggplot2::ggplot(
  data = rosdata_l,
  mapping = aes(
    x = state,
    y = flux,
    fill = mt)
) +
  geom_boxplot() +
  scale_fill_manual(
    values = c( "steelblue3", "firebrick3", "palegreen4"),
    name = NULL,
    labels = c("WT", "BAR", "COX")
  ) +
  facet_grid(
    rows = vars(sex)
  ) +
  theme(
    strip.background = element_rect(
      fill = "rosybrown"
    )
  )

# Plotting with mt on the x axis... and states on the grid
ggplot2::ggplot(
  data = rosdata_l,
  mapping = aes(
    x = as.factor(age),
    y = flux,
    fill = mt,
    alpha = as.factor(age)
  )
) +
  geom_boxplot() +
  scale_fill_manual(
    values = c( "steelblue3", "firebrick3", "palegreen4"),
    name = NULL,
    labels = c("WT", "BAR", "COX")
  ) +
  facet_grid(
    cols = vars(state)
  ) +
  theme(
    strip.background = element_rect(
      fill = "rosybrown"
    )
  ) +
  scale_alpha_discrete(
    range = c(1,0.5)
  )



# Creating summary data
ros_summary <- rosdata_l %>%
  group_by(mt, age, sex, state) %>%
  dplyr::summarise(
    N = length(flux),
    mean = mean(flux, na.rm = TRUE),
    sd = sd(flux, na.rm = TRUE),
    se = sd/sqrt(N)
  )

ros_summary$age <- gsub(
  pattern = "D",
  x = ros_summary$age,
  replacement = ""
)

for(i in states){
  p <- ros_summary %>%
    filter(state == i) %>% # loop through each state
    ggplot2::ggplot(
      mapping = aes(
        x = mt,
        y = mean,
        colour = mt,
        shape = age,
        #xmin = 5,   # to move points towards centre of the plot
        #xmax = 35
      )
    ) +
    geom_point(
      position = position_dodge(0.3),
      size = 3
    ) +
    geom_line(
      aes(
        linetype = sex
      ),
      position = position_dodge(0.3)
    ) +
    geom_errorbar(
      mapping = aes(
        ymin = mean-se,  # NOTE: standard error is used here...
        ymax = mean+se
      ),
      width = 0.3,
      position = position_dodge(0.3)
    ) +
    facet_grid(
      #rows = vars(sex),
      cols = vars(sex)
    ) +
    ylab(
      "Mean specific flux values \n (pmol-s^-1 x^-1)"
    )+
    xlab(
      "Age (days)"
    ) +
    ggtitle(
      i
    ) +
    scale_colour_manual(
      values = c("steelblue3", "firebrick3", "palegreen4"),
      name = NULL,
      labels = c("WT", "BAR", "COX")
    ) +
    theme(
      strip.background = element_rect(
        fill = "rosybrown"
      )
    )
  print(p)
}

#  Stats ---------------------------------------------------------------------

outliers <- rosdata_l %>%
  group_by(state) %>%
  rstatix::identify_outliers(flux)

subset(
  outliers,
  is.extreme == "TRUE"
)

# identify extreme outliers
rosdata_l <- rosdata_l %>%
  filter(
    sheet != "268 WT C"
  ) %>%
  filter(
    sheet != "282 BAR P"
  )
  # remove these then repeat earlier steps...

## Model selection ------------------------------------------------------------

options(na.action = "na.fail")
#states <- states[c(4,5)]

for (i in states){
  rosdata_i <- rosdata %>%
    filter(!is.na(rosdata[[i]]))
  mod <- lme4::lmer(
    rosdata_i[[i]] ~ sex + mt + as.factor(sample) + tr + as.factor(age) + (1|subsample),
    data = rosdata_i
  )
  mod <- MuMIn::dredge(mod)

  print(rosdata[[i]])
  print(mod)
}

options(na.action = "na.omit")

# Print the p-value
print(p_value_mt)
AIC(lm)

# Creating linear models
for( i in states){
  lm <- lme4::lmer(
    rosdata[[i]] ~ sex * age * mt + (1|sample),
    data = rosdata
  )

  a <- car::Anova(
    lm,
    type = 3, # as we have 'repeated' measures and we want to assess interactions
    test = "F"
  )
  print(a)


  a <- emmeans::emmeans(
    object = lm,
    ~ sex * age * mt
  )

  a <- pairs(
    a,
    simple = "sex"
  )
  print(a)

  a <- pairs(
    a,
    simple = "age"
  )
  print(a)

  a <- pairs(
    a,
    simple = "mt"
  )
  print(a)

  a <- emmeans::contrast(
    a,
    interaction = c("pairwise", "consec")
  )

  print(a)
}


# Creating linear models for F only
for( i in states){

  data <- rosdata %>%
    filter(age == "D10")


  lm <- lme4::lmer(
    data[[i]] ~ mt  + (1|sample),
    data = data
  )

  a <- car::Anova(
    lm,
    type = 3, # as we have 'repeated' measures and we want to assess interactions
    test = "F"
  )
  print(a)


  a <- emmeans::emmeans(
    object = lm,
     ~ mt
  )
  print(a)

#  a <- pairs(
#    a,
#    simple = "age"
#  )
#  print(a)

  a <- pairs(
    a,
    simple = "mt"
  )
  print(a)

  a <- emmeans::contrast(
    a,
    interaction = c("pairwise", "consec")
  )

  print(a)
}
