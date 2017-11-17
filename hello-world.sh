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
bowtie2-2.2.1 --version
cutadapt --version

printf "\npip2:\n"
pip2 list

printf "\npip3:\n"
pip3 list
