
##   ----- Performing multiple sequence alignments -----
#          ---------------------------------------

#.   This scripts contains the test code to align sequences using MUSCLE, 
#.   DECIPHER, and MAFFT packages (see sections below).  Data used herein are 
#.   mitochondrial genomes obtained from entrez (see lhf_entrez.R). 

#    UPDATE:   MAFFT was found to perform best (fewest gaps, fastest alignment), 
#    and is thus advised for future use. 
#    Following the initial alignment problematic sequences were filtered out, with 
#    the alignment subsequently being rerun. 

## Libraries required:    -----

library(stringr)
library(dplyr)
library(phylotools)
library(msa)
library(ape)
library(seqinr)
library(DECIPHER)
library(Biostrings)

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

##.  Alignment test set of 100 sequences... 

seq_mt_100 <- readDNAStringSet("../../../data/lhf_d/100_output.fasta")

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

#. Run with 10 seq, now adapting files to run on 100

seq_mt <- readDNAStringSet("output.fasta")   # as above

decipher_algn <- DECIPHER::AlignSeqs(seq_mt_100)
Biostrings::writeXStringSet(
  decipher_algn, 
  "../../../data/lhf_d/aln_100_decipher.fasta"
)

decipher_algn2 <- ape::read.dna(
  file = "~/Documents/data/lhf_d/aln_decipher_complete_08_2023.fasta",
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
{'mafft --thread n <input_file.fasta> <output_file.fasta>'}

# Or to use a reference genome (this will help improve efficiency and accuracy)
{'mafft --6merpair --thread n --keeplength input_file.fasta ref.fasta > output.fasta '}

# run on 05.09.2023
{'mafft --6merpair --thread 6  --addfragments  
  Documents/data/lhf_d/complete_output_09.2023.fasta
  Documents/data/lhf_d/human_mtDNA_reference_seq.fasta 
  > Documents/data/lhf_d/aln_mafft_incRef_2_09_2023.fasta'}

# run on 14.10.2023
# op : gap opening penalty, increased to 2.30 (1.5 x 1.53 default)
{'mafft --6merpair --thread 6 --op 3.00  --addfragments  
  Documents/data/lhf_d/complete_output_09.2023.fasta
  Documents/data/lhf_d/human_mtDNA_reference_seq.fasta 
  > Documents/data/lhf_d/aln_mafft_incRef_Gap3.0_09_2023.fasta'}

# also run in 14.10.2023 -- using the filtered fasta files (and standard op)
{'mafft --6merpair --thread 6  --addfragments  
  Documents/data/lhf_d/complete_output_filtered_09.2023.fasta
  Documents/data/lhf_d/human_mtDNA_reference_seq.fasta 
  > Documents/data/lhf_d/aln_mafft_incRef_filtered_09_2023.fasta'}


mafft_algn <- ape::read.dna(
  file = "~/Documents/data/lhf_d/aln_mafft_incRef_2_09_2023.fasta",
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

##  Filtering the MAFFT alignment ------------------------------------------ 

# The resulting alignment has a number of sites where there is a single base 
# called (with all other sequences thus having a gap at this point).  To improve
# the alignment, these problem sequences should be identified and removed. 

mafft_algn <- Biostrings::readDNAStringSet(
  file = "~/Documents/data/lhf_d/aln_mafft_incRef_2_09_2023.fasta"
)
# Convert to a matrix 
algn_matrix <-  as.matrix(mafft_algn)

# Calculate the number of sequences and alignment length
num_sequences <- nrow(algn_matrix)
alignment_length <- ncol(algn_matrix)

# Create a matrix to store gap information for each position
gap_counts <- matrix(
  0,
  nrow = alignment_length, 
  ncol = 1)

# Loop through each position in the alignment:

for (position in 1:alignment_length) {
  # Count the number of gaps at the current position
  gap_counts[position, 1] <- sum(
    algn_matrix[, position] == "-"
    )
}

mac <- 10
threshold <- 1-(mac/num_sequences) # % cutoff
threshold <- threshold * num_sequences # number of  gaps limit

# list values where there are few
gap_points <- which(
  gap_counts >= threshold, 
  #arr.ind = TRUE
)

outlier_sequences <- rownames(algn_matrix)[which(
  rowSums(
    algn_matrix[, c(gap_points)] == '-'
  ) != 360
)]

outlier_sequences <- algn_matrix[, c(gap_points)]
outlier_sequences <- rowSums(outlier_sequences == '-')
outlier_sequences <- which(outlier_sequences != 360)

outlier_sequences <- as.vector(names(outlier_sequences))

# reading in the original fasta file...
og_fasta <- seqinr::read.fasta(
  file = "~/Documents/data/lhf_d/complete_output_09.2023.fasta"
)

# filter out the outlier sequences defined above:
filtered_fasta <- og_fasta[-which(names(og_fasta) %in% outlier_sequences)]

# Write the filtered FASTA file
seqinr::write.fasta(
  sequences = filtered_fasta, 
  names = names(filtered_fasta), 
  file = "~/Documents/data/lhf_d/complete_output_filtered_09.2023.fasta"
)  # then re-align this file... (using MAFFT)
