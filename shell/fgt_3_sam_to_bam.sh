#!/bin/bash

#  3 - Processing short read sequences: Converting SAM to BAM files

################################################################################

#      This script is also adapted from scripts from M.R and is the third step 
#      in processing short read data from pooled DNA sequenced samples.  This 
#      script navigates to the output directory from 'fgt_2_qsub_mapping.sh'
#      and uses Samtools (https://doi.org/10.1093/gigascience/giab008) to sort
#      the .sam files into .bam (binary, can be read faster) files. These are 
#      processed using Picard (https://broadinstitute.github.io/picard/index.html)
#      and the GATK (https://gatk.broadinstitute.org/hc/en-us) software to realign,
#      remove duplicated reads, and calculate the depth.  

#      Modified by FiG-T (May 2023)

################################################################################   

#  Define the shell being used: 
#$ -S /bin/bash

#  Request 'hard virtual memory' space:
#$ -l h_vmem = 32G

#  Request 'transcendent memory' space
#$ -l tmem = 32G

#  Request/specify time needed/limit
#$ -l h_rt = 6:00:0

#$ -wd /home/zcbtfgg/Scratch/t.i.m.e/sequences
   # Note: Myriad cannot write files directly to the home directory

#  Temporary scratch resource requirement
#$ -l tscratch = 75G

#  Number of (shared) parrallel environments/ processors required.
#$ -pe smp 4

#  Specify task IDs: 
#$ -t 61-90

################################################################################

#  Link to scratch directory for current task (where the outputs from the
#  mapping are)
echo "Creating directory in scratch:"
echo "scratch_dir=$JOB_ID"."$SGE_TASK_ID"

scratch_dir= $JOB_ID"."$SGE_TASK_ID
scratchpath="tmp_data/"$scratch_dir

cd $scratchpath

# Define filenames:
filename=$(ls *.sam | awk NR==1)
echo "Filename: $filename"
filename_root=${filename%%.*}
echo "Filename root: $filename_root"

cd ../..
echo "PWD: $(pwd)"

## create directory and copy reference genome file
echo "Copying: reference genome files"
echo "mkdir -p $scratchpath/ref_genome"

mkdir -p $scratchpath/ref_genome

echo "rsync -raz drosophila_r633_index/dmel-all-chromosome-r6.33.fasta\
 $scratchpath/ref_genome/"
rsync -raz drosophila_r633_index/dmel-all-chromosome-r6.33.fasta \
  $scratchpath/ref_genome/

echo "rsync -raz drosophila_r633_index/dmel-all-chromosome-r6.33.fasta.fai\
 $scratchpath/ref_genome/"
rsync -raz drosophila_r633_index/dmel-all-chromosome-r6.33.fasta.fai\
 $scratchpath/ref_genome/

echo "rsync -raz drosophila_r633_index/dmel-all-chromosome-r6.33.dict\
 $scratchpath/ref_genome/"
rsync -raz drosophila_r633_index/dmel-all-chromosome-r6.33.dict\
 $scratchpath/ref_genome/

echo "Ref fasta: $(ls $scratchpath/ref_genome/*.fasta | awk NR==1)"


# Remove reads with low quality and covert to BAM
#  Using the SAMtools software

echo "/shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools view -q 20 -bS \
  $scratchpath/${filename_root}.sam \
  | /shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools sort \
  -o $scratchpath/${filename_root}_filtered_sorted.bam"

/shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools view -q 20 \
  -bS $scratchpath/${filename_root}.sam \
  | /shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools sort \
  -o $scratchpath/${filename_root}_filtered_sorted.bam

# Remove duplicated reads
echo "/shared/ucl/apps/java/jdk1.8.0_92/bin/java -jar \
  /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates\
  INPUT=$scratchpath/${filename_root}_filtered_sorted.bam \
  OUTPUT=$scratchpath/${filename_root}_dedup.bam \
  METRICS_FILE=$scratchpath/${filename_root}_dedup_metrics.txt"

/shared/ucl/apps/java/jdk1.8.0_92/bin/java -jar $PICARDPATH/picard.jar\
  MarkDuplicates INPUT = $scratchpath/${filename_root}_filtered_sorted.bam\
  OUTPUT = $scratchpath/${filename_root}_dedup.bam\
  METRICS_FILE = $scratchpath/${filename_root}_dedup_metrics.txt

# Define read groups
echo "/shared/ucl/apps/java/jdk1.8.0_92/bin/java  -jar\
  /share/apps/genomics/picard-2.20.3/bin/picard.jar AddOrReplaceReadGroups\
  INPUT = $scratchpath/${filename_root}_dedup.bam\
  OUTPUT = $scratchpath/${filename_root}_dedup_RG.bam LB = $filename_root\
  PL = ILLUMINA PU = 1 SM = $filename_root"

/shared/ucl/apps/java/jdk1.8.0_92/bin/java -jar $PICARDPATH/picard.jar\
  AddOrReplaceReadGroups INPUT = $scratchpath/${filename_root}_dedup.bam\
  OUTPUT=$scratchpath/${filename_root}_dedup_RG.bam LB=$filename_root\
  PL=ILLUMINA PU=1 SM=$filename_root

# Index bam file
echo "/share/apps/genomics/samtools-1.9/bin/samtools index \
  $scratchpath/${filename_root}_dedup_RG.bam"

/shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools index \
  $scratchpath/${filename_root}_dedup_RG.bam

# Create targets for realignment
echo "/shared/ucl/apps/java/jdk1.8.0_92/bin/java -jar\
  /share/apps/genomics/GenomeAnalysisTK-3.8.1.0/GenomeAnalysisTK.jar\
  -T RealignerTargetCreator -R \
  $scratchpath/ref_genome/dmel-all-chromosome-r6.33.fasta -I \
  $scratchpath/${filename_root}_dedup_RG.bam \
  -o $scratchpath/${filename_root}_dedup_RG_realign.intervals"

/shared/ucl/apps/java/jdk1.8.0_92/bin/java -jar $GATKPATH/GenomeAnalysisTK.jar\
  -T RealignerTargetCreator \
  -R $scratchpath/ref_genome/dmel-all-chromosome-r6.33.fasta \
  -I $scratchpath/${filename_root}_dedup_RG.bam \
  -o $scratchpath/${filename_root}_dedup_RG_realign.intervals

# Use IndelRealigner Tool from GATK.3
echo "/shared/ucl/apps/java/jdk1.8.0_92/bin/java -jar\
  /share/apps/genomics/GenomeAnalysisTK-3.8.1.0/GenomeAnalysisTK.jar\
  -T IndelRealigner -R $scratchpath/ref_genome/dmel-all-chromosome-r6.33.fasta\
  -I $scratchpath/${filename_root}_dedup_RG.bam --targetIntervals \
  $scratchpath/${filename_root}_dedup_RG_realign.intervals\
   -o $scratchpath/${filename_root}_final.bam"

/shared/ucl/apps/java/jdk1.8.0_92/bin/java $GATKPATH/GenomeAnalysisTK.jar\
  -T IndelRealigner \
  -R $scratchpath/ref_genome/dmel-all-chromosome-r6.33.fasta \
  -I $scratchpath/${filename_root}_dedup_RG.bam \
  --targetIntervals $scratchpath/${filename_root}_dedup_RG_realign.intervals \
  -o $scratchpath/${filename_root}_final.bam

## Generate read depths
echo "/share/apps/genomics/samtools-1.9/bin/samtools depth -a -f \
  $scratchpath/${filename_root}_final.bam > \
  $scratchpath/${filename_root}_final_depth.txt"

/shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin/samtools depth \
  -a $scratchpath/${filename_root}_final.bam > \
  $scratchpath/${filename_root}_final_depth.txt


# Copy results back to local directory
#  Transfer output files from scratch to permanent repository
safepath_bam="~/data/sequences/t.i.m.e/bam_reads"
safepath_depth="~/data/sequences/t.i.m.e/depth_files"

echo "rsync -raz $scratchpath/${filename_root}_final.bam  $safepath_bam/"
rsync -raz $scratchpath/${filename_root}_final.bam  $localoutpath_bam/

echo "rsync -raz $scratchpath/${filename_root}_final_depth.txt  $localoutpath_depth/"
rsync -raz $scratchpath/${filename_root}_final_depth.txt  $localoutpath_depth/


################################################################################

## Call SNPs using unified genotyper
#echo "/share/apps/jdk1.8.0_131/bin/java -jar /share/apps/genomics/GenomeAnalysisTK-3.8.1.0/GenomeAnalysisTK.jar -T UnifiedGenotyper -R $scratchpath/ref_genome/dmel-all-chromosome-r6.33.fasta -I $scratchpath/${filename_root}_final.bam -o $scratchpath/${filename_root}_SNPs.vcf"
#/share/apps/jdk1.8.0_131/bin/java -jar /share/apps/genomics/GenomeAnalysisTK-3.8.1.0/GenomeAnalysisTK.jar -T UnifiedGenotyper -R $scratchpath/ref_genome/dmel-all-chromosome-r6.33.fasta -I $scratchpath/${filename_root}_final.bam -ploidy 120 -o $scratchpath/${filename_root}_SNPs.vcf
#echo "rsync -raz $scratchpath/${filename_root}_SNPs.vcf  $localpath/"
#rsync -raz $scratchpath/${filename_root}_SNPs.vcf  $localpath/
#echo "rsync -raz $scratchpath/${filename_root}_SNPs.vcf.idx  $localpath/"
#rsync -raz $scratchpath/${filename_root}_SNPs.vcf.idx  $localpath/

