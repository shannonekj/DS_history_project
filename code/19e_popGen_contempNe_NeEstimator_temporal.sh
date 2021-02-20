#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J formatNeEst
#SBATCH -e 19e_popGen_contempNe_NeEstimator.%j.err
#SBATCH -o 19e_popGen_contempNe_NeEstimator.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES:
#	Taking files generated from allele counts for 2011-2014
#	and formatting for NeEstimator 
# 	by creating a GENEPOP file 

# set up directories
pop="DS_history"
yearFirst="2014"
year1="2013"
year2="2012"
yearLast="2011"
nInd="165"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data/"
geno_dir="/home/sejoslin/projects/${pop}/data/TempNe_genoLike${yearFirst}to${yearLast}"
sample_dir="/home/sejoslin/projects/${pop}/data/RAD_samples"
nest_dir="/home/sejoslin/projects/${pop}/data/TempNe_estimation_${yearFirst}.${year1}.${year2}.${yearLast}"

#######################################
###  make directory and select ind  ###
#######################################
module load angsd
mkdir ${nest_dir}
cd ${nest_dir}

#copy the sites shared between all population and remove header
cp ${geno_dir}/shared.sites .
sed -i 1d shared.sites

# first index the shared.sites file
angsd sites index shared.sites
sleep 1m
touch shared.sites.bin
touch shared.sites.idx

#copy bamlists for each year
cp ${geno_dir}/*.bamlist .

head -n ${nInd} Ht_${yearFirst}.bamlist > ${yearFirst}.${nInd}.bamlist
head -n ${nInd} Ht_${year1}.bamlist > ${year1}.${nInd}.bamlist
head -n ${nInd} Ht_${year2}.bamlist > ${year2}.${nInd}.bamlist
head -n ${nInd} Ht_${yearLast}.bamlist > ${yearLast}.${nInd}.bamlist


############################
###    call genos for    ### 
###       each year      ###
############################

# make .geno for yearFirst
numInd=$(wc -l ${yearFirst}.${nInd}.bamlist | awk '{print $1}')
minInd=$((${numInd}*8/10))
angsd -bam ${yearFirst}.${nInd}.bamlist -out ${yearFirst}.${nInd} -GL 1 -doMajorMinor 1 -doMaf 1 -doGeno 2 -doPost 2 -postCutoff 0.95 -minMapQ 20 -minQ 20 -SNP_pval 1e-12 -minMaf 0.05 -minInd ${minInd} -sites shared.sites

# make geno for year1
numInd=$(wc -l ${year1}.${nInd}.bamlist | awk '{print $1}')
minInd=$((${numInd}*8/10))
angsd -bam ${year1}.${nInd}.bamlist -out ${year1}.${nInd} -GL 1 -doMajorMinor 1 -doMaf 1 -doGeno 2 -doPost 2 -postCutoff 0.95 -minMapQ 20 -minQ 20 -SNP_pval 1e-12 -minMaf 0.05 -minInd ${minInd} -sites shared.sites

# make geno for year2
numInd=$(wc -l ${year2}.${nInd}.bamlist | awk '{print $1}')
minInd=$((${numInd}*8/10))
angsd -bam ${year2}.${nInd}.bamlist -out ${year2}.${nInd} -GL 1 -doMajorMinor 1 -doMaf 1 -doGeno 2 -doPost 2 -postCutoff 0.95 -minMapQ 20 -minQ 20 -SNP_pval 1e-12 -minMaf 0.05 -minInd ${minInd} -sites shared.sites

# make geno for yearLast
numInd=$(wc -l ${yearLast}.${nInd}.bamlist | awk '{print $1}')
minInd=$((${numInd}*8/10))
angsd -bam ${yearLast}.${nInd}.bamlist -out ${yearLast}.${nInd} -GL 1 -doMajorMinor 1 -doMaf 1 -doGeno 2 -doPost 2 -postCutoff 0.95 -minMapQ 20 -minQ 20 -SNP_pval 1e-12 -minMaf 0.05 -minInd ${minInd} -sites shared.sites


# unzip
gunzip ${yearFirst}.${nInd}.geno.gz
gunzip ${year1}.${nInd}.geno.gz
gunzip ${year2}.${nInd}.geno.gz
gunzip ${yearLast}.${nInd}.geno.gz


################################
###  now use PopGenTools.pl  ###
################################

perl /home/sejoslin/scripts/PopGenTools_3.00.pl GENEPOP -g ${yearFirst}.${nInd}.geno -n ${numInd} -o ${yearFirst}.${nInd}.genepop -p
perl /home/sejoslin/scripts/PopGenTools_3.00.pl GENEPOP -g ${year1}.${nInd}.geno -n ${numInd} -o ${year1}.${nInd}.genepop -p
perl /home/sejoslin/scripts/PopGenTools_3.00.pl GENEPOP -g ${year2}.${nInd}.geno -n ${numInd} -o ${year2}.${nInd}.genepop -p
perl /home/sejoslin/scripts/PopGenTools_3.00.pl GENEPOP -g ${yearLast}.${nInd}.geno -n ${numInd} -o ${yearLast}.${nInd}.genepop -p

mkdir NeEstimator_v2.1
cp /home/sejoslin/software/NeEstimator_v2.1/Ne* NeEstimator_v2.1/.
cp *.genepop NeEstimator_v2.1/.

cd NeEstimator_v2.1


# fill in the correct population number (i.e. generation number)
sed -i -e 's/Ind/1/g' ${yearFirst}.${nInd}.genepop
sed -i -e 's/Ind/2/g' ${year1}.${nInd}.genepop
sed -i -e 's/Ind/3/g' ${year2}.${nInd}.genepop
sed -i -e 's/Ind/4/g' ${yearLast}.${nInd}.genepop


# combine last 165 lines for each file
cp ${yearFirst}.${nInd}.genepop ${yearFirst}.${year1}.${year2}.${yearLast}.${nInd}.gen
echo "Pop" >> ${yearFirst}.${year1}.${year2}.${yearLast}.${nInd}.gen
tail -165 ${year1}.${nInd}.genepop >>${yearFirst}.${year1}.${year2}.${yearLast}.${nInd}.gen
echo "Pop" >>${yearFirst}.${year1}.${year2}.${yearLast}.${nInd}.gen
tail -165 ${year2}.${nInd}.genepop >>${yearFirst}.${year1}.${year2}.${yearLast}.${nInd}.gen
echo "Pop" >>${yearFirst}.${year1}.${year2}.${yearLast}.${nInd}.gen
tail -165 ${yearLast}.${nInd}.genepop >>${yearFirst}.${year1}.${year2}.${yearLast}.${nInd}.gen


#create info file
touch info
echo "8   0   * First number n = sum of method(s) to run: LD(=1), Het(=2), Coan(=4), Temporal(=8). Second number k is for various temporals; see below" >> info
echo "${nest_dir}/NeEstimator_v2.1/ * Input Directory" >>info
echo "${yearFirst}.${year1}.${year2}.${yearLast}.${nInd}.gen * Input file name" >>info
echo "2                       * 1 = FSTAT format, 2 = GENEPOP format" >>info
echo "${nest_dir}/NeEstimator_v2.1/ * Output Directory" >>info
echo "${yearFirst}.${year1}.${year2}.${yearLast}.${nInd}Tp.txt     * Output file name (put asterisk adjacent to the name to append)" >>info
echo "3                       * Number of critical values, added 1 if a run by rejecting only singleton alleles is included" >>info
echo "0.05  0.02  0.01        * Critical values, a special value '1' is for rejecting only singleton alleles" >>info
echo "0               * 0: Random mating, 1: Monogamy (LD method)" >>info
echo "0 0 1 2 3 	* One set of generations per line. The first entry is N > 0 for plan I, 0 for plan II. Then generations follow." >>info
echo "0 		* Only 0 entered: End of generations input" >>info


# create option file
touch option
echo "8  0  10  0      * First number = sum of method(s) to have extra output: LD(=1), Het(=2), Coan(=4), Temporal(=8)" >>option
echo "0       * Maximum individuals/pop. If 0: no limit" >>option
echo "4 4     * First entry n1 = 0: No Freq output. If n1 = -1: Freq. output up to population 50. Two entries n1, n2 with n1 <= n2: Freq output for populations from n1 to n2. Max. po" >>option
echo "0       * For Burrow output file (up to 50 populations can have output). See remark below" >>option
echo "1       * Parameter CI: 1 for Yes, 0 for No" >>option
echo "1       * Jackknife CI: 1 for Yes, 0 for No" >>option
echo "0       * Up to population, or range of populations to run (if 2 entries). If first entry = 0: no restriction" >>option
echo "0       * All loci are accepted" >>option
echo "1       * Enter 1: A file is created to document missing data if there are any in input file. Enter 0: no file created" >>option
echo "0       * Line for chromosomes/loci option and file" >>option



##############################
###  run NeEstimator v2.1  ###
##############################
./Ne2-1L i:info o:option






