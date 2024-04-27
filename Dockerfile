FROM base-image

ARG REDEX_BRANCH=stable
ARG RUN_TESTS=false

# Install redex

COPY redex_${REDEX_BRANCH} /redex
COPY runTests.sh /redex

WORKDIR /redex

RUN ./setup_oss_toolchain.sh && \
    apt-get install -q --no-install-recommends -y curl && \
    ldconfig

RUN autoreconf -ivf && \
    ./configure --enable-protobuf && \
    make && \
    make install && \
    ./runTests.sh "${RUN_TESTS}" && \
    make clean

WORKDIR /

RUN apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /redex

CMD ["redex"]