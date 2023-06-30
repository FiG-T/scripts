################################################################################

## ------------ Plots for SMBE2023 conference ----------------------------------

# Drawing data from O2k_O2_analysis.R and O2k_ROS.R

################################################################################

# Set colour palettes

palette1 <- c( "steelblue3", "firebrick3", "palegreen4")
palette1 <- c("turquoise3", "orchid3", "darkolivegreen3")

# Oxygen capacity for NPro_P and NProSGp_P
state.label <- c("NADH pathway", "Maximum Coupled Respiration")
names(state.label) <- c("NPro_P", "NProSGp_P")

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
    values = palette1,
    name = NULL,
    labels = c("WT", "BAR", "COX")
  ) +
  xlab(
    "Mitochondrial Haplotype"
  ) +
  ylab(
   "Oxygen Flux   (pmol·s-1·x-1)"
  ) +
  scale_alpha_discrete(
    range = c(1,0.5),
    name = "Fly age",
    labels = c("10 days", "31 days")
  ) +
  facet_grid(
    cols = vars(state),
    labeller = labeller(
      state = state.label
    )
  ) +
  theme_bw()+
  theme(
    strip.background = element_rect(fill = "skyblue2"),
    axis.text.x = element_text(size = 26),
    axis.text.y = element_text(size = 24),
    axis.title.x = element_text(size = 28),
    axis.title.y = element_text(size = 26),
    strip.text = element_text(size = 26),
    legend.position = "top",
    panel.background = element_rect(fill='transparent'), #transparent panel bg
    plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
    #panel.grid.major = element_blank(), #remove major gridlines
    #panel.grid.minor = element_blank(), #remove minor gridlines
    legend.background = element_rect(fill='transparent'), #transparent legend bg
    legend.box.background = element_rect(fill='transparent') #transparent legend panel
  )

ggplot2::ggsave(
  filename = "oxygenflux_plot.png",
  plot = last_plot(),
  bg = "transparent"
)


# Plotting oxygen flux contributions

contributions <- c("gp_c", "cI_c")

state.label <- c(
  "Complex III Contribution", "Complex I Contribution")
names(state.label) <- contributions

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
    scale_fill_manual(
      values = palette1,
      name = NULL,
      labels = c("WT", "BAR", "COX")
    ) +
    facet_grid(
      cols = vars(state),
      #rows = vars(tr),
      labeller = labeller(
        state = state.label
      )
    ) +
    xlab(
      "Mitochondrial Haplotype"
    ) +
    ylab(
      "Proportional Increase Between \n Respiratory States"
    ) +
    scale_alpha_discrete(
      range = c(1,0.5),
      name = "Fly age",
      labels = c("10 days", "31 days")
    ) +
    theme_bw()+
    theme(
      strip.background = element_rect(fill = "skyblue2"),
      axis.text.x = element_text(size = 26),
      axis.text.y = element_text(size = 24),
      axis.title.x = element_text(size = 28),
      axis.title.y = element_text(size = 26),
      strip.text = element_text(size = 26),
      legend.position = "top",
      panel.background = element_rect(fill='transparent'), #transparent panel bg
      plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
      #panel.grid.major = element_blank(), #remove major gridlines
      #panel.grid.minor = element_blank(), #remove minor gridlines
      legend.background = element_rect(fill='transparent'), #transparent legend bg
      legend.box.background = element_rect(fill='transparent') #transparent legend panel
    )

  print(p)
}

ggplot2::ggsave(
  filename = "contributions_plot.png",
  plot = last_plot(),
  bg = "transparent"
)

# Plotting ROS ----------------------------------------------------------------
# Plotting with mt on the x axis... and states on the grid

state.label <- c("NADH pathway", "Maximum Coupled \nRespiration")
names(state.label) <- c("NPro_P", "NProSGp_P")

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
    values = palette1,
    name = NULL,
    labels = c("WT", "BAR", "COX")
  ) +
  facet_grid(
    cols = vars(state)
  ) +
  facet_grid(
    cols = vars(state),
    #rows = vars(tr),
    labeller = labeller(
      state = state.label
    )
  ) +
  xlab(
    "Mitochondrial Haplotype"
  ) +
  ylab(
    "Hydrogen Peroxide Flux \n(pmol·s-1·x-1)"
  ) +
  scale_alpha_discrete(
    range = c(1,0.5),
    name = "Fly age",
    labels = c("10 days", "31 days")
  ) +
  theme_bw()+
  theme(
    strip.background = element_rect(fill = "rosybrown"),
    axis.text.x = element_text(size = 26),
    axis.text.y = element_text(size = 24),
    axis.title.x = element_text(size = 28),
    axis.title.y = element_text(size = 26),
    strip.text = element_text(size = 26),
    legend.position = "top",
    panel.background = element_rect(fill='transparent'), #transparent panel bg
    plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
    #panel.grid.major = element_blank(), #remove major gridlines
    #panel.grid.minor = element_blank(), #remove minor gridlines
    legend.background = element_rect(fill='transparent'), #transparent legend bg
    legend.box.background = element_rect(fill='transparent') #transparent legend panel
  )

ggplot2::ggsave(
  filename = "ROS_plot.png",
  plot = last_plot(),
  bg = "transparent"
)


## Plotting heatmaps -----------------------------------------------------------

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

  if (value3 == "D10"){
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
  value1 = "COX",
  value2 = "F",
  value3 = "D31",

)


###   Recreating fecundity and survival data:

# Fecundity plot ---------------------------------------------------------------
egg.data <- read.csv("2023_data/eggs.csv")

head(egg.data)

egg.data <- egg.data %>%
  filter(
    diet == "ST"
  ) %>%
  filter(
    day == 6 | day == 35
  )

egg.data$mito <- as.factor(egg.data$mito)
egg.data$mito <- factor(
  egg.data$mito,
  levels = c("WT", "BAR", "COX")
)

ggplot2::ggplot(
  data = egg.data,
  aes(
    x = as.factor(day),
    y = egg,
    fill = mito,
    alpha = as.factor(day)
    )
  ) +
  geom_boxplot(
  ) +
  scale_fill_manual(
    values = palette1,
    name = NULL,
    labels = c("WT", "BAR", "COX")
  ) +
  xlab(
    "Fly Age (Days)"
  ) +
  ylab(
    "Number of Eggs Laid"
  ) +
  scale_alpha_discrete(
    range = c(1,0.5),
    name = "Fly age",
    labels = c("6 days", "35 days")
  ) +
  theme_classic()+
  theme(
    strip.background = element_rect(fill = "rosybrown"),
    axis.text.x = element_text(size = 26),
    axis.text.y = element_text(size = 24),
    axis.title.x = element_text(size = 28),
    axis.title.y = element_text(size = 26),
    strip.text = element_text(size = 26),
    legend.position = "right",
    panel.background = element_rect(fill='transparent'), #transparent panel bg
    plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
    #panel.grid.major = element_blank(), #remove major gridlines
    #panel.grid.minor = element_blank(), #remove minor gridlines
    legend.background = element_rect(fill='transparent'), #transparent legend bg
    legend.box.background = element_rect(fill='transparent') #transparent legend panel
  )

ggplot2::ggsave(
  filename = "egg_plot.png",
  plot = last_plot(),
  bg = "transparent"
)


#  Plotting survival data ------------------------------------------------------
library(readxl)

# import data
surv.data <- read_excel(
  path = "2023_data/female_survival.xlsx",
  sheet = "Sheet1",
  col_names = TRUE
)[-1, c(1:4)]

# change col names
names(surv.data) <- c("day", "WT", "COX", "BAR")

# convert to long form
surv.data_l <- tidyr::pivot_longer(
  data = surv.data,
  cols = 2:4,
  names_to = "mt",
  values_to = "survival"

)
surv.data_l$mt <- as.factor(surv.data_l$mt)
surv.data_l$mt <- factor(
  surv.data_l$mt,
  levels = c("WT", "BAR", "COX")
)

# plot survival curves
ggplot(
  data = surv.data_l,
  aes(
    x = day,
    y = survival,
    colour = mt
    )
  ) +
  geom_point(
    size = 5
  )+
  geom_line(
    size = 1.5
  ) +
  scale_colour_manual(
    values = palette1,
    name = NULL,
    labels = c("WT", "BAR", "COX")
  ) +
  ylab("Survival (%)") +
  xlab("Day")+
  theme_classic()+
  theme(
    axis.text.x = element_text(size = 26),
    axis.text.y = element_text(size = 24),
    axis.title.x = element_text(size = 28),
    axis.title.y = element_text(size = 26),
    strip.text = element_text(size = 26),
    legend.position = "right",
    panel.background = element_rect(fill='transparent'), #transparent panel bg
    plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
    #panel.grid.major = element_blank(), #remove major gridlines
    #panel.grid.minor = element_blank(), #remove minor gridlines
    legend.background = element_rect(fill='transparent'), #transparent legend bg
    legend.box.background = element_rect(fill='transparent') #transparent legend panel
  )

ggplot2::ggsave(
  filename = "survival_plot.png",
  plot = last_plot(),
  bg = "transparent"
)

## Activity plots --------------------------------------------------------------

# import data
act.data <- readxl::read_excel(
  path = "2023_data/activity.xlsx",
  sheet = "Sheet1",
  col_names = TRUE
)

# set very low values to NA
act.data[act.data < 1] <- NA

# Only retain females on control diet at days 10 and 31
act.data <- act.data %>%
  filter(sex == "F") %>%
  filter(treat == "C") %>%
  filter(day != 45)

# Calculate the mean value for each timepoint
act_l <- aggregate(
  act.data[7:50],
  by = list(act.data$day, act.data$mito),
  FUN = "mean",
  na.rm = TRUE
)

# Convert to long format
act_l <- tidyr::pivot_longer(
  data = act_l,
  cols = 3:46,
  names_to = "time",
  values_to = "act"
)

# update names:
names(act_l)[c(1,2)] <- c("day", "mt")

#Plot results
ggplot2::ggplot(
  data = act_l,
  mapping = aes(
    x = as.numeric(time),
    y = act,
    colour = mt,
    #shape = day,
    linetype = as.factor(day)
    )
  ) +
  geom_point(
    stat = "identity"
  ) +
  geom_line() +
  facet_grid(
    rows = vars(mt)
  )

# looking at other activity data:
act.data <- readxl::read_excel(
  path = "2023_data/complete_activity.xlsx",
  sheet = "Sheet1",
  col_names = TRUE
)

act.data <- act.data %>%
  filter(sex == "F") %>%
  filter(treat == "C") %>%
  filter(day != 45)

# reorder levels
act.data$mito <- as.factor(act.data$mito)
act.data$mito <- factor(
  act.data$mito,
  levels = c("WT", "BAR", "COX")
)

act.data$day <- as.factor(act.data$day)
act.data$day <- factor(
  act.data$day,
  levels = c("10", "31")
)

ggplot(
  data = act.data,
  mapping = aes(
    x = as.factor(day),
    y = `DAY`,
    fill = mito,
    alpha = as.factor(day)
    )
  ) +
  scale_alpha_discrete(
    range = c(0.8, 0.6)
  ) +
  geom_boxplot()+
  scale_fill_manual(
    values = palette1
  ) +
  scale_colour_manual(
    values = palette1
  ) +
  ylab("Activity During Daylight Hours \n (No. beams triggered)")+
  xlab("Fly Age (Days")+
  theme_classic() +
  theme(
    axis.text.x = element_text(size = 26),
    axis.text.y = element_text(size = 24),
    axis.title.x = element_text(size = 28),
    axis.title.y = element_text(size = 26),
    strip.text = element_text(size = 26),
    panel.background = element_rect(fill='transparent'), #transparent panel bg
    plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
    #panel.grid.major = element_blank(), #remove major gridlines
    #panel.grid.minor = element_blank(), #remove minor gridlines
    legend.background = element_rect(fill='transparent'), #transparent legend bg
    legend.box.background = element_rect(fill='transparent') #transparent legend panel
  )

ggplot2::ggsave(
  filename = "day_act_plot.png",
  plot = last_plot(),
  bg = "transparent"
)

#run model
act.mod <- lme4::lmer(
  data = act.data,
  `DAY` ~ mito * day + (1|chamber)
  )

# test if significant effect
car::Anova(
  act.mod,
  type = 3,
  test = "F"
)

# post hoc to identify differences
a<- emmeans::emmeans(
  object = act.mod,
  pairwise ~ mito * day
)


 pairs(
  a,
  simple = "mito"
)

p +
  theme(
    panel.background = element_rect(fill='transparent'), #transparent panel bg
    plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
    panel.grid.major = element_blank(), #remove major gridlines
    panel.grid.minor = element_blank(), #remove minor gridlines
    legend.background = element_rect(fill='transparent'), #transparent legend bg
    legend.box.background = element_rect(fill='transparent') #transparent legend panel
  )



