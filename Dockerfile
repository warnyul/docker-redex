FROM warnyul/android-build-tools:29.0.3

LABEL maintainer="Balázs Varga <warnyul@gmail.com>"
LABEL description="Facebook's Android Bytecode Optimizer"

# Install redex

COPY redex /redex

RUN apt-get -y update && \
    apt-get -y install software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get -y install \
    g++ \
    automake \
    autoconf \
    autoconf-archive \
    libtool \
    liblz4-dev \
    liblzma-dev \
    make \
    zlib1g-dev \
    binutils-dev \
    libjemalloc-dev \
    libiberty-dev \
    libjsoncpp-dev \
    python3.6 \
    bzip2 \ 
    wget && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2 && \
    /redex/get_boost.sh && \
    apt-get -y remove bzip2 wget && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH /usr/local/lib
ENV CXX g++-5
ENV TRACE 0
ENV BOOST_DEBUG 0

WORKDIR /redex

RUN autoreconf -ivf && \
    ./configure CXX='g++-5' && \
    make -j4 && \
    make install && \
    make clean && \
    rm -rf boost_1_71_0.tar.bz2 && \
    rm -rf redex.tar.gz

CMD ["redex"]
