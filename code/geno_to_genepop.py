#!/usr/bin/env python

import sys

F1 = sys.argv[1]
out = F1.split('.')[0]

with open(F1) as File1, open(out + '.genepoptemp', 'w') as File2:
	Loci = ''
	Geno = []
	for line in File1:
        	Lines = line.strip().split()
		Contig = Lines[0]
		Pos = Lines[1]
		Geno.append(Lines[4:])
		Loci = Loci + Contig + '_' + Pos + '\t'
	Geno_t = zip(*Geno)		
	File2.write(Loci + '\n')
	for i in Geno_t:
		Rows = ''
		for x in i:
			Rows = Rows + x + '\t' 	
		M = Rows + '\n'
		Alleles = M.replace('-1', 'mis').replace('0', 'maj').replace('1', 'het').replace('2', 'min')
		Genepop = Alleles.replace('mis', '0000').replace('maj', '0101').replace('het', '0102').replace('min', '0202')
		File2.write(Genepop)
