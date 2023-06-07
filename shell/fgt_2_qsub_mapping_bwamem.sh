#!/bin/bash

#  2 - Processing short read sequences: Aligning to the Dros reference genome

################################################################################

#      This script is also adapted from scripts from M.R and is the 
#      second step in processing short read data from pooled DNA sequenced 
#      samples. This script creates temporary directories in the Scratch repo, 
#      and uses the BWA - MEM package (arXiv:1303.3997v2) to perfom an ultrafast
#      alignment of short reads to the (specified) reference genome. BWA MEM was
#      selected due to it's high accuracy and specificity, its compatibility 
#      with later SNP callers, and fast computing speed. 
#      Note:  This does not use bowtie2 (as in earlier versions).

#      Modified by FiG-T (May 2023)

################################################################################    

#  Define the shell being used: 
#$ -S /bin/bash 

#  Request RAM required 
#$ -l mem=10G

# Request TMPDIR space
#$ -l tmpfs=100G

#  Request/specify time needed/limit
#$ -l h_rt=01:40:0

#$ -wd /home/zcbtfgg/Scratch/t.i.m.e/sequences
   # Note: Myriad nodes cannot write files directly to the home directory

#  Number of (shared) parrallel environments/ processors required.
#$ -pe smp 4

#  Specify task IDs: 
#$ -t 1-2

#####  figt: silenced (for running on computer science cluster)
#  Request 'hard virtual memory' space:
# -l h_vmem=500M
#  Request 'transcendent memory' space
# -l tmem=500M
#  Temporary scratch resource requirement
# -l tscratch=15G

################################################################################

# Create a scratch directory for current task
tmp_dir=$JOB_ID"."$SGE_TASK_ID
tmp_path=$TMPDIR"/"$tmp_dir
mkdir -p $tmp_path

echo "Created directory $tmp_path"

# Get name of ith diectory
#  This is not really a local directory but where your raw data is stored 
datadirectory=$(ls raw_data | awk NR==$SGE_TASK_ID)
datapath="raw_data/"$datadirectory
echo "Data path $datapath"

# Defining the input and output filenames: 
cd $datapath
#  sourcing the outputs from the first script
R1_infile=$(ls *trimmed.fq.gz | awk 'NR==1')
R2_infile=$(ls *trimmed.fq.gz | awk 'NR==2')

cd ../.. # (takes you back to the working directory in Scratch)


outfile=$datadirectory"_mapped.sam"  
echo "Outfile $outfile"

# Copy input files to scratch
 rsync -raz $datapath/$R1_infile $tmp_path
 echo  "rsync -raz $datapath/$R1_infile $tmp_path"

# echo "rsync -raz $localpath/$R2_infile $scratchpath"
 rsync -raz $datapath/$R2_infile $tmp_path

# Create scratch directory for reference genome
 echo "Copying: reference genome files"
 echo "mkdir -p $TMPDIR/ref_genome"
 mkdir -p $TMPDIR/ref_genome

 rsync -raz dmel-all-chromosome-r6.51* $TMPDIR/ref_genome/   
echo "rsync -raz drosophila_r633.* $TMPDIR/ref_genome/"

# Run mapping 
#  This uses the BWA programme to map the trimmed fasta files to the 
#  reference genome specified. 
#  'bwa mem' is specified as this operates best for reads >70bp.
# '-t' number of threads
# [forward infile] [reverse strand infile] > [outfile]

/shared/ucl/apps/bwa/0.7.12/gnu-4.9.2/bwa mem \
  -t 4  $TMPDIR/ref_genome/dmel-all-chromosome-r6.51.fa \
  $tmp_path/$R1_infile $tmp_path/$R2_infile > $tmp_path/$outfile

echo "/shared/ucl/apps/bwa/0.7.12/gnu-4.9.2/bwa mem"


# Copy results back to local directory
rsync -raz $tmp_path/$outfile $datapath
echo "rsync -raz $tmp_path/$outfile $datapath"
