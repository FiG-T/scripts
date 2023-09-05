#!/bin/bash

#  4 - Processing short read sequences: Calling SNP Variants

################################################################################
# Summary:

#  *dedup_rg.bam -> .vcf

#      After the sequences have been processed, aligned, and cleaned, variants 
#      will need to be called.  This identifies sites that are different between
#      samples and/or the reference genome. bcf mpileup (formerly on samtools)
#      (https://samtools.github.io/bcftools/bcftools.html#mpileup) was selected 
#      due to reported good performances on non-human sequences and downstream 
#      compatibility with PoolSNP.  This latter programe was chosen due to its 
#      strong perfomance (low FDR, high sensitivity) with pooled sequences, as 
#      well as reasonable documentation (https://github.com/capoony/PoolSNP).

#      Modified by FiG-T (August 2023)

################################################################################   

#  Define the shell being used: 
#$ -S /bin/bash

#  Define the shell being used: 
#$ -S /bin/bash 

#  Request RAM required 
#$ -l mem=40G

# Request TMPDIR space
#$ -l tmpfs=40G

#  Request/specify time needed/limit
#$ -l h_rt=30:00:00

#$ -wd /home/zcbtfgg/Scratch/t.i.m.e/sequences
   # Note: Myriad nodes cannot write files directly to the home directory

#  Number of (shared) parrallel environments/ processors required.
#$ -pe smp 16

################################################################################

module load bcftools/1.3.1/gnu-4.9.2
module load python3/recommended
module load parallel
module load samtools/1.9/gnu-4.9.2

#input file
ls raw_data/*/*dedup_rg.bam > bam_list.txt
echo "ls raw_data/*/*dedup_rg.bam > bam_list.txt"

# output files
#output_SNP=x_x_0_final.vcf
echo "output_SNP="x_x_0_092023.vcf""

# Pool names  
name1="mM_A_0" 
name2="mM_B_0"
name3="mM_C_0"
name4="mM_D_0"
name5="mM_E_0" 
name6="tT_A_0"
name7="tT_B_0" 
name8="tT_C_0" 
name9="tT_D_0" 
name10="tT_E_0"


# Run mpileup
#samtools mpileup -Ou -f dmel-all-chromosome-r6.51.fa -B -b\
#  bam_list.txt > output_$name1-$name10.mpileup
#echo "mpileup -Ou -f dmel-all-chromosome-r6.51.fa -B -b\
#  bam_list.txt > output_$name1-$name10.mpileup"

# Run PoolSNP
 ~/scripts/PoolSNP.sh \
  output=~/data/sequences/t.i.m.e/x_x_0_092023.vcf \
  mpileup=~/Scratch/t.i.m.e/sequences/output_$name1-$name10.mpileup \
  reference=~/Scratch/t.i.m.e/sequences/dmel-all-chromosome-r6.51.fa \
  names=$name1,$name2,$name3,$name4,$name5,$name6,$name7,$name8,$name9,$name10 \
  min-cov=8 \
  max-cov=0.95 \
  min-count=2 \
  min-freq=0.0025 \
  miss-frac=0.80 \
  bq=15 \
  jobs=16

echo "Operation complete"