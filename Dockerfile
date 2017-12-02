FROM python:2.7.14-slim

MAINTAINER wscott@cfenet.ubc.ca

# This section installs Python 3 on top of Python 2 >>>
# runtime dependencies not included with Python 2.7
RUN apt-get update && apt-get install -y --no-install-recommends \
		libexpat1 \
		libffi6 \
	&& rm -rf /var/lib/apt/lists/*

ENV GPG_KEY 97FC712E4C024BBEA48A61ED3A5CA953F73C700D
ENV PYTHON_VERSION 3.4.7

RUN set -ex \
	&& buildDeps=" \
		dpkg-dev \
		gcc \
		libbz2-dev \
		libc6-dev \
		libexpat1-dev \
		libffi-dev \
		libgdbm-dev \
		liblzma-dev \
		libncursesw5-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		make \
		tcl-dev \
		tk-dev \
		wget \
		xz-utils \
		zlib1g-dev \
# as of Stretch, "gpg" is no longer included by default
		$(command -v gpg > /dev/null || echo 'gnupg dirmngr') \
	" \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& wget -nv -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -nv -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
	&& make install \
	&& ldconfig \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' + \
	&& rm -rf /usr/src/python

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 9.0.1

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends wget; \
	rm -rf /var/lib/apt/lists/*; \
	wget -nv -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
	apt-get purge -y --auto-remove wget; \
	python3 get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip3 --version; \
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py; \
    cp /usr/local/bin/pip2 /usr/local/bin/pip
    # Sets the default pip back to pip2.

# <<< End of Python 3

RUN apt-get update && apt-get install -y --no-install-recommends \
		r-base \
		r-cran-ggplot2 \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /root/build

# Install three versions of bowtie2, last one is the default.
# Have to put links in /usr/local/bin and not binaries to make multiple
# versions work side by side.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends wget perl \
	&& rm -rf /var/lib/apt/lists/* \
	&& wget -nv \
	    https://downloads.sourceforge.net/project/bowtie-bio/bowtie2/2.2.1/bowtie2-2.2.1-linux-x86_64.zip \
	    https://downloads.sourceforge.net/project/bowtie-bio/bowtie2/2.2.9/bowtie2-2.2.9-linux-x86_64.zip \
	    https://downloads.sourceforge.net/project/bowtie-bio/bowtie2/2.2.8/bowtie2-2.2.8-linux-x86_64.zip \
	&& apt-get purge -y --auto-remove wget \
    && (for btver in 2.2.1 2.2.9 2.2.8; \
        do  unzip bowtie2-$btver-linux-x86_64.zip \
            && rm bowtie2-$btver-linux-x86_64.zip \
            && mkdir /usr/local/bowtie2-$btver \
            && cd bowtie2-$btver \
            && (for cmd in bowtie2*; \
                do  mv $cmd /usr/local/bowtie2-$btver \
                    && ln -s /usr/local/bowtie2-$btver/$cmd /usr/local/bin/$cmd-$btver \
                    && ln -sf /usr/local/bowtie2-$btver/$cmd /usr/local/bin/$cmd ; \
                done \
                ) \
            && cd .. \
            && rm -r bowtie2-$btver ; \
        done \
        )

ENV SAMTOOLS_VERSION 1.3.1
WORKDIR /root/build

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	    ncurses-base \
	    wget \
	    zlib1g-dev \
	    bzip2 \
	    make \
	    gcc \
	    libncurses5-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& wget -nv \
	    https://github.com/samtools/bcftools/releases/download/$SAMTOOLS_VERSION/bcftools-$SAMTOOLS_VERSION.tar.bz2 \
	    https://github.com/samtools/samtools/releases/download/$SAMTOOLS_VERSION/samtools-$SAMTOOLS_VERSION.tar.bz2 \
	&& apt-get purge -y --auto-remove wget \
    && tar xjf bcftools-$SAMTOOLS_VERSION.tar.bz2 \
    && tar xjf samtools-$SAMTOOLS_VERSION.tar.bz2 \
    && cd bcftools-$SAMTOOLS_VERSION \
    && make \
    && make install \
    && cd ../samtools-$SAMTOOLS_VERSION \
    && make \
    && make install \
    && apt-get purge -y --auto-remove \
        zlib1g-dev \
        bzip2 \
        make \
        gcc \
        libncurses5-dev \
    && rm -r /root/build

WORKDIR /

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	    build-essential \
	&& rm -rf /var/lib/apt/lists/* \
    && pip3 install \
        cutadapt==1.11 \
        matplotlib==2.0.2 \
        numpy==1.13.0 \
        python-Levenshtein==0.12.0 \
    && ln -s /usr/local/bin/cutadapt /usr/local/bin/cutadapt-1.11 \
    && pip2 install \
        matplotlib==2.0.2 \
        numpy==1.13.0 \
        python-Levenshtein==0.12.0 \
    && rm -r /root/.cache \
	&& apt-get purge -y --auto-remove build-essential


WORKDIR /root/build

# Hyphy & Gotoh
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	    curl \
	    wget \
	    g++ \
	    libcurl4-openssl-dev \
	    libssh-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& wget -nv \
	    https://github.com/veg/hyphy/archive/2.2.5.tar.gz \
        https://github.com/cfe-lab/MiCall/archive/v7.6.tar.gz \
        https://github.com/cfe-lab/MiCall/archive/v7.7.0.tar.gz \
	&& apt-get purge -y --auto-remove wget \
    && tar xzf 2.2.5.tar.gz \
    && tar xzf v7.6.tar.gz \
    && tar xzf v7.7.0.tar.gz \
    && cd hyphy-2.2.5/src/lib \
    && python2 setup.py install \
    && cd ../../../MiCall-7.6/micall/alignment \
    && python2 setup.py install \
    && cd ../../../MiCall-7.7.0/micall/alignment \
    && python3 setup.py install \
	&& apt-get purge -y --auto-remove \
	    g++ \
	    libcurl4-openssl-dev \
	    libssh-dev \
    && rm -r /root/build

WORKDIR /

# Configure pip to avoid a warning.
COPY pip.conf /root/.config/pip/

# Install a minimal script to print out version numbers.
COPY hello-world.sh /root/hello-world.sh

CMD ["/root/hello-world.sh"]
