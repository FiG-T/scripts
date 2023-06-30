
#  MSci reanalysis 2023 -- O2 -------------------------------------------------

################################################################################

#  This script is a record of exactly what has been done to re-analyse data from
#  my master's project (last looked at in 2021).

################################################################################

## Oxygen flux data

## Quick summary ###############################################################

#  Some differences observed between groups but few were significant.  Sex had
#  a large effect, with females typically having a higher capacity, this was
#  exacerbated by an age effect.  Females and males trended in different
#  directions over time (females decrease, males increased.)
#  Protein showed marginally lower flux values however these were not
#  statistically significant.
#  WT flies had lower flux values for CI & CII however these results were not
#  statistically significant.  Mt was not found to have a significant effect
#  although a significant effect was found for the sex:age:mt interaction.  In
#  general the variance of the data was very large and not normally distributed.

################################################################################
library(dplyr)

# Calling in raw data from 2 original O2k template files (with data):

O2import(
  c("High P Thorax O2 data.xlsx",  # file 1
  "High P Thorax O2 data-2.xlsx" # file 2
   ),
  rtn_values = "FALSE",  # do return table to local environment.
  rtn_mean = "FALSE",
  output_file = "2023_data/msci_O2_raw.xlsx"
  )
  # output file with 301 rows of data.

## this output file is manually edited to remove Malonate values for D10 and D20
## for batch (sample) 1, as well as D10 for batch 2.  This is as Malonate was not
## correctly added for these runs.  This step will normally not be required.

#  Bring in edited data values:
o2data <- readxl::read_excel("2023_data/msci_O2_raw_edit.xlsx")

# Check the data looks about right:
head(o2data)
str(o2data)

# Separate mt and tr (can be done in updated O2import function)
o2data <- tidyr::separate(
  o2data,
  col = type,
  sep = " ",
  into = c("mt", "tr")
  )
#  Rename columns (canm also be done automatically in new O2import function)
names(o2data) <- c("mt",
                 "tr",
                 "age",
                 "sex",
                 "sample",
                 "subsample",
                 "N_L", "N_P", "NPro_P", "NProS_P", "NProSGp_P",
                 "NProSGp_E", "ProSGp_E", "ProGp_E", "ROX"
)

#  Filtering data to slim it down:  only include D10 and D31.
o2data <- o2data %>%
  dplyr::filter(age != "D20") %>% # need to make more efficient...
  dplyr::filter(age != "D45") %>%
  dplyr::filter(sex == "F")  # focusing on F for poster

#  Reorder factor levels (so that they are the desired order when plotted)
o2data$mt <- as.factor(o2data$mt)
o2data$mt <- factor(
  o2data$mt,
  levels = c("WT", "BAR", "COX")
  )

# Plotting data roughly:
library(ggplot2)

# Create variable of state names
states <- names(o2data)[7:14]
# shorten states to only include NPro_P and NProSGp_P
states <- states[c(3,5)]


# Create long form of data
o2data_l <- tidyr::pivot_longer(
  data = o2data,
  cols = 7:15,       # changed to only include specific cols
  names_to = "state",
  values_to = "flux"
)
head(o2data_l)

# If states not filtered earlier:
o2data_l <- o2data_l %>%
  filter(
    state == "NPro_P" | state == "NProSGp_P"
  )




##  Comparing sexes: ----------------------------------------------------------

# loop through states and plot
for(i in states){
p <-  ggplot(
  data = o2data,
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

# Plotting with states on the x axis...
ggplot2::ggplot(
  data = o2data_l,
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
      fill = "skyblue2"
    )
  )
 #
 # Females higher flux across most states
 #


##  Comparing ages: ----------------------------------------------------------

# loop through states and plot
for(i in states){
  p <-  ggplot(
    data = o2data,
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
  data = o2data_l,
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
      fill = "skyblue2"
    )
  )
#
# similar flux across most states (if only split by age)
#


##  Comparing treatments: ------------------------------------------------------

# loop through states and plot
for(i in states){
  p <-  ggplot(
    data = o2data,
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
        fill = "skyblue2"
      )
    )
  print(p)
}

# Plotting with states on the x axis...
ggplot2::ggplot(
  data = o2data_l,
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
    rows = vars(sex,age)
  ) +
  theme(
    strip.background = element_rect(
      fill = "skyblue2"
    )
  )
#
# generally lower flux in High Protein diet
#

##  Comparing batches: ------------------------------------------------------

# Plotting with states on the x axis...
ggplot2::ggplot(
  data = o2data_l,
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
    rows = vars(age)
  ) +
  theme(
    strip.background = element_rect(
      fill = "skyblue2"
    )
  )
#
# generally similar across batches
#


##  Comparing mitochondria: ----------------------------------------------------

# loop through states and plot
for(i in states){
  p <-  ggplot(
    data = o2data,
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
      labels = c("WT", "BAR", "COX")
    ) +
    facet_grid(
      #rows = vars(sex),
      cols = vars(sex)
    ) +
    theme(
      strip.background = element_rect(
        fill = "skyblue2"
      )
    ) +
    scale_alpha_discrete(
      range = c(1,0.5)
    )
  print(p)
}

# Plotting with states on the x axis...
ggplot2::ggplot(
  data = o2data_l,
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
    rows = vars(sex),
    cols = vars(age)
  ) +
  theme(
    strip.background = element_rect(
      fill = "skyblue2"
    )
  )


# Plotting with mt on the x axis... and states on the grid
ggplot2::ggplot(
  data = o2data_l,
  mapping = aes(
    x = mt,
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
      fill = "skyblue2"
    )
  ) +
  scale_alpha_discrete(
    range = c(1,0.5)
  )


# Creating summary data -------------------------------------------------------

o2_summary <- o2data_l %>%
  group_by(mt, age, sex, state, tr) %>%
  dplyr::summarise(
    N = length(flux),
    mean = mean(flux, na.rm = TRUE),
    sd = sd(flux, na.rm = TRUE),
    se = sd/sqrt(N)
  ) %>%
  dplyr::filter(state != "ROX")

o2_summary$age <- gsub(
  pattern = "D",
  x = o2_summary$age,
  replacement = ""
)

# Plot summary data
for(i in states){
p <- o2_summary %>%
  filter(state == i) %>% # loop through each state
  ggplot2::ggplot(
    mapping = aes(
      x = as.numeric(age),
      y = mean,
      colour = mt,
      shape = tr,
      xmin = 5,   # to move points towards centre of the plot
      xmax = 35
      )
    ) +
  geom_point(
    position = position_dodge(2),
    size = 3
  ) +
  geom_line(
    aes(
      linetype = tr
    ),
    position = position_dodge(2)
  ) +
  geom_errorbar(
    mapping = aes(
      ymin = mean-se,  # NOTE: standard error is used here...
      ymax = mean+se
      ),
    width = 0.3,
    position = position_dodge(2)
  ) +
  facet_grid(
    rows = vars(sex),
    cols = vars(tr)
  ) +
  scale_x_continuous(
   labels = c("", 10, "", 30, "")
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
    values = c("firebrick3", "palegreen4", "steelblue3"),
    name = NULL,
    labels = c("BAR", "COX", "WT")
  ) +
  theme(
    strip.background = element_rect(
      fill = "skyblue2"
    )
  )
print(p)
}

# -----------------------------------------------------------------------------

# Looking at model selection
options(na.action = "na.fail")
states <- states[c(4,5)]

for (i in states){
  mod <- lme4::lmer(
    o2data[[i]] ~ sex + mt + as.factor(sample) + tr + as.factor(age) + (1|subsample),
    data = o2data
  )
  mod <- MuMIn::dredge(mod)

  print(o2data[[i]])
  print(mod)
}

options(na.action = "na.omit")

# Recreate states vector
states <- names(o2data)[7:14]
states <- states[c(3,5)]

# Creating linear models
for( i in states){
lm <- lme4::lmer(
  o2data[[i]] ~  mt * as.factor(age)  + (1|subsample),
  data = o2data
)

a <- car::Anova(
  lm,
  type = 3, # as we have 'repeated' measures and we want to assess interactions
  test = "F"
)

print(a)

a <- emmeans::emmeans(
  object = lm,
   ~  age * mt
)

#a <- pairs(
 # a,
#  simple = "sex"
#)
#print(a)

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

#  looking at F only
for( i in states){
  lm <- lme4::lmer(
    o2data[[i]] ~  mt * as.factor(age)  + (1|subsample),
    data = o2data
  )

  a <- car::Anova(
    lm,
    type = 3, # as we have 'repeated' measures and we want to assess interactions
    test = "F"
  )

  print(a)

  a <- emmeans::emmeans(
    object = lm,
    pairwise ~  age * mt
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

}


  # note: the residuals created by this linear models are close, but not equal
  #       to a normal distribution.

#  Looking at contributions ---------------------------------------------------

#  Calculate relative increases/decreases between states & add new columns
o2data <- o2data %>%
  mutate(pro_c = (NPro_P-N_P)/N_P) %>%
  mutate(s_c = (NProS_P-NPro_P)/NPro_P) %>%
  mutate(gp_c = (NProSGp_P-NProS_P)/NProS_P) %>%
  mutate(adp_c = (N_P-N_L)/N_P) %>%
  mutate(cI_c = (NProSGp_E - ProSGp_E)/ProSGp_E) %>%
  mutate(cII_c = (ProSGp_E - ProGp_E)/ProGp_E)

# Remove outlier and negative values
o2data$pro_c[o2data$pro_c > 1] <- NA
o2data$pro_c[o2data$pro_c < 0] <- NA
o2data$s_c[o2data$s_c > 1] <- NA
o2data$s_c[o2data$s_c < 0] <- NA
o2data$gp_c[o2data$gp_c > 1] <- NA
o2data$gp_c[o2data$gp_c < 0] <- NA
o2data$cI_c[o2data$cI_c > 5] <- NA
o2data$cI_c[o2data$cI_c < 0] <- NA
o2data$cII_c[o2data$cII_c > 0.5] <- NA
o2data$cII_c[o2data$cII_c < 0] <- NA

# convert into long form
o2data_lc <- tidyr::pivot_longer(
  data = o2data,
  cols = 16:21,
  names_to = "state",
  values_to = "contribution"
)

# summarise data into a new table
o2_summary <- o2data_lc %>%
  group_by(mt, sex, age, state) %>%
  dplyr::summarise(
    N = length(contribution),
    mean = mean(contribution, na.rm = TRUE),
    sd = sd(contribution, na.rm = TRUE),
    se = sd/sqrt(N)
  ) %>%
  dplyr::filter(state != "ROX")

o2_summary$age <- gsub(
  pattern = "D",
  x = o2_summary$age,
  replacement = ""
)

contributions <- c("pro_c", "gp_c", "cI_c")
# Plot summary data
for(i in contributions){
  p <- o2_summary %>%
    filter(state == i) %>% # loop through each state
    ggplot2::ggplot(
      mapping = aes(
        x = mt,
        y = mean,
        fill = mt,
        #shape = tr,
        alpha = age,
        xmin = 5,   # to move points towards centre of the plot
        xmax = 35
      )
    ) +
    geom_bar(
      stat = "identity",
      position = position_dodge(0.5),
      width = 0.4
    ) +
    geom_errorbar(
      mapping = aes(
        ymin = mean-se,  # NOTE: standard error is used here...
        ymax = mean+se
      ),
      width = 0.2,
      position = position_dodge(0.5)
    ) +
    ylab(
      "Mean contributions"
    )+
    xlab(
      "Age (days)"
    ) +
    ggtitle(
      i
    ) +
    scale_fill_manual(
      values = c("steelblue3", "firebrick3", "palegreen4"),
      name = NULL,
      labels = c("WT", "BAR", "COX")
    ) +
    scale_alpha_discrete(
      range = c(1, 0.6)
    ) +
    facet_grid(
      cols = vars(state),
      #rows = vars(tr)
    ) +
    theme(
     strip.background = element_rect(
      fill = "skyblue2"
      )
    )

  print(p)
}

contributions <- names(o2data)[16:21]
contributions <-

#  contribution statistics ----------------------------------------------------

for( i in contributions){

  data <- o2data

  lm <- lme4::lmer(
    data[[i]] ~ sex* mt * as.factor(age)  + (1|subsample),
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
     ~ sex*  mt * age
  )

  print(a)

  a <- pairs(
    a,
    simple = "sex"
  )
  #print(a)

  a <- pairs(
    a,
    simple = "age"
  )
  #print(a)

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

  # looking at F only

for( i in contributions){

  data <- o2data %>%
    filter(age == "D10")

  lm <- lme4::lmer(
    data[[i]] ~  mt *  + (1|subsample),
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
    ~  mt
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

