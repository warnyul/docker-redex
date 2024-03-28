FROM base-image

ARG REDEX_BRANCH="stable"

# Install redex

COPY redex_${REDEX_BRANCH} /redex

WORKDIR /redex

RUN ./setup_oss_toolchain.sh

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
