# Converting Multiple Sequence Alignments to a vcf file

 For some unknown reason I was unable to install the snp-sites package locally... 
 This package was chosen as it was the best (only) option which allows for a direct conversion
 from a fasta (aligned) file to a vcf without requiring bam file creation or genotype calling.

 "SNP-sites: rapid efficient extraction of SNPs from multi-FASTA alignments",
  Andrew J. Page, Ben Taylor, Aidan J. Delaney, Jorge Soares, Torsten Seemann, Jacqueline A. Keane, Simon R. Harris,
  Microbial Genomics 2(4), (2016). http://dx.doi.org/10.1099/mgen.0.000056

  The following code was run in Anaconda Cloud terminal: 
   In a new environment: 

# Activate the new environment (or existing one)
`conda activate <environment_name>`

`conda install -c bioconda snp-sites`

 Upload fasta file to cloud terminal
`snp-sites -v -o snp_sites_msa_converted_09_2023.vcf aln_mafft_incRef_2_09_2023.fasta`

