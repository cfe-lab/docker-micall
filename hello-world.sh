#!/bin/sh

printf "This is the kive-default 'hello-world.sh' script.\n\n"

printf "Default Python version:\n"
python -V

printf "Python 3 version:\n"
python3 -V

printf "\nOther tools:\n"
samtools --version
bcftools --version
bowtie2 --version
cutadapt --version
