## Extracting Bioclimatic data from Townsville and Melbourne

# download all bioclimatic variables
global_bio <- geodata::worldclim_global(
  var = "bio",
  res = 2.5, 
  path = tempdir(), 
  version = "2.1"
)

# to plot... 
plot(global_bio[[3]])

names(global_bio)

# select relevant variables 
env_covariates <- global_bio[[c(1,2,3,4,5,6,7,12,15)]]
# rename selected columns 
names(env_covariates) <- c(
  "tmp_yr", "tmp_range_drl", "isotherm", "tmp_seasonality", "tmp_max", "tmp_min", 
  "tmp_range_yr", "precip_yr", "precip_seasonality"
)

# create tibble of locations (from Stefano preprint)
aus_variables <- tibble::tibble(
  location = c("Townsville", "Melbourne"), 
  latitude = c(-19.26, -37.77), 
  longitude = c(146.81, 144.99)
)

# convert to a SpatVector
aus_coord <- terra::vect(
  x = aus_variables, 
  geom = c("longitude", "latitude"),
  crs = '+proj=longlat +datum=WGS84'
)

# Calculte geometries 
aus_coord <- terra::geom(aus_coord)

# Extract bioclimatic variables for these locations 
aus_env <- terra::extract(
  x = env_covariates, 
  y = aus_coord[,3:4]
)

# bind location and climatic variables together 
aus_variables <- cbind(
  aus_variables, 
  aus_env
)

# save file 
write.csv(
  x = aus_variables, 
  file = "~/Documents/data/time/TOW_MEL_WorldClim_variables.csv"
)

# import file (change this depending on where you have saved it)
aus_variables <- read.csv(
  file = "~/Documents/data/time/TOW_MEL_WorldClim_variables.csv", 
  header = TRUE
)

# create simple plots
for (i in 2:ncol(aus_variables)) {
  
  p <- ggplot2::ggplot(
    data = aus_variables, 
    mapping = ggplot2::aes(
      x = location, 
      y = aus_variables[[i]], 
      colour = location
    )
  ) +
    ggplot2::geom_point(
      size = 4
    ) + 
    ggplot2::scale_colour_manual(
      values = c(
        Townsville = "firebrick3", 
        Melbourne = "deepskyblue3"
      ) 
    ) +
    ggplot2::ylab(
      names(aus_variables)[[i]]
    ) +
    ggplot2::theme_bw()
  
  print(p)
  
}

# to create long form and plot
aus_variables_l <- tidyr::pivot_longer(
  data = aus_variables, 
  names_to = "variable", 
  values_to = "value", 
  cols = latitude:precip_seasonality
)

# plot using long form
for (i in unique(aus_variables_l$variable)) {
  
  data <- filter(
    aus_variables_l, 
    variable == i 
  )
  
  p <- ggplot2::ggplot(
    data = data, 
    mapping = ggplot2::aes(
      x = location, 
      y = value, 
      colour = location
    )
  ) +
    ggplot2::geom_point(
       size = 4
    ) + 
    ggplot2::scale_colour_manual(
      values = c(
        Townsville = "firebrick3", 
        Melbourne = "deepskyblue3"
      )
    ) +
    ggplot2::facet_wrap(
      ~variable
    ) +
    ggplot2::theme_bw()
  
  print(p)
  
}

