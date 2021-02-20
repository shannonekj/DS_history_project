#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J SFSsing
#SBATCH -e SFS_singletons.%j.err
#SBATCH -o SFS_singletons.%j.out
#SBATCH -c 20
#SBATCH --time=03:03:00
#SBATCH --mem=60G
#SBATCH -p bigmemh

set -e # exits upon failing command
set -v # verbose -- all lines
hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"
THREADS=${SLURM_NTASKS}
echo "Threads: $THREADS"
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1024)
echo "Mem: $MEM"

#### NOTES: ####
# This script is to try to figure out why we are getting so many singletons in out SFS.
#	Altered flags:	-baq
#			-C
#			-minMapQ

#### SETUP ####
# directories
pop="DS_history"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
old_dir="${para_dir}/results_SFS_unfold_wParalogs"
out_dir="${para_dir}/results_SFS_singletons"

ref="${pop}_contigs_250.fasta"
bamlist="${old_dir}/${pop}.rand20.bamlist"

mkdir -p ${out_dir}
cd ${out_dir}

touch README
echo "This directory's purpose is to house SFSs to try to figure out why we are seeing so many singletons in our SFS generated from RAD sequencing data. I will be generating and comparing unfolded SFS" >> README
echo "$(date)" >> README
echo "Bamlist for SFS can be found at ${bamlist}" >> README
echo "Reference partial genome assembly is located at ${para_dir}/${ref}" >> README

###################
###   get sfs   ###
###################

# ALREADY COMPLETED #echo "Indexing reference."
# ALREADY COMPLETED #samtools faidx ../${ref}
# ALREADY COMPLETED #sleep 1m
# ALREADY COMPLETED #touch ../${ref}.fai

module load bio 
angsd --version

SFS_1a="angsd -bam ${bamlist} \
	-out SFS_minMapQ10 \
	-anc ../${ref} \
	-GL 2 -doSaf 1 \
	-minMapQ 10 -minQ 20"

SFS_2a="angsd -bam ${bamlist} \
	-out SFS_minMapQ30 \
	-anc ../${ref} \
	-GL 2 -doSaf 1 \
	-minMapQ 30 -minQ 20"

SFS_3a="angsd -bam ${bamlist} \
        -out SFS_minMapQ10_baq1_C50 \
        -anc ../${ref} \
        -GL 2 -doSaf 1 \
        -minMapQ 10 -minQ 20 \
	-ref ../${ref} \
        -baq 1 -C 50"

SFS_4a="angsd -bam ${bamlist} \
        -out SFS_minMapQ30_baq1_C50 \
        -anc ../${ref} \
        -GL 2 -doSaf 1 \
        -minMapQ 30 -minQ 20 \
	-ref ../${ref} \
	-baq 1 -C 50"

echo "$(date) : Creating site allele frequency likelihood based on genotype likelihoods assuming HWE."
echo "All SFS were run with the following base commands:" >> README
echo "    angsd -bam ${bamlist} -anc ../${ref} -GL 2 -doSaf 1 -minQ 20" >> README
echo "And were run with additional commands stated in each file name" >> README

echo ${SFS_1a}
eval ${SFS_1a}

echo ${SFS_2a}
eval ${SFS_2a}

echo ${SFS_3a}
eval ${SFS_3a}

echo ${SFS_4a}
eval ${SFS_4a}

echo "$(date) : Generating unfolded site frequency spectrum." 

realSFS SFS_minMapQ10.saf.idx -maxIter 100 > SFS_minMapQ10.sfs
realSFS SFS_minMapQ30.saf.idx -maxIter 100 > SFS_minMapQ30.sfs
realSFS SFS_minMapQ10_baq1_C50.saf.idx -maxiter 100 > SFS_minMapQ10_baq1_C50.sfs
realSFS SFS_minMapQ30_baq1_C50.saf.idx -maxiter 100 > SFS_minMapQ30_baq1_C50.sfs

echo "$(date) : plotting SFS."
~/scripts/plotSFS.R SFS_minMapQ10.sfs
~/scripts/plotSFS.R SFS_minMapQ30.sfs
~/scripts/plotSFS.R SFS_minMapQ10_baq1_C50.sfs
~/scripts/plotSFS.R SFS_minMapQ30_baq1_C50.sfs

end=`date +%s`
runtime=$((end-start))

echo Runtime: $runtime
