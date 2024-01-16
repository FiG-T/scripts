## ---------------    Comparing Environmental Measures    ----------------------

#  Given that there was some debate as to which environmental variable should be
#  used for the analysis it was decided to look into how well the different 
#  options correlate with each other. 

#  Compared are MEAN and CENTROID environmental data points
## -----------------------------------------------------------------------------

#  Importing the data: 

##  Generating centroid data ----------------------------------------- 

centroid_coord <- terra::geom(country_centroids)

centroid_env <- terra::extract(
  x = env_covariates, 
  y = centroid_coord[,3:4]
)

centroid_env$country <- c(country_centroids$NAME_0)

centroid_env <- cbind(
  centroid_env, 
  centroid_coord
)
centroid_env <- centroid_env[,-c(11,12,15)]

names(centroid_env)[c(11,12)] <- c("long", "lat")

# save output file 
feather::write_feather(
  x = centroid_env, 
  path = "~/Documents/data/lhf_d/lhf_country_centroid_metadata_01_2024.feather"
)

# ------------------------------------------------------------------------------
##  Generating mean latitudes by country ---------------------------------------

# extract mean biological variables
 mean_env <-   terra::extract(
  env_covariates, 
  world_coord, 
  mean,
  na.rm = TRUE, 
  weights = TRUE
)

# add in country names
mean_env$country <- c(world_coord$NAME_0)
mean_env$country <- gsub(
  pattern = "Czech Republic", 
  replacement = "Czechia", 
  x = mean_env$country
)


# calculate mean latitudes 
#   (NOTE: in my experience this is a pain to do in terra)
mean_latitudes <- ggplot2::map_data("world") %>%
  group_by(region) %>% # here region actually = country
  dplyr::summarise(
    lat = mean(lat), 
    long = mean(long)
  )

mean_latitudes$iso3 <- countrycode::countrycode(
  mean_latitudes$region, 
  origin = "country.name", 
  destination = "iso3c"
)

mean_latitudes <- dplyr::left_join(
  x = mean_latitudes, 
  y = country_codes, 
  by = join_by(iso3 == ISO3)
)

# combine together 
mean_env <- dplyr::left_join(
  x = mean_env, 
  y = mean_latitudes, 
  by = dplyr::join_by(country == NAME)
)

feather::write_feather(
  x = mean_env, 
  path = "~/Documents/data/lhf_d/lhf_country_mean_metadata_01_2024.feather"
)

# ------------------------------------------------------------------------------
# Adding in Capital cities -----------------------------------------------------

# read in Capital city coordinates 
# [https://gist.github.com/ofou/df09a6834a8421b4f376c875194915c9#file-country-capital-lat-long-population-csv]

# read in coordinates: 

capitals_info <- readr::read_delim(
  "~/Documents/data/lhf_d/country-capital-lat-long-population.csv"
)

# Rename countries in capital datasets 
capitals_info$Country <- gsub(
  x = capitals_info$Country, 
  pattern = "United States of America", 
  replacement = "United States"
)
capitals_info$Country <- gsub(
  x = capitals_info$Country, 
  pattern = "Russian Federation", 
  replacement = "Russia"
)

capitals_info$Country <- gsub(
  x = capitals_info$Country, 
  pattern = "United Republic of Tanzania", 
  replacement = "Tanzania"
)

capitals_coord <- terra::vect(
  x = capitals_info, 
  geom = c("Longitude", "Latitude"),
  crs = '+proj=longlat +datum=WGS84'
)

capitals_coord <- terra::geom(capitals_coord)

capitals_env <- terra::extract(
  x = env_covariates, 
  y = capitals_coord[,3:4]
)

capitals_env <- capitals_env %>%
  dplyr::mutate(country = c(capitals_info$Country))

capitals_env <- cbind(
  capitals_env, 
  capitals_coord[,3:4]
)

# save output file 
feather::write_feather(
  x = capitals_env, 
  path = "~/Documents/data/lhf_d/lhf_country_capitals_metadata_01_2024.feather"
)

# ------------------------------------------------------------------------------


# By centroids: 
env_centroids <- feather::read_feather(
  path = "~/Documents/data/lhf_d/lhf_country_centroid_metadata_01_2024.feather"
) 

# By mean values: 
env_mean <- feather::read_feather(
  path = "~/Documents/data/lhf_d/lhf_country_mean_metadata_01_2024.feather"
) 
env_mean <- env_mean[, -c(12,15:23)]

# By capitals: 
env_capitals <- feather::read_feather(
  path = "~/Documents/data/lhf_d/lhf_country_capitals_metadata_01_2024.feather"
) 
# add suffix
names(env_capitals) <- paste0(
  names(env_capitals), ".cap"
)
str(env_capitals)

# combine together
env_all <- dplyr::full_join(
  x = env_centroids, 
  y = env_mean, 
  by = dplyr::join_by(country == country), 
  suffix = c(".cent", ".mean")
)

env_all <-  dplyr::full_join(
  x = env_all, 
  y = env_capitals, 
  by = dplyr::join_by(country == country.cap)
)


# reorder cols
env_all <- env_all[, c(10, 1:9,11,12,14:35)]

# ------------------------------------------------------------------------------

# plot comparisons 
psych::pairs.panels(
  x = env_all[,c(
    "lat.cent", "lat.mean", "Latitude.cap", 
    "precip_yr.cent", "precip_yr.mean", "precip_yr.cap",
    "long.cent", "long.mean", "Longitude.cap"
  )], 
  lm = TRUE, 
  stars = TRUE, 
  hist.col = "orchid3", 
  cex.cor = 2
)

psych::pairs.panels(
  x = env_all[,c(
    "tmp_max.cent", "tmp_max.mean", "tmp_max.cap", 
    "tmp_min.cent", "tmp_min.mean", "tmp_min.cap", 
    "tmp_yr.cent", "tmp_yr.mean", "tmp_yr.cap"
  )], 
  lm = TRUE, 
  stars = TRUE, 
  hist.col = "orchid3",
  cex.cor = 2
)
psych::pairs.panels(
  x = env_all[,c(
    "tmp_range_drl.cent", "tmp_range_drl.mean", "tmp_range_drl.cap", 
    "tmp_range_yr.cent", "tmp_range_yr.mean", "tmp_range_yr.cap", 
    "tmp_seasonality.cent", "tmp_seasonality.mean", "tmp_seasonality.cap", 
    "isotherm.cent", "isotherm.mean", "isotherm.cap"
  )], 
  lm = TRUE, 
  stars = TRUE, 
  hist.col = "orchid3", 
  cex.cor = 2
)

# to save plots: 
pdf(
  file = "/Users/finleythomas/Library/CloudStorage/OneDrive-UniversityCollegeLondon/Results/lhf/figures/mean_vs_centroid_vs_capitals_env_cor_plots_01_2024.pdf", 
  onefile = TRUE
)
dev.off()

# Differences by country -------------------------------------------------------

# add extra country data to full dataset

env_all <- dplyr::left_join(
  x = env_all, 
  y = country_codes, 
  by = dplyr::join_by(country == NAME)
)

# remove unwanted columns 
env_all <- env_all[,-c(37:42)]

# calculate differences between mean vs centroid, mean vs capitals
# for now only done for lat and precip_yr 
env_all <- env_all %>%
  dplyr::mutate(precip_yr_mean_cent = precip_yr.mean - precip_yr.cent) %>%
  dplyr::mutate(precip_yr_mean_cap = precip_yr.mean - precip_yr.cap) %>%
  dplyr::mutate(lat_mean_cent = lat.mean - lat.cent) %>%
  dplyr::mutate(lat_mean_cap = lat.mean - Latitude.cap)

inc_countries <- unique(glm_gt_data_patr$country)
  
env_all$incl[env_all$country %in% inc_countries] <- "inc"
env_all$incl[!env_all$country %in% inc_countries] <- "not_inc"

# plotting results 

env_all <- env_all %>%
  filter(!is.na(lat_mean_cent)) %>%
  filter(!is.na(lat_mean_cap)) %>%
  filter(!is.na(precip_yr_mean_cent))

# Creating function to plot the results
env_diff_plotter <- function(
        data, 
        variable, 
        filter_inc = FALSE
){
  
  # remove NAs
  table <- data %>%
    filter(!is.na(
      .[[variable]]
     )
    )
  
  # if specified, only include countries also found in the genetic dataset
  if(filter_inc == TRUE){
    table <- table %>%
      filter(incl == "inc")
  } else if (filter_inc == FALSE) {
    message("All countries included - no filtering applied \n")
  } else {
    return(
     "filter_inc must be either FALSE (the default) or TRUE -- function stopped"
    )
  }
  
  # specify the y axis labels
  if(variable == "precip_yr_mean_cent"){
    x_label <- "Absolute difference in Annual Precipitation calculated from mean
    values and centroid coordinates"
  }
  if(variable == "precip_yr_mean_cap"){
    x_label <- "Absolute difference in Annual Precipitation calculated from mean
    values and capital coordinates"
  }
  if(variable == "lat_mean_cent"){
    x_label <- "Absolute difference in latitude calculated from mean 
    values and centroid coordinates"
  }
  if(variable == "lat_mean_cap"){
    x_label <- "Absolute difference in latitude calculated from mean 
    values and capital coordinates"
  }
  
  # select the correct palette
  if(
    length(
      unique(table$continent)
    ) == 6 ) {
    palette_cont <- c(
      "deepskyblue4","firebrick4", "darkorchid3", "chartreuse4", 
      "turquoise","chartreuse3"
    )
  } else if (
    length(
      unique(table$continent)
    ) > 6 ) {
    palette_cont <- c(
      "deepskyblue4", "snow4", "firebrick4", "darkorchid3", "chartreuse4", 
      "turquoise","chartreuse3"
    )
   }

  if(variable == "precip_yr_mean_cent"|variable == "precip_yr_mean_cap"){
    x_lim <- c(-1500,1600)
  }
  if(variable == "lat_mean_cent"| variable == "lat_mean_cap"){
    x_lim <- c(-15, 20)
  }
  
  # plot results
  return(
    ggplot2::ggplot(
    data = table, 
    mapping = ggplot2::aes(
      x = !!rlang::sym(variable),
      y = reorder(x = country, +!!rlang::sym(variable)), # plot the bars in value order, 
      fill = continent, 
      alpha = incl
    )
  ) + 
    ggplot2::geom_bar(
      stat = "identity"
    ) + ggplot2::scale_fill_manual(
      values = palette_cont
    ) +
    ggplot2::scale_alpha_manual(
      values = c(1, 0.25)
    ) +
    ggplot2::ylab(
      "Country"
      ) +
    ggplot2::xlab(
      x_label
    ) + 
    ggplot2::xlim(
      x_lim
    ) +
    ggplot2::theme_minimal(
    ) + 
    ggplot2::theme(
      text = ggplot2::element_text(
        size = 5
      )
    )
 )
}

# apply function
env_diff_plotter(
  data = env_all, 
  variable = 'lat_mean_cent', 
  filter_inc = TRUE
)

# to save
pdf(
  file = "/Users/finleythomas/Library/CloudStorage/OneDrive-UniversityCollegeLondon/Results/lhf/figures/mean_vs_centroid_capitals_env_bar_plots_LAT_01_2024.pdf", 
  onefile = TRUE
)
# run through plots... then:
dev.off()

  # ------------------------------------------------------------------------------

## Looking at variance per country

# Whereas above is comparing the values calculated via the different methods - 
# this section is looking at the range of values within a country (i.e. between 
# all the quadrants that contribute to a country)

# As latitude is not relevant here, we focus on maximim and minimum temperature, 
# as well as annual precipitation. 

# ------------------------------------------------------------------------------

# Generating max and min latitudes

max_min_lat <- ggplot2::map_data("world") %>%
  group_by(region) %>% # here region actually = country
  dplyr::summarise(
    lat_min = min(lat), 
    lat_max = max(lat)
  )

max_min_lat$iso3 <- countrycode::countrycode(
  max_min_lat$region, 
  origin = "country.name", 
  destination = "iso3c"
)

max_min_lat <- dplyr::left_join(
  x = max_min_lat, 
  y = country_codes[,c(1:3, 10)], 
  by = join_by(iso3 == ISO3)
)

# ------------------------------------------------------------------------------

# calculate the minimum value for each bio-climatic variable for each country 
country_env_min <-   terra::extract(
  env_covariates, 
  world_coord, 
  fun = min,
  na.rm = TRUE, 
  weights = TRUE
)

country_env_min$country <- c(world_coord$NAME_0) # add country names

country_env_min <- dplyr::left_join(
  x = country_env_min, 
  y = max_min_lat[,c(2,5)], 
  by = dplyr::join_by(country == NAME)
)
# tweak name
names(country_env_min)[12] <- "lat"


# compress columns 
country_env_min_l <- tidyr::pivot_longer(
  data = country_env_min, 
  cols = c(2:10,12),
  names_to = "variable", 
  values_to = "min"
)

# repeat for maximum values
country_env_max <-   terra::extract(
  env_covariates, 
  world_coord, 
  fun = max,
  na.rm = TRUE, 
  weights = TRUE, 
  ID = TRUE
)

country_env_max$country <- c(world_coord$NAME_0) # add country names

country_env_max <- dplyr::left_join(
  x = country_env_max, 
  y = max_min_lat[,c(3,5)], 
  by = dplyr::join_by(country == NAME)
)
# tweak name
names(country_env_max)[12] <- "lat"

# compress columns 
country_env_max_l <- tidyr::pivot_longer(
  data = country_env_max, 
  cols = c(2:10,12),
  names_to = "variable", 
  values_to = "max"
)

# compress mean values 
country_env_mean <- tidyr::pivot_longer(
  data = env_all[,c(1,11:21)], 
  cols = c(2:12),
  names_to = "variable", 
  values_to = "mean"
)
# remove suffixes
country_env_mean$variable <- gsub(
  pattern = ".cent", 
  replacement = "", 
  x = country_env_mean$variable
)

country_env_mean$variable <- gsub(
  pattern = ".mean", 
  replacement = "", 
  x = country_env_mean$variable
)


# combine max and min values 
country_env_max_min <- dplyr::full_join(
  x = country_env_max_l, 
  y = country_env_min_l, 
  by = dplyr::join_by(country, variable)
)

country_env_max_min <- dplyr::full_join(
  x = country_env_max_min, 
  y = country_env_mean, 
  by = dplyr::join_by(country, variable)
)


# combine with continent data
country_env_max_min <- dplyr::left_join(
  x = country_env_max_min, 
  y = country_codes[,c(1:3,10)], 
  by = dplyr::join_by(country == NAME)
)

# add in inclusion data 
country_env_max_min$incl[country_env_max_min$country %in% inc_countries] <- "inc"
country_env_max_min$incl[!country_env_max_min$country %in% inc_countries] <- "not_inc"

country_env_max_min <-country_env_max_min %>%
  dplyr::mutate(
    range = max - min
  )


# Plotting points with range ---------------------------------------------------

country_env_max_min <- dplyr::distinct(country_env_max_min)

env_pointer <- function(
    x, 
    selected_variable, 
    filter_inc = TRUE) {
  
  for(i in selected_variable){
    
    table <- filter(x, variable %in% i)
  
  if(filter_inc == TRUE) {
    table <- filter(table, incl == "inc")
  }
  
  print(
    ggplot2::ggplot(
      data = table, 
      mapping = ggplot2::aes(
        x = reorder(x = country, -mean),
        y = mean,
        colour = continent
      )
    ) +
      ggplot2::geom_errorbar(
        mapping = ggplot2::aes(
          ymax = max, 
          ymin = min
        ), 
        linewidth = 0.8
      ) +
      ggplot2::geom_point(
        size = 1.5
      ) +
      ggplot2::scale_colour_manual(
        values = c(
          "deepskyblue4","firebrick4", "darkorchid3", "chartreuse4", 
          "turquoise","chartreuse3"
        )
      ) +
      ggplot2::xlab(
        NULL
      ) +
      ggplot2::theme_minimal(
      ) +
      ggplot2::theme(
        axis.text.x = ggplot2::element_text(
          angle = 90,
          vjust = 0.5,
          hjust = 0.5,
          size = 5
        ), 
        strip.background = ggplot2::element_rect(
          fill = "orchid"
        )
      ) +
      ggplot2::facet_wrap(
        ~(variable) 
      )
  )
  } # end of loop
}

env_pointer(
  x = country_env_max_min, 
  selected_variable = c("isotherm")
)

# to save
pdf(
  file = "/Users/finleythomas/Library/CloudStorage/OneDrive-UniversityCollegeLondon/Results/lhf/figures/mean_limits_env_point_plots_01_2024.pdf", 
  onefile = TRUE
)

env_pointer(
  x = country_env_max_min, 
  selected_variable = unique(country_env_max_min$variable)
)

dev.off()

# ------------------------------------------------------------------------------

country_env_max_min <-country_env_max_min %>%
  dplyr::mutate(
    range = max - min
  )

selected_variable <- c("tmp_min", "precip_yr")

ggplot2::ggplot(
  data = filter(country_env_max_min, variable %in% selected_variable), 
  mapping = ggplot2::aes(
    y = reorder(x = country, -range),
    x = range,
    fill = continent
  )
) + 
  ggplot2::geom_bar(
    stat = "identity"
) +
  ggplot2::scale_fill_manual(
    values = c(
      "deepskyblue4", "snow4", "firebrick4", "darkorchid3", "chartreuse4", 
      "turquoise","chartreuse3"
    )
  ) +
  ggplot2::facet_wrap(
    ~(variable)
  )

ggplot2::ggplot(
  data = filter(country_env_max_min, variable %in% selected_variable), 
  mapping = ggplot2::aes(
    x = reorder(x = country, +min),
    fill = continent
  )
) + 
  ggplot2::geom_segment(
    mapping = ggplot2::aes(
      y = min, 
      yend = max, 
      x = country, 
      xend = country, 
      col = continent
    )
  ) + 
  ggplot2::facet_wrap(
    facets = ~(variable)
  )  
 
