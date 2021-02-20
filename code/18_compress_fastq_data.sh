#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J cmpssALL
#SBATCH -e 18_compress_fastq_data.%j.err
#SBATCH -o 18_compress_fastq_data.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00

set -e # exits upon failing command
set -v # verbose -- all lines
set -x # trace of all commands after expansion before execution


# set up directories
data_dir="/home/sejoslin/projects/DS_history/data"

cd $data_dir

#######################
### Set Up Barcodes ###
#######################

for i in BMAG0*
do
if [[ $i == "BMAG044" ]]
then
  barcode="TTAGGC,TGACCA,ACAGTG,GCCAAT"
  elif [[ $i == "BMAG045" ]]
  then
    barcode="CAGATC,ACTTGA,GATCAG,TAGCTT"
    elif [[ $i == "BMAG046" ]]
    then
      barcode="GGCTAC,CTTGTA,AGTCAA,AGTTCC"
      elif [[ $i == "BMAG047" ]]
      then
        barcode="ATGTCA,CCGTCC,GTCCGC,GTGAAA"
        elif [[ $i == "BMAG048" ]]
        then
          barcode="GTGGCC,CGTACG,ATTCCT,ACTGAT"
          elif [[ $i == "BMAG049" ]]
          then
            barcode="GTTTCG"
            elif [[ $i == "BMAG055" ]]
	    then
		barcode="CCGTCC,CTTGTA,GGCTAC,GTGAAA"
		else
		echo $i " does not match given datasets!"
              fi
cd $i

	#####################
	### Compress main ###
	###     fastq     ###
	#####################

	for k in *.fastq
	do
		echo Compressing $i $(date)
		lzma $k
		echo Compression complete at $(date).
	done

	######################
	### Compress Split ###
	###     fastq      ###
	######################

	wc=$(wc -l indexid.list | awk '{print $1}') # number of lines
	x=1
	while [ $x -le $wc ]
	do
		string="sed -n ${x}p indexid.list"
		str=$($string)
		var=$(echo $str | awk -Ft '{print $1}')
		set -- $var
		c1=$1
		
		cd $c1
		echo Compressing all ${c1} fastq files in $i on $(date)
		lzma *.fastq
		echo Compression complete at $(date)
		cd ../
		x=$(( $x + 1 ))
	done
cd ${data_dir}
done


