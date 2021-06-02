#!/usr/bin/env bash

'''

'''

## variables & default vales##

# the file containing 3UTR sequences
# with wild type allele (one seq per line)
WILD='' 
# the file containing 3UTR sequences 
# with mutant allele (one seq per line)
MUT=''  
# the interval file (seqname \t start \t end) 
# contains position of a target site within 
# each sequence
INT=''

while getopts ':w:m:i:h' opt; do
    case $opt in
        (w) WILD=$OPTARG;;
        (m) MUT=$OPTARG;;
        (i) INT=$OPTARG;;
        (h) usage;;
        (:) case $OPTARG in
                (w) echo "Please specify a file containing wildtype sequences" && exit 1;;
                (m) echo "Please specify a file containing mutant sequences" && exit 1;;
                (i) echo "Please specify a file containing intervals" && exit 1;;
            esac;;
    esac
done

## check if files passed to script exist
[[ -e $WILD ]] || { echo "Wildtype sequence file (${WILD}) doesnot exist" && exit 1;  }
[[ -e $MUT ]] || { echo "Mutant sequence file (${MUT}) doesnot exist" && exit 1;  }
[[ -e $INT ]] || { echo "interval file (${INT}) doesnot exist" && exit 1;  }

## check files compatibility
[[ $(cat "$WILD" | wc -l) -eq $(cat "$MUT" | wc -l) ]] || { echo "equal number of wildtype & mutant sequences is expected" && exit 1; }
[[ $(cat "$WILD" | wc -l) -eq $(cat "$INT" | wc -l) ]] || { echo "interval file should contain a row for each wildtype/mutant sequence" && exit 1; }

## number of iterations is equal for wildtype and mutant sequences ##
num_seqs=$(cat $WILD | wc -l)

# looping through sequences and running RNAplfold
for x in $(seq 1 1 $num_seqs); do

    awk -v lineNum=$x '{if (NR == lineNum) {print $0}}' "$WILD" | \    # select 1 wildtype sequence
        RNAplfold -u 21 -W 80 -L 40 | \                                # run RNAplfold with default params
        tail -n +3 - > wt.tmp                                          # remove the top 2 lines

    awk -v lineNum=$x '{if (NR == lineNum) {print $0}}' "$MUT" | \
        RNAplfold -u 21 -W 80 -L 40 | \
        tail -n +3 - > mt.tmp
    rm -f *.tmp
done