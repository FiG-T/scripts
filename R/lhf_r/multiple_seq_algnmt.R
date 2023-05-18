##. Performing multiple sequence alignments

library(stringr)
library(dplyr)
library(phylotools)
library(msa)
library(ape)
library(seqinr)
library(DECIPHER)

## Creating temporary practice file 

mito_seq <- mito_extracted[c(1:10), c(1, 7)]
  #. only included relevant columns & first 10 rows

names(mito_seq) <- c("seq.name", "seq.text")

mito_seq <- mito_seq %>% 
  rowwise() %>%
  mutate(sequence = str_to_upper(sequence))
  #. make sequences upper case

dat2fasta(mito_seq, "../../../data/lhf_d/output.fasta")
  #. convert to fasta file format


##. --- Aligning using the msa package ---

# system.file("tex", "texshade.sty", package="msa")

seq_mt <- readDNAStringSet("output.fasta")
seq_mt

algn_muscle <- msaMuscle(seq_mt)

algn_ape <- msaConvert(algn_muscle, "ape::DNAbin")

write.FASTA(algn_ape, "../../../data/lhf_d/aln_10_muscle.fasta")
  #. this file can be read in AliView

algn_muscle2 <- msaConvert(algn_muscle, type="seqinr::alignment")
d <- dist.alignment(algn_muscle2, "identity")

mt_tree <- ape::nj(d)
plot(mt_tree)

##. ----- Aligning using the DECIPHER package --- 

seq_mt <- readDNAStringSet("output.fasta")   # as above

decipher_algn <- DECIPHER::AlignSeqs(seq_mt)
Biostrings::writeXStringSet(decipher_algn, "../../../data/lhf_d/aln_10_decipher.fasta")

decipher_algn2 <- as.alignment(decipher_algn, mode = "any")
d <- dist.alignment(decipher_algn, "identity")

