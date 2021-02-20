#!/bin/bash -l

F1=$1
n=$(wc -l $F1 | awk '{print $1}')

x=1
while [ $x -le $n ] 
do

                string="sed -n ${x}p $F1"
                str=$($string)

                var=$(echo $str | awk '{print $1}')
                set -- $var
                c1=$1   ### Loci name goes here ###
   
	sed 's/contig/'${c1}'/g' ${c1}_contig.cycle1.fasta > ${c1}_contig_a.fasta
	tr -d '\n' < ${c1}_contig_a.fasta >  ${c1}_contig_b.fasta
	tr ')' '\n' < ${c1}_contig_b.fasta > ${c1}_contig_c.fasta
	getLoci.py ${c1}_contig_c.fasta ${c1}_contig.fasta

        	x=$(( $x + 1 ))

done
