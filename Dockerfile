FROM python:2.7.14-alpine3.4

MAINTAINER wscott@cfenet.ubc.ca

# This section installs Python 3 on top of Python 2 >>>
ENV GPG_KEY 97FC712E4C024BBEA48A61ED3A5CA953F73C700D
ENV PYTHON_VERSION 3.4.7

RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps \
        gnupg \
        openssl \
        wget \
        tar \
        xz \
    #
    && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
    && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && (gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
        || gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEY" \
        || gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEY") \
    && gpg --batch --verify python.tar.xz.asc python.tar.xz \
    && rm -rf "$GNUPGHOME" python.tar.xz.asc \
    && mkdir -p /usr/src/python \
    && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
    && rm python.tar.xz \
    #
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
    # add build deps before removing fetch deps in case there's overlap
    && apk del .fetch-deps \
    #
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
    #
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --virtual .python-rundeps $runDeps \
    && apk del .build-deps \
    #
    && find /usr/local -depth \
        \( \
            \( -type d -a \( -name test -o -name tests \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' + \
    && rm -rf /usr/src/python

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 9.0.1

# TODO: change this python to python3, and copy /usr/local/bin/pip2 over /usr/local/bin/pip
RUN set -ex; \
    #
    apk add --no-cache --virtual .fetch-deps openssl; \
    #
    wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
    #
    apk del .fetch-deps; \
    #
    python get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        "pip==$PYTHON_PIP_VERSION" \
    ; \
    pip --version; \
    #
    find /usr/local -depth \
        \( \
            \( -type d -a \( -name test -o -name tests \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' +; \
    rm -f get-pip.py

# <<< End of Python 3

ENV BOWTIE2_VERSION 2.2.8

WORKDIR /root/build

# Tried binary distribution, but it didn't work:
# https://serverfault.com/q/883625/1143
RUN apk add --no-cache --virtual .fetch-deps \
        openssl \
        wget \
        ca-certificates \
    && wget -nv https://downloads.sourceforge.net/project/bowtie-bio/bowtie2/$BOWTIE2_VERSION/bowtie2-$BOWTIE2_VERSION-source.zip \
    && apk add --no-cache --virtual .build-deps \
        g++ \
        make \
    && apk del .fetch-deps \
    && unzip bowtie2-$BOWTIE2_VERSION-source.zip \
    && cd bowtie2-$BOWTIE2_VERSION \
    && make \
    && mv bowtie2* /usr/local/bin \
    && (for cmd in /usr/local/bin/bowtie2*; \
        do ln -s $cmd $cmd-$BOWTIE2_VERSION ; \
        done \
       ) \
    && apk add --no-cache --virtual .bowtie2-rundeps \
        perl \
        libstdc++ \
    && apk del .build-deps \
    && rm -r /root/build

ENV SAMTOOLS_VERSION 1.3.1
WORKDIR /root/build

RUN apk add --no-cache --virtual .samtools-rundeps \
        ncurses==6.0_p20170701-r0 \
    && apk add --no-cache --virtual .fetch-deps \
        wget==1.18-r1 \
        ca-certificates==20161130-r0 \
    && wget -nv https://github.com/samtools/bcftools/releases/download/$SAMTOOLS_VERSION/bcftools-$SAMTOOLS_VERSION.tar.bz2 \
    && wget -nv https://github.com/samtools/samtools/releases/download/$SAMTOOLS_VERSION/samtools-$SAMTOOLS_VERSION.tar.bz2 \
    && apk add --no-cache --virtual .build-deps \
        make==4.1-r1 \
        gcc==5.3.0-r0 \
        libc-dev==0.7-r0 \
        zlib-dev==1.2.11-r0 \
        ncurses-dev==6.0_p20170701-r0 \
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

# TODO: Remove this RUN command, and switch the python to python3 on previous TODO.
RUN set -ex; \
    #
    apk add --no-cache --virtual .fetch-deps openssl; \
    #
    wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
    #
    apk del .fetch-deps; \
    #
    python3 get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        "pip==$PYTHON_PIP_VERSION" \
    ; \
    pip --version; \
    #
    find /usr/local -depth \
        \( \
            \( -type d -a \( -name test -o -name tests \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' +; \
    rm -f get-pip.py

RUN apk add --no-cache --virtual .build-deps \
        build-base==0.4-r1 \
        freetype-dev==2.6.3-r1 \
    && pip3 install \
        cutadapt==1.11 \
        matplotlib==2.0.2 \
        numpy==1.13.0 \
        python-Levenshtein==0.12.0 \
    && pip2 install \
        matplotlib==2.0.2 \
        numpy==1.13.0 \
        python-Levenshtein==0.12.0 \
    && apk del .build-deps

# Configure pip to avoid a warning.
COPY pip.conf /root/.config/pip/
# Set the default pip back to pip2
RUN cp /usr/local/bin/pip2 /usr/local/bin/pip

# Install a minimal script to print out version numbers.
COPY hello-world.sh /root/hello-world.sh

CMD ["/root/hello-world.sh"]
