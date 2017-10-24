#!/bin/bash

printf "This is the docker-micall 'hello-world.sh' script\n\n"

printf "python version:\n"
python3 -V

printf "\nsamtools version:\n"
samtools --version

printf "\nbcftools version:\n"
bcftools --version

printf "\nbowtie2 version\n"
bowtie2-2.2.8 --version
