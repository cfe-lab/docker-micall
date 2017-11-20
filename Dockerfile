FROM python:2.7.14-alpine3.6

MAINTAINER wscott@cfenet.ubc.ca

# This section installs Python 3 on top of Python 2 >>>
ENV GPG_KEY 97FC712E4C024BBEA48A61ED3A5CA953F73C700D
ENV PYTHON_VERSION 3.4.7

# add build deps before removing fetch deps in case there's overlap
RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps \
        gnupg \
        openssl \
        wget \
        tar \
        xz \
    && wget -nv -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
    && wget -nv -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && (gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
        || gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEY" \
        || gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEY") \
    && gpg --batch --verify python.tar.xz.asc python.tar.xz \
    && rm -rf "$GNUPGHOME" python.tar.xz.asc \
    && mkdir -p /usr/src/python \
    && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
    && rm python.tar.xz \
    && apk add --no-cache --virtual .build-deps  \
        bzip2-dev \
        coreutils \
        dpkg-dev dpkg \
        expat-dev \
        gcc \
        gdbm-dev \
        libc-dev \
        libffi-dev \
        linux-headers \
        make \
        ncurses-dev \
        openssl \
        openssl-dev \
        pax-utils \
        readline-dev \
        sqlite-dev \
        tcl-dev \
        tk \
        tk-dev \
        xz-dev \
        zlib-dev \
    && apk del .fetch-deps \
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
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --virtual .python-rundeps $runDeps \
    && apk del .build-deps \
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
    apk add --no-cache --virtual .fetch-deps openssl; \
    wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
    apk del .fetch-deps; \
    python3 get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        "pip==$PYTHON_PIP_VERSION" \
    ; \
    pip --version; \
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

RUN apk add --no-cache R

ENV BOWTIE2_VERSION 2.2.8

WORKDIR /root/build

# Tried binary distribution, but decided it was safer to build from source:
# https://serverfault.com/q/883625/1143
# Have to put links in /usr/local/bin and not binaries to make multiple
# versions work side by side.
RUN apk add --no-cache --virtual .fetch-deps \
        wget \
    && wget -nv https://downloads.sourceforge.net/project/bowtie-bio/bowtie2/$BOWTIE2_VERSION/bowtie2-$BOWTIE2_VERSION-source.zip \
    && apk add --no-cache --virtual .build-deps \
        g++ \
        make \
    && apk del .fetch-deps \
    && unzip bowtie2-$BOWTIE2_VERSION-source.zip \
    && cd bowtie2-$BOWTIE2_VERSION \
    && make \
    && mkdir /usr/local/bowtie2-$BOWTIE2_VERSION \
    && mv bowtie2* /usr/local/bowtie2-$BOWTIE2_VERSION \
    && cd /usr/local/bowtie2-$BOWTIE2_VERSION \
    && (for cmd in *; \
        do  ln -s `pwd`/$cmd /usr/local/bin/$cmd ; \
            ln -s `pwd`/$cmd /usr/local/bin/$cmd-$BOWTIE2_VERSION ; \
        done \
       ) \
    && apk add --no-cache --virtual .bowtie2-rundeps \
        perl \
        libstdc++ \
    && apk del .build-deps \
    && rm -r /root/build

ENV BOWTIE2_VERSION 2.2.1

WORKDIR /root/build

# Install a second version of bowtie2, with version in file names.
RUN apk add --no-cache --virtual .fetch-deps \
        wget \
    && wget -nv https://downloads.sourceforge.net/project/bowtie-bio/bowtie2/$BOWTIE2_VERSION/bowtie2-$BOWTIE2_VERSION-source.zip \
    && apk add --no-cache --virtual .build-deps \
        g++ \
        make \
    && apk del .fetch-deps \
    && unzip bowtie2-$BOWTIE2_VERSION-source.zip \
    && cd bowtie2-$BOWTIE2_VERSION \
    && make \
    && mkdir /usr/local/bowtie2-$BOWTIE2_VERSION \
    && mv bowtie2* /usr/local/bowtie2-$BOWTIE2_VERSION \
    && cd /usr/local/bowtie2-$BOWTIE2_VERSION \
    && (for cmd in *; \
        do  ln -s `pwd`/$cmd /usr/local/bin/$cmd-$BOWTIE2_VERSION ; \
        done \
       ) \
    && apk del .build-deps \
    && rm -r /root/build

ENV SAMTOOLS_VERSION 1.3.1
WORKDIR /root/build

RUN apk add --no-cache --virtual .samtools-rundeps \
        ncurses \
    && apk add --no-cache --virtual .fetch-deps \
        wget \
    && wget -nv https://github.com/samtools/bcftools/releases/download/$SAMTOOLS_VERSION/bcftools-$SAMTOOLS_VERSION.tar.bz2 \
    && wget -nv https://github.com/samtools/samtools/releases/download/$SAMTOOLS_VERSION/samtools-$SAMTOOLS_VERSION.tar.bz2 \
    && apk add --no-cache --virtual .build-deps \
        make \
        gcc \
        libc-dev \
        zlib-dev \
        ncurses-dev \
    && apk del .fetch-deps \
    && tar xjf bcftools-$SAMTOOLS_VERSION.tar.bz2 \
    && tar xjf samtools-$SAMTOOLS_VERSION.tar.bz2 \
    && cd bcftools-$SAMTOOLS_VERSION \
    && make \
    && make install \
    && cd ../samtools-$SAMTOOLS_VERSION \
    && make \
    && make install \
    && apk del .build-deps \
    && rm -r /root/build

WORKDIR /

RUN apk add --no-cache --virtual .build-deps \
        build-base \
        freetype-dev \
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
    && apk del .build-deps \
    && rm -r /root/.cache

WORKDIR /root/build

RUN apk add --no-cache --virtual .hyphy-rundeps \
        curl \
        libgomp \
    && apk add --no-cache --virtual .fetch-deps \
        wget \
    && wget -nv https://github.com/veg/hyphy/archive/2.2.5.tar.gz \
    && wget -nv https://github.com/cfe-lab/MiCall/archive/v7.6.tar.gz \
    && wget -nv https://github.com/cfe-lab/MiCall/archive/v7.7.0.tar.gz \
    && apk add --no-cache --virtual .build-deps \
        g++ \
        curl-dev \
        openssl-dev \
    && apk del .fetch-deps \
    && tar xzf 2.2.5.tar.gz \
    && tar xzf v7.6.tar.gz \
    && tar xzf v7.7.0.tar.gz \
    && cd hyphy-2.2.5/src/lib \
    && python2 setup.py install \
    && cd ../../../MiCall-7.6/micall/alignment \
    && python2 setup.py install \
    && cd ../../../MiCall-7.7.0/micall/alignment \
    && python3 setup.py install \
    && apk del .build-deps \
    && rm -r /root/build

WORKDIR /root/build

RUN apk add --no-cache --virtual .build-deps \
        R-dev \
        R-doc \
        g++ \
    && R -e 'install.packages(c("ggplot2"), repos="https://cran.cnr.berkeley.edu")' \
    && apk del .build-deps

ENV BOWTIE2_VERSION 2.2.9

WORKDIR /root/build

# Install a third version of bowtie2, with version in file names.
RUN apk add --no-cache --virtual .fetch-deps \
        wget \
    && wget -nv https://downloads.sourceforge.net/project/bowtie-bio/bowtie2/$BOWTIE2_VERSION/bowtie2-$BOWTIE2_VERSION-source.zip \
    && apk add --no-cache --virtual .build-deps \
        g++ \
        make \
    && apk del .fetch-deps \
    && unzip bowtie2-$BOWTIE2_VERSION-source.zip \
    && cd bowtie2-$BOWTIE2_VERSION \
    && make \
    && mkdir /usr/local/bowtie2-$BOWTIE2_VERSION \
    && mv bowtie2* /usr/local/bowtie2-$BOWTIE2_VERSION \
    && cd /usr/local/bowtie2-$BOWTIE2_VERSION \
    && (for cmd in *; \
        do  ln -s `pwd`/$cmd /usr/local/bin/$cmd-$BOWTIE2_VERSION ; \
        done \
       ) \
    && apk del .build-deps \
    && rm -r /root/build

WORKDIR /

# Configure pip to avoid a warning.
COPY pip.conf /root/.config/pip/

# Install a minimal script to print out version numbers.
COPY hello-world.sh /root/hello-world.sh

CMD ["/root/hello-world.sh"]
