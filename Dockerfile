#

FROM ubuntu:xenial
LABEL maintainer="webispy@gmail.com" \
      version="0.2" \
      description="IoTivity development environment"

ARG http_proxy
ARG https_proxy

ENV http_proxy=$http_proxy \
    https_proxy=$https_proxy \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
		ca-certificates language-pack-en \
		build-essential \
		git \
		scons \
		ssh \
		unzip \
		sudo \
		valgrind \
		doxygen \
		libtool \
		autoconf \
		pkg-config \
		libboost-all-dev \
		libsqlite3-dev \
		uuid-dev \
		libglib2.0-dev \
		libcurl4-gnutls-dev \
		libbz2-dev \
		cmake \
		chrpath \
		rpm \
		ubuntu-dev-tools \
		debhelper \
		sed \
		apt-utils \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

# Apply custom certificate
COPY certs/* /usr/local/share/ca-certificates/
RUN update-ca-certificates

ARG RELEASE=false
ARG LOG_LEVEL=ERROR
ARG SECURED=1

# Use PREFIX to /out instead of /usr to remove RPATH
ENV RELEASE=$RELEASE \
    LOG_LEVEL=$LOG_LEVEL \
    SECURED=$SECURED \
    PREFIX=/out

COPY patch/* /tmp/

# - clone iotivity and related sources
# - apply custom patch (patch/*)
# - remove RPATH from executable and shared library
# - install to /usr
# - modify iotivity.pc (replace prefix)
RUN git clone --depth 1 https://github.com/iotivity/iotivity -b 1.3.1 \
	&& cd iotivity \
	&& git clone --depth 1 https://github.com/01org/tinycbor.git extlibs/tinycbor/tinycbor -b v0.4.1 \
	&& git clone --depth 1 https://github.com/ARMmbed/mbedtls.git extlibs/mbedtls/mbedtls -b mbedtls-2.4.2 \
	&& git apply /tmp/00*.patch \
	&& rm /tmp/00*.patch \
	&& scons --silent SECURED=${SECURED} RELEASE=${RELEASE} RD_MODE=CLIENT LOG_LEVEL=${LOG_LEVEL} TARGET_TRANSPORT=IP -j8 --prefix=${PREFIX}

RUN cd iotivity \
	&& scons SECURED=${SECURED} RELEASE=${RELEASE} RD_MODE=CLIENT LOG_LEVEL=${LOG_LEVEL} TARGET_TRANSPORT=IP -j8 --prefix=${PREFIX} install \
	&& cd /out \
	&& find . -type f -executable -exec chrpath -d "{}" \; \
	&& find . -type f -iname "lib*.so" -exec chrpath -d "{}" \; \
	&& mv bin/* /usr/bin/ \
	&& mv lib/pkgconfig/* /usr/lib/pkgconfig/ \
	&& rmdir lib/pkgconfig \
	&& mv lib/* /usr/lib/ \
	&& mv include/* /usr/include/ \
	&& sed -i 's/prefix=\/out/prefix=\/usr/g' /usr/lib/pkgconfig/iotivity.pc \
	&& cd .. \
	&& rm -rf /out \
	&& rm -rf /iotivity \

