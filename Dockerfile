#

FROM ubuntu:xenial
LABEL maintainer="webispy@gmail.com" \
      version="0.1" \
      description="IoTivity development environment"

ARG RELEASE=false
ARG LOG_LEVEL=ERROR
ARG PREFIX=/usr
ARG SECURED=1
ARG http_proxy
ARG https_proxy

ENV http_proxy=$http_proxy \
    https_proxy=$https_proxy \
    DEBIAN_FRONTEND=noninteractive \
    RELEASE=$RELEASE \
    LOG_LEVEL=$LOG_LEVEL \
    PREFIX=$PREFIX \
    SECURED=$SECURED

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

COPY static.patch /tmp
RUN git clone --depth 1 https://github.com/iotivity/iotivity -b 1.3-rel \
	&& cd iotivity \
	&& git clone --depth 1 https://github.com/01org/tinycbor.git extlibs/tinycbor/tinycbor -b v0.4.1 \
	&& git clone --depth 1 https://github.com/ARMmbed/mbedtls.git extlibs/mbedtls/mbedtls -b mbedtls-2.4.2 \
	&& git apply /tmp/static.patch \
	&& scons SECURED=${SECURED} RELEASE=${RELEASE} RD_MODE=CLIENT LOG_LEVEL=${LOG_LEVEL} TARGET_TRANSPORT=IP -j4 --prefix=${PREFIX} \
	&& scons SECURED=${SECURED} RELEASE=${RELEASE} RD_MODE=CLIENT LOG_LEVEL=${LOG_LEVEL} TARGET_TRANSPORT=IP -j4 --prefix=${PREFIX} install \
	&& cd .. \
	&& rm -rf iotivity \
	&& rm /tmp/static.patch

