#!/bin/bash

#  3 - Processing short read sequences: Converting SAM to BAM files

################################################################################

#      This script is also adapted from scripts from M.R and is the third step 
#      in processing short read data from pooled DNA sequenced samples.  This 
#      script navigates to the output directory from 'fgt_2_bwa_simple.sh'
#      and uses Samtools (https://doi.org/10.1093/gigascience/giab008) to sort
#      the .sam files into .bam (binary, which can be read faster) files. These are 
#      processed using Picard (https://broadinstitute.github.io/picard/index.html)
#      and the GATK (https://gatk.broadinstitute.org/hc/en-us) software to realign,
#      remove duplicated reads, and calculate the depth.  

#      Modified by FiG-T (May 2023)

################################################################################   

#  Define the shell being used: 
#$ -S /bin/bash

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
#$ -pe smp 4

#  Specify task IDs: 
#$ -t 1
# 1 = AA_test, 8 = tT_B_0 (used as a test sample)

################################################################################

## Navigate to the sample directory
datadirectory=$(ls raw_data | awk NR=="$SGE_TASK_ID")
  # where the line of the directory matches the task ID (specified above)
datapath="raw_data/"$datadirectory

# Set the working directory for each sample
cd "$datapath"
echo "cd $datapath"

## Remove reads with low quality and covert to BAM 
  # Using the SAMtools software
/shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools view \
  -q 20 -bT ../../dmel-all-chromosome-r6.51.fa.fai  *__mapped.sam\    
  # skip reads that have a mapping quality below 20
  # use the defined reference genome
  # use the mapped sam file (from bwa) as the input
  | /shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools sort \
    # pipe the output of 'view' to sort (hence no output file is specified for view)
  -o $datadirectory"_filtered_sorted.bam"

echo "/shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools view \
  -q 20 -bT ../../dmel-all-chromosome-r6.51.fai  *__mapped.sam  \
  | /shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools sort \
  -o $datadirectory"_filtered_sorted.bam""


## Remove PCR duplicates (these are not independent reads)
dedup_output=$datadirectory"_dedup.bam"
dedup_metrics=$datadirectory"_dedup_metrics.txt"

/shared/ucl/apps/java/jdk1.8.0_92/bin/java -jar 
 /shared/ucl/apps/picard-tools/2.18.9/bin/picard.jar MarkDuplicates \
  INPUT=*_mapped_sorted.bam \
  OUTPUT=$dedup_output \
  METRICS_FILE=$dedup_metrics \
  REMOVE_DUPLICATE=true  # as will not be needed for downstream analysis

echo "performed: /shared/ucl/apps/java/jdk1.8.0_92/bin/java -jar 
 /shared/ucl/apps/picard-tools/2.18.9/bin/picard.jar MarkDuplicates \
  INPUT=*_mapped_sorted.bam \
  OUTPUT=$dedup_output \
  METRICS_FILE=$dedup_metrics \
  REMOVE_DUPLICATE=true"

## Add read groups (to allow the pools to be uniquely identified in  
# downstream analysis) 

# specifiy outfile:
dedup_rg_output=$datadirectory"_dedup_rg.bam" 

# run command:
/shared/ucl/apps/java/jdk1.8.0_92/bin/java -jar 
 /shared/ucl/apps/picard-tools/2.18.9/bin/picard.jar AddOrReplaceReadGroups \ 
  INPUT=*_dedup.bam  \  # select input file 
  OUTPUT=$dedup_rg_output \
  RGSM=$datadirectory      `# sample/pool name`    \
  RGPL=ILLUMINA            `# sequencing platform`  \
  RGPU=$datadirectory-01   `# platform unit (normally flowcell.lane.barcode)` \
  RGLB=lib1                 # library used 

# print command: (to log file)
echo "/shared/ucl/apps/java/jdk1.8.0_92/bin/java -jar 
 /shared/ucl/apps/picard-tools/2.18.9/bin/picard.jar AddOrReplaceReadGroups \ 
  INPUT=*_dedup.bam \  # select input file 
  OUTPUT=$dedup_rg_output \
  RGSM=$datadirectory \   
  RGPL=ILLUMINA \
  RGPU=$datadirectory-01 \
  RGLB=lib1
"
## Index the bam file: 
#  This speeds up later processing of the file
/shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools index \
  *_dedup_rg.bam

# print to log: 
echo "/shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools index \
  *_dedup_rg.bam"

# Note: indel realignment is not included in the pipeline for GATK 4 and 
# is not needed for newer variant calling methods.

# Copy bam files to backed up directory:
rsync -raz *_dedup_rg.bam  ~/data/sequences/t.i.m.e/bam_reads
echo "rsync -raz *_dedup_rg.bam  ~/data/sequences/t.i.m.e/bam_reads"

################################################################################

# Create targets for realignment

#/shared/ucl/apps/java/jdk1.8.0_92/bin/java -jar $GATKPATH/GenomeAnalysisTK.jar\
#  -T RealignerTargetCreator \
#  -R $scratchpath/ref_genome/dmel-all-chromosome-r6.33.fasta \
#  -I $scratchpath/${filename_root}_dedup_RG.bam \
#  -o $scratchpath/${filename_root}_dedup_RG_realign.intervals

# Use IndelRealigner Tool from GATK.3

#/shared/ucl/apps/java/jdk1.8.0_92/bin/java $GATKPATH/GenomeAnalysisTK.jar\
#  -T IndelRealigner \
#  -R $scratchpath/ref_genome/dmel-all-chromosome-r6.33.fasta \
#  -I $scratchpath/${filename_root}_dedup_RG.bam \
#  --targetIntervals $scratchpath/${filename_root}_dedup_RG_realign.intervals \
#  -o $scratchpath/${filename_root}_final.bam

## Generate read depths
#
#/shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools depth \
#  -a $scratchpath/${filename_root}_final.bam > \
#  $scratchpath/${filename_root}_final_depth.txt


################################################################################

## Call SNPs using unified genotyper
#echo "/share/apps/jdk1.8.0_131/bin/java -jar /share/apps/genomics/GenomeAnalysisTK-3.8.1.0/GenomeAnalysisTK.jar -T UnifiedGenotyper -R $scratchpath/ref_genome/dmel-all-chromosome-r6.33.fasta -I $scratchpath/${filename_root}_final.bam -o $scratchpath/${filename_root}_SNPs.vcf"
#/share/apps/jdk1.8.0_131/bin/java -jar /share/apps/genomics/GenomeAnalysisTK-3.8.1.0/GenomeAnalysisTK.jar -T UnifiedGenotyper -R $scratchpath/ref_genome/dmel-all-chromosome-r6.33.fasta -I $scratchpath/${filename_root}_final.bam -ploidy 120 -o $scratchpath/${filename_root}_SNPs.vcf
#echo "rsync -raz $scratchpath/${filename_root}_SNPs.vcf  $localpath/"
#rsync -raz $scratchpath/${filename_root}_SNPs.vcf  $localpath/
#echo "rsync -raz $scratchpath/${filename_root}_SNPs.vcf.idx  $localpath/"
#rsync -raz $scratchpath/${filename_root}_SNPs.vcf.idx  $localpath/

