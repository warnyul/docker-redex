FROM base-image

ARG REDEX_BRANCH="stable"

# Install redex

COPY redex_${REDEX_BRANCH} /redex

WORKDIR /redex

RUN ./setup_oss_toolchain.sh

RUN apt install -q --no-install-recommends -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt -y remove python3 && \
    apt install -q --no-install-recommends -y python3.7 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2

RUN ldconfig

RUN autoreconf -ivf && \
    ./configure --enable-protobuf && \
    make && \
    make install && \
    make clean

WORKDIR /

RUN apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /redex

CMD ["redex"]