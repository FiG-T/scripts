#!bin/bash 

# Creating a bwa index for the Drosphila referenece genome

################################################################################

#  In order to use the reference genome for mapping & variant calling index files 
#  must be available.  This script generates such files for the bwa mem mapping
#  from the .fasta file (available at ftp.flybase.net/releases/FB2023/dmel_r6.51/dna
#  /fasta/dmel-all-chromosome-r6.51).  

#  Written by FiG-T in June 2023. 

################################################################################

#  Define the shell being used: 
#$ -S /bin/bash 

#  Request RAM required 
#$ -l mem=5G

# Request TMPDIR space
#$ -l tmpfs=5G

#  Request/specify time needed/limit
#$ -l h_rt=00:03:0

#$ -wd /home/zcbtfgg/Scratch/t.i.m.e/sequences
   # Note: Myriad nodes cannot write files directly to the home directory

################################################################################


/shared/ucl/apps/bwa/0.7.12/gnu-4.9.2/bwa index dmel-all-chromosome-r6.51.fasta 

