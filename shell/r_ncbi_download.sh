#!/bin/bash

#   Downloading human mtDNA sequences from NCBI

################################################################################

#      This scripts calls an R script which uses entrez and it's API to download 
#      all the genbank file information for every known full human mitochondrial
#      genome on NCBI.  

#      Written by FiG-T (June 2023).

################################################################################

#  Define the shell being used: 
#$ -S /bin/bash 

#  Request RAM required 
#$ -l mem=1G

# Request TMPDIR space
#$ -l tmpfs=1G

#  Request/specify time needed/limit
#$ -l h_rt=00:20:00

#$ -wd /home/zcbtfgg/Scratch/lhf/data
   # Note: Myriad nodes cannot write files directly to the home directory

################################################################################

cd $TMPDIR

no_gb = ".No_1_2000_"

#  Load the R module
module -f unload compilers mpi gcc-libs
module load r/recommended

#  Run the R script
R --no-save < ~/scripts/lhf_entrez_download.R >  lhf_download.out
echo "R --no-save < ~/scripts/lhf_entrez_download.R >  lhf_download.out"

# Transfer files back into the scratch space
cp $TMPDIR/lhf_download.out ~/Scratch/lhf/data/$JOB_ID"_"$no_gb"_lhf.out"
echo "cp $TMPDIR/lhf_download.out ~/Scratch/lhf/data/$JOB_ID/.No1_2000_lhf_download.out"

cp $TMPDIR/mito_gb.txt ~/Scratch/lhf/data/$JOB_ID"."$no_gb"mito_gb.txt"
echo "cp $TMPDIR/mito_gb.txt ~/Scratch/lhf/data/$JOB_ID"."$no_gb"_mito_gb.txt"

echo "R script complete" 
