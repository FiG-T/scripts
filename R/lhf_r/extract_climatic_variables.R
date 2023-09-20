##   ----------------- Extracting Environmental Variables ----------------------

#    This script is designed to import environmental variables for a given list 
#    of countries.  This results in a metadata file be joined with the sample
#    names (see vcf_processing.R) to create a pair of files that can be used to 
#    identify correlations and run PGLS analysis. 

#    ---------------------------------------------------------------------------

##   Libraries required ----

if (!require("geodata")) install.packages("geodata")
if (!require("tidyterra")) install.packages("tidyterra")
library(terra)
library(geodata)
library(ggplot2)
library(tidyterra)

##  Importing climate data 

# This downloads data from the world Clim data page 
# [https://www.worldclim.org/data/bioclim.html]

global_bio <- geodata::worldclim_global(
  var = "bio",
  res = 2.5, 
  path = tempdir(), 
  version = "2.1"
)
global_bio
# bio1 : annual mean temp
# bio2 : mean diurnal range
# bio3 : Isothermality (bio2 * bio7)
# bio4 : temperature seasonality
# bio5 : Max temp warmest month 
# bio6 : Min temp coldest month
# bio7 : Temperature annual range 
# bio12: Annual precipitation
# bio15: Precipitation seasonality

# To plot one of these variables...
plot(global_bio[[3]])

env_covariates <- global_bio[[c(1,2,3,4,5,6,7,12,15)]]
names(env_covariates) <- c(
  "tmp_yr", "tmp_range_drl", "isotherm", "tmp_seasonality", "tmp_max", "tmp_min", 
  "tmp_range_yr", "precip_yr", "precip_seasonality"
)
env_covariates

terra::global(env_covariates, mean)

###
country_codes <- geodata::country_codes(
  query = NULL
)

## generating world coordinates

world_coord <- geodata::world(
  resolution = 3, 
  level = 0, 
  path = tempdir()
)

country_centroids <- terra::centroids(
  x = world_coord, 
  inside = TRUE # will guarantee the point falls within the polygon, may not be 
                # the true centroid.
)

# plot map positions... 
plot(world_coord, 
     col = 'honeydew3'
)
points(country_centroids, 
       col = "deeppink2", 
       pch = 4)

## select relevant countries -----
lhf_centroids <- country_centroids[country_centroids$NAME_0 %in% c(lhf_names),]

plot(world_coord, 
     col = 'seashell2'
)
points(
  lhf_centroids, 
  col = "purple", 
  pch = 20, 
  cex = 2
)

## Plotting points over climatic variables: 
bio <- 7
plot(
  env_covariates[[bio]], 
  main = names(env_covariates)[bio]
  )
points(lhf_centroids, 
       col = "purple", 
       pch = 18, 
       cex = 1)

# generate matrix of centroid coordinates

lhf_coord <- terra::geom(lhf_centroids)

## use this matrix to extract relevant environmental variables 
# extract relevant country data 
lhf_env <- terra::extract(
  x = env_covariates, 
  y = lhf_coord[,3:4]
)

str(lhf_env)
#  this shows this is now a dataframe with the environmental variables for each 
#  coord for each country in the list...

# create a table of relevant country names
lhf_countries <- terra::as.data.frame(lhf_centroids)

## combine the datasets... 
lhf_env <- base::cbind(
  lhf_countries, 
  lhf_env
)

# combine with the centroid coordinates
lhf_env <- cbind(
  lhf_env, 
  lhf_coord
)

lhf_env <- lhf_env[,c(1:2, 15, 14, 3:11)]

names(lhf_env)[1:4] <- c("ISO_3", "country", "lat", "long")

## to combine climatic covariates and sample names:

#  re-import sample names: 
lhf_names <- readr::read_delim(
  file = "~/Documents/data/lhf_d/vcf/lhf_filtered_maf0.005_sampleNames.txt", 
  delim = "/t", 
  col_names = "samples"
)

# arrange into 2 columns...
lhf_names <- tidyr::separate(
  data = lhf_names, 
  col = samples, 
  into = c("acc", "a", "b", "c", "d" , "e", "f"), 
  sep = "_"
) 
lhf_names <- tidyr::unite(
  data = lhf_names, 
  col = "country", 
  a, b, c, d, e , f, 
  sep = " ", 
  na.rm = TRUE
)

#  remove reference sequence
lhf_names <- lhf_names[-1,]

#  replace problem names
lhf_names$country <- gsub(
  pattern = "USA", 
  replacement = "United States", 
  x = lhf_names$country
)
lhf_names$country <- gsub(
  pattern = "Great Britain", 
  replacement = "United Kingdom", 
  x = lhf_names$country
)

lhf_names$country <- gsub(
  pattern = "Czech Republic", 
  replacement = "Czechia", 
  x = lhf_names$country
)

lhf_names <- unique(lhf_names$country)


## Combine with the environmental variables

lhf_meta <- dplyr::full_join(
  x = lhf_names, 
  y = lhf_env,
  by = dplyr::join_by(country)
)

# add in regions and continents: 
lhf_meta <- dplyr::left_join(
  x = lhf_meta, 
  y = country_codes, # quereied above
  by = dplyr::join_by("ISO_3" == "ISO3")
)

# reorder and remove unwanted cols: 
lhf_meta <- lhf_meta[,c(1:3,16,21,23,4:14)]

# unite first two columns to reform sample names: 
lhf_meta <- tidyr::unite(
  data = lhf_meta, 
  col = "samples", 
  acc, country,
  sep = "_", 
  na.rm = TRUE, 
  remove = FALSE
)

# remove spaces from sample names: 
lhf_meta$samples <- gsub(
  pattern = " ", 
  replacement = "_", 
  x = lhf_meta$samples
)

# change iso column names (to remove capital letters)
names(lhf_meta)[4:6] <- c("iso3", "iso2", "subcontinent")


# write to an output file: 
#  feather is used as it is an ultrafast file format designed to quickly read 
#  and write data into R and python. 
#  Note: feather is a binary format system so will not be able to be read by text
#  editors...


feather::write_feather(
  x = lhf_meta, 
  path = "~/Documents/data/lhf_d/lhf_meta_data_09_2023.feather"
)


## extracting averages per country region ----------

head(
  terra::extract(
  env_covariates[[2]], 
  world_coord, 
  na.rm = TRUE, 
  weights = TRUE
  )
)

lhf_env <-   terra::extract(
  env_covariates, 
  world_coord, 
  mean,
  na.rm = TRUE, 
  weights = TRUE
)

## combine the mean values with country names...
lhf_env <- base::cbind(
  world_coord_df, 
  lhf_env
)

# collect country centriod coordinates
world_centroid <- terra::geom(country_centroids)

# combine with mean value data 
lhf_env <- base::cbind(
  lhf_env, 
  world_centroid
)

lhf_env <- lhf_env[,c(1,2,15,16,4:12)]
names(lhf_env)[1:4] <- c("ISO_3", "country", "lat", "long")

lhf_env$country <- gsub(
  pattern = "Czech Republic", 
  replacement = "Czechia", 
  x = lhf_env$country
)

# using names from above...
lhf_meta2 <- dplyr::left_join(
  x = lhf_names, 
  y = lhf_env,
  by = dplyr::join_by(country)
)

# add in regions and continents: 
lhf_meta2 <- dplyr::left_join(
  x = lhf_meta2, 
  y = country_codes, # quereied above
  by = dplyr::join_by("ISO_3" == "ISO3")
)

# reorder and remove unwanted cols: 
lhf_meta2 <- lhf_meta2[,c(1:3,16,21,23,4:14)]

# unite first two columns to reform sample names: 
lhf_meta2 <- tidyr::unite(
  data = lhf_meta2, 
  col = "samples", 
  acc, country,
  sep = "_", 
  na.rm = TRUE, 
  remove = FALSE
)

# remove spaces from sample names: 
lhf_meta2$samples <- gsub(
  pattern = " ", 
  replacement = "_", 
  x = lhf_meta2$samples
)

# change iso column names (to remove capital letters)
names(lhf_meta2)[4:6] <- c("iso3", "iso2", "subcontinent")

# write to alternate file 
feather::write_feather(
  x = lhf_meta2, 
  path = "~/Documents/data/lhf_d/lhf_meta2_data_09_2023.feather"
)

