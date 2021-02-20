#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J uSFSnoPara
#SBATCH -e 17d_getParalog_unfoldedSFS_noParalogs.%j.err
#SBATCH -o 17d_getParalog_unfoldedSFS_noParalogs.%j.out
#SBATCH -c 20
#SBATCH --time=24:00:00
#SBATCH --mem=60G
#SBATCH -p high

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES:
# Script to generate unfolded SFS 
# Samples:
#	the SAME 20 individuals generated in /home/sejoslin/projects/DS_history/code/15_getUnfoldSFS_wParalogs.sh
#	a new random 20 individuals
# Cutoffs
#	Bonferroni	<- 29 Chi-square value from p-value=0.05/(# SNPs) [# SNPs=804447, 1df)
#	Conservative	<- 10

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
loci_dir="${data_dir}/id_loci/PRICE"
RAD_dir="${data_dir}/RAD_alignments"
para_dir="${data_dir}/paralog_id"
PARA_dir="${para_dir}/results_paralogs"
out_dir="${para_dir}/results_SFS_unfold_noParalogs"

ref="${para_dir}/${pop}_contigs_250.fasta"

mkdir -p ${out_dir}
cd ${out_dir}

### Gather bamlists
# old
cp ${para_dir}/results_SFS_unfold_wParalogs/DS_history.rand20.bamlist DS_history.same20.bamlist
echo "The old random 20 individuals are:"
cat DS_history.same20.bamlist
# make new random set of 20 individuals 
echo "Grabbing a new random 20 individuals to generate unfolded SFS for."
shuf -n 20 ../${pop}.bamlist > ${pop}.newRand20.bamlist
echo "They are:"
cat ${pop}.newRand20.bamlist

### Setup for new SFS
# make list of sets to generate SFS for under different stringency levels
echo "same" >> uSFS.list
echo "newRand" >> uSFS.list
#echo "diff" >> uSFS.list

infile="uSFS.list"
n=$(wc -l $infile | awk '{print $1}')



### Calculate saf files and the ML estimate of the sfs using the EM algorithm

### Generate unfolded SFS for all groups (same, newRand) with Bonferroni and conservative cutoffs.
x=1
while [ $x -le $n ]
do
	# Bonferroni
	cutoff=29
	grp=$(sed -n ${x}p $infile)
		echo "#!/bin/bash" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
		echo "#SBATCH -e ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.err" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
		echo "#SBATCH -o ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.out" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
		echo "#SBATCH --time=1-20:00:00" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "#SBATCH --mem=60G" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "#SBATCH -J sfs${grp}" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
		echo "#SBATCH -c 20" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "set -e" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "set -v" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
		echo "module load angsd" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
		echo "echo \$(date) Calculating site allele frequency likelihoods to create SFS." >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
		echo "angsd -bam ${out_dir}/${pop}.${grp}20.bamlist -ref ${ref} -anc ${ref} -rf ${PARA_dir}/${pop}.rand20.same.${cutoff}.loci -out ${out_dir}/${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs -GL 1 -doSaf 1 -minMapQ 20 -minQ 20 -minInd 10 -P 20" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "echo \$(date) Generating unfolded site frequency spectrum." >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
		echo "realSFS ${out_dir}/${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.saf.idx -maxIter 100 -P 20 > ${out_dir}/${pop}.rand20.${grp}.${cutoff}.sfs" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
		echo "echo \$(date) : plotting SFS." >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
		echo "$HOME/scripts/plotSFS.R ${out_dir}/${pop}.rand20.${grp}.${cutoff}.sfs" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
	sbatch ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh

	# Conservative
        cutoff=10
                echo "#!/bin/bash" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "#SBATCH -e ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.err" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "#SBATCH -o ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.out" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "#SBATCH --time=1-20:00:00" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "#SBATCH --mem=60G" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "#SBATCH -J sfs${grp}" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "#SBATCH -c 20" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "set -e" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "set -v" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "module load angsd" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "echo \$(date) Calculating site allele frequency likelihoods to create SFS." >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "angsd -bam ${out_dir}/${pop}.${grp}20.bamlist -ref ${ref} -anc ${ref} -rf ${PARA_dir}/${pop}.rand20.same.${cutoff}.loci -out ${out_dir}/${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs -GL 1 -doSaf 1 -minMapQ 20 -minQ 20 -minInd 10 -P 20" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "echo \$(date) Generating unfolded site frequency spectrum." >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "realSFS ${out_dir}/${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.saf.idx -maxIter 100 -P 18 > ${out_dir}/${pop}.rand20.${grp}.${cutoff}.sfs" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "echo \$(date) : plotting SFS." >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
                echo "$HOME/scripts/plotSFS.R ${out_dir}/${pop}.rand20.${grp}.${cutoff}.sfs" >> ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
        sbatch ${pop}.rand20.${grp}.${cutoff}.SFSnoParalogs.sh
	x=$(( $x + 1 ))	
done



