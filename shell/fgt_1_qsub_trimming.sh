#!/bin/bash

# 1 - Processing short read sequences: Trimming the ends 

################################################################################

#      This script (as well as the following) is adapted from M.R and is the 
#      first step in processing short read data from pooled DNA sequenced 
#      samples.  Files for the first and second paired-end reads in the dataset 
#      are identified and trimmed using the Cutadapt package 
#      (DOI:10.14806/ej.17.1.200). 

#      Modified by FiG-T (May 2023)

################################################################################

#  Define the used shell:
#$ -S /bin/bash 

#  Request 'hard virtual memory' space:
#$ -l h_vmem=1G

#  Request 'transcendent memory' space
#$ -l tmem=1G

#  Request/specify time needed/limit
#$ -l h_rt=2:00:0

#  Specify the working directory
#$ -wd /home/zcbtfgg/Scratch/t.i.m.e/sequences

#  Specify task IDs: 
#$ -t 4-90

################################################################################
 
source /shared/ucl/apps/python/bundles/python39-6.0.0/venv/bin/python3

#  Move to ith diectory
directory=$(ls raw_data | awk NR==$SGE_TASK_ID)
  #  this retrieves the directory associated with the current task ID and assigns
  #  it to the variable 'directory'.
  #  where '$SGE_TASK_ID' links back to the task IDs created earlier (line 26)
echo "$directory"

#  Specify the path to the directory with the data.
path="raw_data/"$directory


#  Get input filenames
#  .two files are provided by the sequencing company per sample, these will be
#   combined into a single SAM file at a later stage.
R1_infile=$(ls $path/*.gz | awk 'NR==1')
R2_infile=$(ls $path/*.gz | awk 'NR==2')
echo "$R1_infile"

# Create ouput filenames
R1_outfile=$path"/"$directory"_R1_trimmed.fq.gz"
R2_outfile=$path"/"$directory"_R2_trimmed.fq.gz"
echo "$R1_outfile"

#  Trim the primers from the short reads. 
#  .this uses the cutadapt tool
#  .check that these sequences match those provided by the sequencing results. 
#  .the second sequence is the reverse strand to what is specified by the 
#    sequencing report. 
#  '-q' specifies the quality score cutoff (things below this will be discarded)
#  '-o' specifies the output file for the first read in a paired-end seq dataset.
#  '-p' specifies the output file for the second read in a paired-end seq dataset.
/shared/ucl/apps/python/bundles/python39-6.0.0/venv/bin/cutadapt -a \
  AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT -A \
  CAAGCAGAAGACGGCATACGAGATNNNNNNGTGACTGGAGTTCAGACGTGTGCTCTTCCGATC -q 10 \
  -o $R1_outfile -p $R2_outfile $R1_infile $R2_infile
