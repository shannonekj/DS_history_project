#!/usr/bin/env python

import os
import sys

Input = sys.argv[1]
Output = sys.argv[2]

File1 = open(Input, 'r').readlines()
File2 = open(Output, "w")
#File2.write(File1.readline())

for line in File1:
	if not line.startswith(">"):
		File2.write(line[108:] + '\n')

	if line.startswith(">"):
		File2.write(line[0:8] + '\n')

#	if line.startswith("R"):
#		File2.write('>' + line[0:7] + '\n')
#	else:
#		File2.write(line + '\n')
#File1.close()
File2.close()
