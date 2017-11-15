#!/bin/sh

printf "This is the kive-default 'hello-world.sh' script.\n\n"

printf "Default Python version:\n"
python -V

printf "Python 3 version:\n"
python3 -V

printf "\nsamtools version:\n"
samtools --version

printf "\nbcftools version:\n"
bcftools --version

printf "\nbowtie2 version\n"
bowtie2 --version
