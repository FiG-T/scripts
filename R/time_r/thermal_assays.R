## Analysis of thermal tolerance data

# Originally written to process results of pilot experiments (completed in
# August 2023)

## Read in data

assay <- readxl::read_excel(
  path = "/Users/finleythomas/Library/CloudStorage/OneDrive-UniversityCollegeLondon/data/time_fitness/Pilot_heat_tolerance.xlsx"
)

# calculate survival fractions
library(dplyr)
assay <- assay %>%
  mutate(
    per_post = post_treatment / start_no
  ) %>%
  mutate(
    per_final= final_survival / start_no
  )

str(assay)

assay$temperature <- as.factor(assay$temperature)
assay$time <- as.factor(assay$time)
assay$batch <- as.factor(assay$batch)

# plotting all points ####

assay %>%
  filter(temperature == 5) %>%
  ggplot2::ggplot(
    mapping = ggplot2::aes(
      x = time,
      y = per_post,
      shape = sex,
      fill = genotype,
      alpha = sex
    )
  ) +
  ggplot2::geom_boxplot(
    position = ggplot2::position_dodge(0.5)
  ) +
  ggplot2::facet_grid(
    cols = vars(temperature)
  ) +
  ggplot2::scale_fill_manual(
    values = c("firebrick2", "deepskyblue2")
  ) +
  ggplot2::theme_minimal()

# filters & subsets ####

assay_nf <- assay %>%
  filter(food == "n")

pilot2 <- assay %>%
  filter(batch==3)

## Create (rough) summary data
assay_summary <- assay %>%
  dplyr::group_by(
    genotype, sex, batch, temperature, time, food
  ) %>%
  dplyr::summarise(
    N = length(start_no),
    mean_post = mean(
      per_post, na.rm = TRUE
    ),
    sd_post = sd(per_post, na.rm = TRUE),
    se_post = sd_post/sqrt(N),
    mean_final = mean(
      per_final,
      na.rm = TRUE
    ),
    sd_final = sd(per_final, na.rm = TRUE),
    se_final = sd_final/sqrt(N)
  )

# Plotting (rough) summary data
library(ggplot2)


assay_summary %>%
  filter(temperature == 1 & time == 1320 |
         temperature == 5 & time == 1500 & batch == 3) %>%
  # temp options for pilot 1 = 1 5 28.5 30 33 35 35.5 37 38.5 40
  # temp options for pilot 2 = 5 36.5 37 37.5
   #filter(food == "n") %>%
   #filter(batch == 1 ) %>%
   #filter(temperature != 5 ) %>%
  # filter(temperature != 1 ) %>%
  # filter(time == 30) %>%
  ggplot2::ggplot(
  mapping = ggplot2::aes(
    x = sex,
    y = mean_post,
    shape = sex,
    colour = genotype
    )
  ) +
  ggplot2::geom_point(
    position = ggplot2::position_dodge(0.5),
    size = 3
  ) +
  ggplot2::labs(
    y = "Survival fraction"
  ) +
  ggplot2::geom_errorbar(
    mapping = ggplot2::aes(
      ymin = mean_post-se_post,
      ymax = mean_post+se_post,
      width = 0.3
    ),
    position = ggplot2::position_dodge(0.5)
  ) +
  geom_point(
    mapping = ggplot2::aes(
      y = mean_final,
      alpha = 0.8,
      size = 2
    ),
    position = position_dodge(0.4)
  ) +
  ggplot2::geom_errorbar(
    mapping = ggplot2::aes(
      ymin = mean_final-se_final,
      ymax = mean_final+se_final,
      width = 0.2,
      alpha = 0.8
    ),
    position = ggplot2::position_dodge(0.4)
  )+
  ggplot2::facet_grid(
    cols = vars(temperature:time:batch),
    rows = vars(food)
  ) +
  ggplot2::scale_colour_manual(
    values = c("deepskyblue2", "firebrick3", "deepskyblue2")
  ) +
  ggplot2::theme_bw()


## for exporting results to a pdf see the markdown document
