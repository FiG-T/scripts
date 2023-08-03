#!/bin/bash

#  2 - Processing short read sequences: Aligning to the Dros reference genome

################################################################################

#      This script is the second step in processing short read data from pooled 
#      DNA sequenced samples. 
#      This script uses the BWA - MEM package (arXiv:1303.3997v2) to perfom an 
#      ultrafast alignment of short reads to the (specified) reference genome.  
#      BWA MEM was selected due to it's high accuracy and specificity, its 
#      compatibility with later SNP callers, and fast computing speed. 

#      Note:  This does not use bowtie2 (as in earlier versions).

#      Written by FiG-T (July 2023)

################################################################################    

#  Define the shell being used: 
#$ -S /bin/bash 

#  Request RAM required 
#$ -l mem=70G

# Request TMPDIR space
#$ -l tmpfs=25G

#  Request/specify time needed/limit
#$ -l h_rt=10:00:0

#$ -wd /home/zcbtfgg/Scratch/t.i.m.e/sequences
   # Note: Myriad nodes cannot write files directly to the home directory

#  Number of (shared) parrallel environments/ processors required.
#$ -pe smp 10

# Specify task IDs
#$ -t 8 
# 8 = the number for my test file in the directory list

#####  figt: silenced (for running on computer science cluster)
#  Request 'hard virtual memory' space:
# -l h_vmem=500M
#  Request 'transcendent memory' space
# -l tmem=500M
#  Temporary scratch resource requirement
# -l tscratch=15G

################################################################################

datadirectory=$(ls raw_data | awk NR=="$SGE_TASK_ID")
  # where the line of the directory matches the task ID (specified above)
datapath="raw_data/"$datadirectory

# set the working directory for each sample
cd "$datapath"
echo "cd $datapath"

# specify output file name: 
outfile=$datadirectory"__mapped.sam" 
echo "$outfile"

# once in the sample-specific subfolder - call BWA mem 
/shared/ucl/apps/bwa/0.7.12/gnu-4.9.2/bwa mem \
  -t 10 \
 ../../dmel-all-chromosome-r6.51.fa \
  *R1_trimmed.fastq.gz *R2_trimmed.fastq.gz > "$outfile"

echo "/shared/ucl/apps/bwa/0.7.12/gnu-4.9.2/bwa mem \
  -t 10 \
  ../../dmel-all-chromosome-r6.51.fa \
  *R1_trimmed.fastq.gz *R2_trimmed.fastq.gz > $outfile
  "

cd ../..

echo "Operation complete"
