#!/bin/bash

#  4 - Processing short read sequences: Indexing BAM files

################################################################################

#      This script is also adapted from scripts from M.R and is the fith step 
#      in processing short read data from pooled DNA sequenced samples.  This
#      uses the SNVer software (doi: 10.1093/nar/gkr599) to call variants for
#      the indexed bam files.

#      Modified by FiG-T (May 2023)

################################################################################

#  Define the shell being used: 
#$ -S /bin/bash

#  Request 'hard virtual memory' space:
#$ -l h_vmem = 60G

#  Request 'transcendent memory' space
#$ -l tmem = 60G

#  Request/specify time needed/limit
#$ -l h_rt = 20:00:0

#$ -wd /home/zcbtfgg/data/sequences/t.i.m.e
   # Note: Myriad cannot write files directly to the home directory

################################################################################

#$ -S /bin/bash #defines the used shell
#$ -l h_vmem=60G,tmem=60G,h_rt=20:00:0
#$ -wd /SAN/reuterlab/FA-AF/bam_reads

## SNVer check
/share/apps/java/bin/java -jar /share/apps/SNVer-0.5.3/SNVerPool.jar \
   -n 106 -i bam/ -o SNVer_output\
   -r ../drosophila_r633_index/dmel-all-chromosome-r6.33.fasta
   
echo "done"