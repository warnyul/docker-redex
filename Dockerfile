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
    make clean && \
    rm -rf boost_1_71_0.tar.bz2 && \
    rm -rf redex.tar.gz

RUN ls -al >&2

RUN which redex >&2

CMD ["redex"]
