FROM base-image

ARG REDEX_BRANCH=stable
ARG RUN_TESTS=false

# Install redex

COPY redex_${REDEX_BRANCH} /redex

WORKDIR /redex

RUN ./setup_oss_toolchain.sh && \
    apt-get install -q --no-install-recommends -y curl

RUN ldconfig

RUN autoreconf -ivf && \
    ./configure --enable-protobuf && \
    make && \
    make install
    
RUN [ "${RUN_TESTS}" = "true" ] && make check

RUN make clean

WORKDIR /

RUN apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /redex

CMD ["redex"]