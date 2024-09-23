## -----------------------  T.I.M.E Palettes & Themes -------------------------
#
#  This script contains details on the aesthetics for the T.I.M.E projects
#
## ----------------------------------------------------------------------------

# TIME palette genotypes
TIME_palette <- c(
  mX = "orchid1",
  tX = "darkorchid",
  mM = "deepskyblue2",
  tT = "firebrick3"
)

# Generate the RGB values (for use in other software)
col2rgb(TIME_palette)

# Define a transparent, light background to the plot
TIME_theme <- theme_light(
) +
  theme(
    strip.background = element_rect(
      fill = "snow4"
    )
  )
