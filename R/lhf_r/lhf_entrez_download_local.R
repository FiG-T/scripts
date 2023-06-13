### Project LHF - Attempting to use E-Utilities & Entrez ----------------------
#   -----------

## Subset of 'lhf_entrez.R' - this script is shortened and only includes the 
#  code that is to be run on the cluster.

#  This pulls data directly from NCBI using the "rentrez" package and downloads
#  all the genbank files (in groups of a specified size). 

#options(repos = c(CRAN = "https://cloud.r-project.org/"))
# set cran mirror to RStudio maintained global server

#install.packages("rentrez") 
library(rentrez)

#  NCBI default is 3 requests per second - this may result in large requests 
#  taking a long time to process.  This can be improved to 10 requests per 
#  second once you register for a (personal) API key (available once you sign up 
#  for an NCBI account). 

set_entrez_key("f5ff2d14bbc152047694a55253157602b507")
# set the key for each session
# use your own personal key

# ---------------------------------------------------------------------------------------

mito_search <- entrez_search(
  db = "nucleotide",
  term = "(00000015400[SLEN] : 00000016600[SLEN]) AND Homo[Organism] AND mitochondrion
  [FILT] AND (15400[SLEN] : 17000[SLEN])",
  use_history = TRUE
) 
# This uses many some of the same search syntax from the mitomap website
# -------
# to exclude ancient Humans add:  "NOT ((Homo sapiens subsp. 'Denisova'[Organism] OR 
# Homo sp. Altai[All Fields]) OR (Homo sapiens subsp. 'Denisova'[Organism] OR Denisova 
# hominin[All Fields]) OR neanderthalensis[All Fields] OR heidelbergensis[All Fields] 
# OR consensus[All Fields] OR (ancient[All Fields] AND (Homo sapiens[Organism] OR human
# [All Fields]) AND remains[All Fields]))"

mito_search$web_history

# Using a web history within an "entrez_fetch" loop: 

for( seq_start in seq(10001,20000,100)){
  # starting off with a small sample size
  recs <- entrez_fetch(
    db ="nucleotide", 
    web_history = mito_search$web_history,
    #id = mito_search$ids,
    rettype ="gb", 
    retmax = 50, 
    retstart=seq_start)
  Sys.sleep(0.1)          # to ensure NCBI is not overloaded.
  cat(recs, file="mito_gb_10-20..txt", append=TRUE)
  cat(seq_start + 99, "GenBank files downloaded\r")
}
#. This output file can be processed using the python script to extract the 
#. country information etc.


