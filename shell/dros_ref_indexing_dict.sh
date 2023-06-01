#!bin/bash 

# Creating an index and sequence dictionary for the Drosphila referenece genome

################################################################################

#  In order to use the reference genome for mapping & variant calling index and
#  dictionary files must be available.  This script generates such files from 
#  the .fasta file (available at ftp.flybase.net/releases/FB2023/dmel_r6.51/dna
#  /fasta/dmel-all-chromosome-r6.51).  

#  Written by FiG-T in June 2023. 

################################################################################

#  Define the shell being used: 
#$ -S /bin/bash 

#  Request RAM required 
#$ -l mem=10G

# Request TMPDIR space
#$ -l tmpfs=10G

#  Request/specify time needed/limit
#$ -l h_rt = 00:10:0

#$ -wd /home/zcbtfgg/Scratch/t.i.m.e/sequences
   # Note: Myriad nodes cannot write files directly to the home directory

#  Name the job
#$ -N dros_ref_index_dictionary

################################################################################

#  Copy the reference fasta into the temporary node
cp dmel-all-chromosome-r6.51.fasta $TMPDIR

#  Set the directory to the temporary node.
cd $TMPDIR

#  Use Picard tools to create the .dict file: 
#  'R' : input file,  'O' : output file
/shared/ucl/apps/java/jdk1.8.0_92/bin/java -jar $PICARDPATH/picard.jar \
  CreateSequenceDirectory \
  R=dmel-all-chromosome-r6.51.fasta O=dmel-all-chromosome-r6.51.fasta.dict 

#  Use Samtools to index the fasta file
/shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools faidx \
  dmel-all-chromosome-r6.51.fasta 
