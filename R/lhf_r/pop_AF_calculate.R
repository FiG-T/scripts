## ----------------- Looping through Countries for Allele Freq ----------------- 

# Although I looked at a few countries separately (GBR, AGO, JPN) we thought it 
# would be good to have a function that does this for all countries... 

## -----------------------------------------------------------------------------

# taking the country list (for countries with more than 20 indv. )
length(unique(country_N))

pop_AF_calculate <- function(
        population_list, 
        meta_data, 
        path,
        colour_classification, 
        plots_file, 
        haplotypes_phased
) {
  
  for (i in population_list) {
    
    # filter by iso3 name
    lhf_iso <- meta_data %>%
      filter(iso3 == i) %>%
      select(samples) # store column of accession numbers 
    
    # create filename for each population
    filename <- paste(
      path,"/", i , ".txt", 
      sep = ""
    )
    
    # write file
    readr::write_delim(
      x = lhf_iso, 
      file = filename, 
      col_names = FALSE
    )
  }
  
  # after sample name files have been created, run the vcf tools script via bash 
  system2(
    "bash", 
    args = "~/Documents/scripts/shell/iso_allele_freq.sh", 
    stdout = TRUE
  )
  
  # create colour table
  colour_table <- feather::read_feather(
    colour_classification
  )
  
  # read in haplotype list
  haplotypes_phased_table <- feather::read_feather(haplotypes_phased)
  
  # create list for plots 
  plot_list <- list()
  
  # read in allele frequency data 
  for (i in population_list) {
    input_filename <- paste(
      "~/Documents/data/lhf_d/vcf/vcf_iso3_freq","/lhf_", i , "_allele_freq.frq", 
      sep = ""
    )
    
    message(input_filename)
    
    # read in each frequency file 
    var_freq_iso <- readr::read_delim(
      file = input_filename, 
      delim = "\t", 
      col_names = c("chr", "pos", "nalleles", "nchr", "a1", "a2", "a3"), 
      skip = 1, 
      show_col_types = FALSE
    )
    # loop through columns and remove letters and symbols:
    for (j in c(5:7)) {
      x <- names(var_freq_iso)[j]
      
      var_freq_iso[[x]] <- gsub(
        pattern = "[ACTG][:punct:]", # remove letters
        x = var_freq_iso[[x]], 
        replacement = ""
      )
      
      var_freq_iso[[x]] <- gsub(
        pattern = "\\*[:punct:]", # remove punctuation
        x = var_freq_iso[[x]], 
        replacement = ""
      )
      
    }
    
    # select the minor allele 
    var_freq_iso$maf <- var_freq_iso %>% 
      dplyr::select(a1, a2, a3) %>% 
      apply(1, function(z) min(z, na.rm = TRUE))
    
    # convert to numeric
    var_freq_iso$maf <- as.numeric(var_freq_iso$maf)
    
    # combine whith the phased haplotype informative sites
    var_freq_iso_haplo <- dplyr::left_join(
      x = var_freq_iso, 
      y = haplotypes_phased_table , 
      by = dplyr::join_by("pos"=="phased_tpos")
    )
  
    colour_density <- colour_table %>% 
      filter(iso3 == i)
    
    fill_colour <- colour_density$cont_colour
    
    # plot the distribution of alleles
    p <- ggplot2::ggplot(
      data = var_freq_iso_haplo, 
      mapping = ggplot2::aes(
        maf,
        fill = hap_lineages
        ) 
    ) +
      ggplot2::geom_histogram(
        bins = 99
      ) +
      ggplot2::geom_density(
        fill = fill_colour, 
        colour = "black", 
        alpha = 0.75
      ) +
      ggplot2::xlab(
        "Minor Allele Frequency"
      ) +
      ggplot2::ylab(
        "Density"
      ) +
      ggplot2::ggtitle(i)
    
    plot_list[[i]] <- p
   # print(p)
  } # close for loop
  
  # open pdf: 
  pdf(plots_file)
  
  for (iso in population_list) {
    print(plot_list[[iso]])
  }
  
  dev.off()
  
} # end of function

#populations <- c("POL", "CHL")

pop_AF_calculate(
  population_list = c(iso3_N),
  meta_data = lhf_meta2, 
  path = "~/Documents/data/lhf_d/vcf/vcf_sample_names_iso3", 
  colour_classification = "~/Documents/data/lhf_d/country_info_colours.feather", 
  plots_file = "~/Documents/data/lhf_d/allele_frequency_by_pop_plots.pdf", 
  haplotypes_phased = "~/Documents/data/lhf_d/haplotype_informative_sites_phased.feather"
  
)

# group by country and summarise: 
iso3_N <- lhf_meta2 %>%  # generated above
  group_by(iso3) %>%
  summarise(
    N = n()
  )

# filter out countries with fewer than 20
iso3_N <- iso3_N %>%
  filter(N >= 20)  # define the cutoff value. 

# convert remaining countries to a list 
iso3_N <- c(iso3_N$iso3)




