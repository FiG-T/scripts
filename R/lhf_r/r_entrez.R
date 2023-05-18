### Project LHF - Attempting to use E-Utilities & Entrez 
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


mitomap_search

#  attempting to write a loop... 
#    using web history: 
for( seq_start in seq(1,500,50)){     # up to file 500
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




mitomap_acc <- entrez_fetch(    # to retrive the accession numbers: 
  db = "nucleotide",
  web_history = mitomap_search$web_history,  
  rettype = "acc"
)    #. This only returns 10000 numbers --- not sure why...

stringr::str_length(mitomap_acc[[1]])/12
mitomap_acc_list <- stringr::str_split(mitomap_acc, "\n")
length(mitomap_acc_list[[1]])
mitomap_acc_list <- c(mitomap_acc_list[[1]])
length(mitomap_acc_list)


mitomap_acc_list <- read.delim("mitomap_acc_full.txt") 
mitomap_acc_list_ <-mitomap_acc_list[,1]
head(mitomap_acc_list_)
length(mitomap_acc_list_)   # list of 9998 ACC numbers



#.  To get a shorter list of ids/acc no. ... 
mtDNA_summary <- entrez_summary(
  db = "nucleotide", 
  id = mitomap_acc_list_v[1:20]    # list of ids -- this does not work
)
mtDNA_summary

subnames<- extract_from_esummary(mtDNA_summary, "subname") 
# retrieve values from the above summary
# taxid :  number associated with taxa (9606 = sapiens)
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


#. 
mitomap_summary <- entrez_summary(   
  db = "nucleotide",
  web_history = mitomap_search$web_history   # using the web_history 
  #. This will not work if there are more than 500 objects in the web summary. 
)
extract_from_esummary(mitomap_summary, "uid") 
# the number of results returned is limited to the rettmax from the search above. 


#.   ------------------------------------------------------------------
#.   Loop experiments
# 
for( seq_start in seq(1,63500,50)){
  recs <- entrez_fetch(
    db ="nucleotide", 
    web_history = mitomap_search$web_history,
    rettype ="acc", 
    retmax = 50, 
    retstart=seq_start)
  cat(recs, file="mitomap_acc_full.txt", append=TRUE)
  cat(seq_start + 49, "Acc files downloaded\r")
}
