#!/bin/bash

#  2 - Processing short read sequences: Aligning to the Dros reference genome

################################################################################

#      This script is also adapted from scripts from M.R and is the 
#      second step in processing short read data from pooled DNA sequenced 
#      samples. This script creates temporary directories in the Scratch repo, 
#      and uses the Bowtie package (http://genomebiology.com/2009/10/3/R25) to 
#      perfom an ultrafast alignment of short reads to the (specified) reference 
#      genome. 

#      Modified by FiG-T (May 2023)

################################################################################    

#  Define the shell being used: 
#$ -S /bin/bash 

#  Request 'hard virtual memory' space:
#$ -l h_vmem = 500M

#  Request 'transcendent memory' space
#$ -l tmem = 500M

#  Request/specify time needed/limit
#$ -l h_rt = 4:00:0

#$ -wd /home/zcbtfgg/Scratch/t.i.m.e/sequences
   # Note: Myriad cannot write files directly to the home directory

#  Temporary scratch resource requirement
#$ -l tscratch = 15G

#  Number of (shared) parrallel environments/ processors required.
#$ -pe smp 4

#  Specify task IDs: 
#$ -t 61-90

################################################################################

# Create a scratch directory for current task
scratch_dir=$JOB_ID"."$SGE_TASK_ID
scratchpath="tmp_data/"$scratch_dir
mkdir -p $scratchpath

echo "Created directory $scratchpath"

# Get name of ith diectory
#  This is not really a local directory but where your raw data is stored 
datadirectory=$(ls raw_data | awk NR==$SGE_TASK_ID)
datapath="raw_data/"$datadirectory
echo "Data data path $datapath"

# Defining the input and output filenames: 
cd $datapath
#  sourcing the outputs from the first script
R1_infile=$(ls *trimmed.fq.gz | awk 'NR==1')
R2_infile=$(ls *trimmed.fq.gz | awk 'NR==2')

cd ../.. # (takes you back to the working directory in Scratch)


outfile=$datadirectory"_mapped.sam"  
echo "Outfile $outfile"

# Copy input files to scratch
#  fgt:  silenced for now (everything is in scratch anyway)
# echo "rsync -raz $localpath/$R1_infile $scratchpath"
# rsync -raz $localpath/$R1_infile $scratchpath
# echo "rsync -raz $localpath/$R2_infile $scratchpath"
# rsync -raz $localpath/$R2_infile $scratchpath

# Create scratch directory for reference genome
# fgt: silenced -- keep ref genome in accessible location
# echo "Copying: reference genome files"
# echo "mkdir -p $scratchpath/ref_genome"
# mkdir -p $scratchpath/ref_genome
# echo "rsync -raz drosophila_r633_index/drosophila_r633.* $scratchpath/ref_genome/"
# rsync -raz drosophila_r633_index/drosophila_r633.* $scratchpath/ref_genome/

# Run mapping 
#  This uses the bowtie package to map the trimmed fasta files to the 
#  reference genome specified. 
# '-x' specifies the index file
# '-1' input file 1
# '-2' input file 2
# '-S' the file for the SAM output

/shared/ucl/apps/bowtie2/bowtie2-2.2.5/bowtie2 --end-to-end -p 4 \
  -x ~/data/sequences/ref_genome/drosophila_r633 \
  -1 $datapath/$R1_infile -2 $datapath/$R2_infile \
  -S $scratchpath/$outfile
# collect infiles directly from the raw_data scratch folder (datapath), put the outfile in 
# the temp_data scratch directory

echo "/shared/ucl/apps/bowtie2/bowtie2-2.2.5/bowtie2 --end-to-end -p 4 -x \
  $scratchpath/ref_genome/drosophila_r633 -1 $datapath"/"$R1_infile -2 \
  $datapath"/"$R2_infile -S $scratchpath"/"$outfile"

# copy results back to local directory
# fgt: also silenced
# echo "rsync -raz $scratchpath/$outfile $localpath"
# rsync -raz $scratchpath/$outfile $localpath
