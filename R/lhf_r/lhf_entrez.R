### Project LHF - Attempting to use E-Utilities & Entrez ----------------------
#   -----------

#  After unsuccessful attempts to download the required GenBank files and 
#  sequences from the NCBI website interface I have decided to try and use 
#  the API (known as Entrez)... 

install.packages("rentrez")
library(rentrez)

#  NCBI default is 3 requests per second - this may result in large requests 
#  taking a long time to process.  This can be improved to 10 requests per 
#  second once you register for a (personal) API key (available once you sign up 
#  for an NCBI account). 

set_entrez_key("f5ff2d14bbc152047694a55253157602b507")
# set the key for each session
# use your own personal key


entrez_dbs()
# list all available databases

entrez_db_searchable("nucleotide")
# list which features you can include in your search (here for the nucleotide database)

# ---------------------------------------------------------------------------------------

mtDNA_search <- entrez_search(  # custom search 
  db = "nucleotide",   
  term = "(mitochondrion[ALL Fields])
  AND Homo sapiens[ORGN] AND (15400[SLEN] : 16600[SLEN])" 
  # search term
  # limits length between 15400 and 16600 bp.
)

mtDNA_search$ids
length(mtDNA_search$ids)

mitomap_search <- entrez_search(
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

mitomap_search$web_history


##  Summary information for these searches can be retrieved in two steps: 
#    1.  entrez_summary() :  this searches the database and stores the data in a list
#    2.  extract_from_esummary()  : this retrieves specific values from within a particular 
#        list
#   Each summary search must have EITHER a list of ids OR a web_history link from a search. 


#  attempting to write a loop... 
#    using web history: 
for( seq_start in seq(1,63500,50)){
  recs <- entrez_fetch(
    db ="nucleotide", 
    web_history = mitomap_search$web_history,
    rettype ="gb", 
    retmax = 50, 
    retstart=seq_start)
  Sys.sleep(0.1)          # to ensure NCBI is not overloaded.
  cat(recs, file="mitomap_gb_full.txt", append=TRUE)
  cat(seq_start + 49, "GenBank files downloaded\r")
}
#. This output file can be processed using the python script to extract the 
#. country information etc.
  

## ---------------------------------------------------------------------------
##.  Formatting the extracted information. -----------------------------------

mito_extracted <- read.delim("../../../data/lhf_d/genbank_output_D.tsv")
  #. Change this path to match your output file.

#. Getting country list: 

country_info <- feather::read_feather(
  "../../../data/countries_subcontinents.feather")
  #. List of countries and subcontinents with associated cooridinate info. 
  #. Cannot be pulled directly from GitHub (not currently possible with feather 
  #. files)

country_list <- stringr::str_flatten(
  string = country_info$region,
  collapse = "|"
) 

country_list <- stringr::str_c(
  country_list, "Czechia", 
  sep = "|"
)
  #. This makes a very large regular expression with all the countries. 


mito_extracted_processed <- mito_extracted %>%
  filter(
    Organism == "Homo sapiens" # exclude ancient DNA for now
  ) %>%
  mutate(
    Note = str_extract(
    string  = Note, 
    pattern = country_list
    )
    #. Extract names from Notes column
  ) %>%
  mutate(
    Country = str_extract(
      string  = Country, 
      pattern = country_list
    )
    #. Extract names from country columns
    #. This will remove regions/ additional geographical info
  ) %>%
  tidyr::unite(
    col = country,
    c(Country, Note), 
    sep = "", 
    na.rm = TRUE
  ) %>% 
  select(
    Accession, country, Sequence
  ) %>%
  filter(
    country != ""
  ) %>%
  tidyr::unite(
    col = id,
    c(Accession, country)
  ) %>%
  mutate(Sequence = str_to_upper(Sequence))
  
names(mito_extracted_processed) <- c("seq.name", "seq.text")
dat2fasta(mito_extracted_processed[c(1:100),], "../../../data/lhf_d/100_output.fasta")
#. convert to fasta file format

nrow(mito_extracted_processed)


## ---------------------------------------------------------------------------
#. Extracting the information directly from NCBI. ----------------------------

mtDNA_summary <- entrez_summary(
  db = "nucleotide", 
  id = mtDNA_search$ids    # list of ids 
)
mtDNA_summary

subnames<- extract_from_esummary(mtDNA_summary, "subname") 
# retrieve values from the above summary
# taxid :  number associated with taxa (9606 = sapiens) --- no longer the case
# subname: notes, inc. location data

mitotable<- data.frame(notes = subnames)
head(mitotable)

library(stringr)
library(tidyr)
mitotable_temp <- separate(
  mitotable, notes, 
  sep = "\\|",
  into = c("sub_a", "sub_b", "sub_c", "sub_d")
)
