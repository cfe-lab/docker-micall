# dockerfile to run the MiCall pipeline within Kive

FROM centos:7

MAINTAINER wscott@cfenet.ubc.ca

#NOTE: need epel-relase for pip...
RUN yum install -y epel-release
RUN yum -y update && yum -y upgrade

RUN yum install -y rpm-build gcc-c++ libcurl-devel wget git make zlib-devel ncurses-devel openssl-devel
# 2017-10-24: seem to need python34 explicitly (i.e. rather than python3) under centos 7.3 for
# pip install to work properly. This appears to be a bug in the packages, and so this might
# change in newer versions of centos7.
RUN yum install -y python34-pip python34-devel
RUN pip3 install --upgrade pip

#We also need some python modules for the micall pipeline
RUN pip3 install python-Levenshtein matplotlib cutadapt==1.11 && \
    ln -s /usr/bin/cutadapt /usr/bin/cutadapt-1.11
#NOTE: we need to make the gotoh python module -- for this, we get the whole Micall source
#from git, but only build the gotoh python module
WORKDIR /usr/local/share
#NOTE: If we are installing under python2, then we need to pull version 7.6.
#The newer versions uses python3
# RUN git clone --branch v7.6 https://github.com/cfe-lab/MiCall.git
RUN git clone https://github.com/cfe-lab/MiCall.git
WORKDIR MiCall/micall/alignment
RUN python3 setup.py install

# ----- bowtie2, bcftools and samtools: install these from source using rpmbuild
WORKDIR /root

COPY rpmbuild rpmbuild

# bowtie2 
#NOTE: these are required if bowtie is statically linked
RUN yum install -y glibc-static libstdc++-static.x86_64 
RUN wget  https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.8/bowtie2-2.2.8-source.zip 
RUN mv bowtie2-2.2.8-source.zip  rpmbuild/SOURCES/.
RUN rpmbuild -bb rpmbuild/SPECS/bowtie-2.2.8.spec

# bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/1.3.1/bcftools-1.3.1.tar.bz2
RUN mv bcftools-1.3.1.tar.bz2 rpmbuild/SOURCES/.
RUN rpmbuild -bb rpmbuild/SPECS/bcftools-1.3.1.spec

#samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2
RUN mv samtools-1.3.1.tar.bz2 rpmbuild/SOURCES/.
RUN rpmbuild -bb rpmbuild/SPECS/samtools-1.3.1.spec

RUN rpm -Uvh rpmbuild/RPMS/*/*.rpm
RUN yum clean all && rm -rf /var/cache/yum

#All executables can be found under /usr/local/bin . Install a bash profile
# file so that this path is included in all shells
COPY kive-profile.sh  /etc/profile.d/
RUN chmod g-w /etc/profile.d/kive-profile.sh

#install a minimal test script that prints out the versions of the tools installed.
COPY hello-world.sh /root/hello-world.sh

CMD /root/hello-world.sh
