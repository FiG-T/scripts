#!/bin/bash

#  4 - Processing short read sequences: Indexing BAM files

################################################################################

#      This script is also adapted from scripts from M.R and is the fourth step 
#      in processing short read data from pooled DNA sequenced samples.  This
#      uses the samtools software (https://doi.org/10.1093/gigascience/giab008)
#      to create an index file (filename.bam.bai) which acts as an 'external 
#      table of contents', but does not itself contain any sequence data.

#      Modified by FiG-T (May 2023)

################################################################################

#  Define the shell being used: 
#$ -S /bin/bash

#  Request 'hard virtual memory' space:
#$ -l h_vmem = 14G

#  Request 'transcendent memory' space
#$ -l tmem = 14G

#  Request/specify time needed/limit
#$ -l h_rt = 00:15:0

#$ -wd /home/zcbtfgg/data/sequences/t.i.m.e
   # Note: Myriad cannot write files directly to the home directory

#  Specify task IDs: 
#$ -t 3-90

################################################################################

# move to ith diectory
directory=$(ls bam_reads| awk NR==$SGE_TASK_ID)

bam_file="raw_data/"$directory"/"$directory"_mapped_final.bam"

# Run samtools to index
/shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools index $bam_file
