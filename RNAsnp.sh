#!/usr/bin/env bash

#
# This scripts runs RNAsnp program on a set of 3'UTR:snp pairs
#
# inputs: 
#        -f | --utrs: a file containing one 3'UTR seq per line. Should have exact number of lines as -s file.
#        -s | snps: a file containing one snp per line. e.g. A43G in line 1, represents information of the polymorphism
#             related to UTR seq in line 1 of utrs file. Positions are relative to UTR seq.
#
# output: a text file containing the results of RNAsnp for each pair of 3'UTR:snp. 
#         e.g. line 1 of the output file represents the effect of snp on line 1 of snps 
#         file on 3'UTR sequence in line 1 of the utrs file.
#