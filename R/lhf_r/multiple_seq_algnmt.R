
##   ----- Performing multiple sequence alignments -----
#          ---------------------------------------

#.   This scripts contains the test code to align sequences using MUSCLE, 
#.   DECIPHER, and MAFFT packages (see sections below).  Data used herein are 
#.   mitochondrial genomes obtained from entrez (see lhf_entrez.R). 

## Libraries required:    -----

library(stringr)
library(dplyr)
library(phylotools)
library(msa)
library(ape)
library(seqinr)
library(DECIPHER)

#  --------------------------------------------------------------------------
## Creating temporary practice file -----------------------------------------

mito_seq <- mito_extracted[c(1:10), c(1, 7)]
  #. only included relevant columns & first 10 rows

names(mito_seq) <- c("seq.name", "seq.text")

mito_seq <- mito_seq %>% 
  rowwise() %>%
  mutate(sequence = str_to_upper(sequence))
  #. make sequences upper case

dat2fasta(mito_seq, "../../../data/lhf_d/output.fasta")
  #. convert to fasta file format

# --------------------------------------------------------------------------
## Aligning using the msa package ------------------------------------------

# system.file("tex", "texshade.sty", package="msa")

seq_mt <- readDNAStringSet("output.fasta")
seq_mt

algn_muscle <- msaMuscle(seq_mt)

algn_ape <- msaConvert(
  x = algn_muscle, 
  type = "ape::DNAbin"
  )

write.FASTA(algn_ape, "../../../data/lhf_d/aln_10_muscle.fasta")
  #. this file can be read in AliView

algn_muscle2 <- msaConvert(
  algn_muscle, 
  type="seqinr::alignment"
)

d <- dist.alignment(algn_muscle2, "identity")

mt_tree <- ape::nj(d)
ape::plot.phylo(mt_tree)

muscle_algn2 <- ape::read.dna(
  file = "../../../data/lhf_d/aln_10_muscle.fasta", 
  format = "fasta")
ape::checkAlignment(muscle_algn2)

# --------------------------------------------------------------------------
##  Aligning using the DECIPHER package ------------------------------------ 

seq_mt <- readDNAStringSet("output.fasta")   # as above

decipher_algn <- DECIPHER::AlignSeqs(seq_mt)
Biostrings::writeXStringSet(
  decipher_algn, 
  "../../../data/lhf_d/aln_10_decipher.fasta"
)

decipher_algn2 <- ape::read.dna(
  file = "../../../data/lhf_d/aln_10_decipher.fasta",
  format = "fasta"
)
d <- dist.alignment(decipher_algn, "identity")

ape::checkAlignment(decipher_algn2)
  # top left:     Nucleotide & gap summary
  # top right:    Shannon Index (high values = greater diversity)
  # bottom left:  Gaps at the start
  # bottom right: Number of nucleotides at each site

decipher_dist <- ape::dist.dna(
  x = decipher_algn2, 
  model = "JC"
)

decipher_tree <- ape::nj(decipher_dist)
ape::plot.phylo(decipher_tree)

## --------------------------------------------------------------------------
##  Checking the MAFFT alignment -------------------------------------------- 

#. Alignment completed using MAFFT of the command line: 
#  To run in terminal:  
 {'bash mafft <input_file.fasta> <output_file.fasta>'}

mafft_algn <- ape::read.dna(
  file = "../../../data/lhf_d/mafft_algn.fasta",
  format = "fasta"
)

ape::checkAlignment(mafft_algn)

mafft_dist <- ape::dist.dna(
  x = mafft_algn, 
  model = "JC"  
    # JC = Jukes Cantor
    # K80 = Kimura 1980
)

mafft_tree <- ape::nj(mafft_dist)
ape::plot.phylo(mafft_tree)



