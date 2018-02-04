# Temporary image for IoTivity build
FROM ubuntu:xenial as builder
ARG RELEASE=false
ARG LOG_LEVEL=ERROR
ARG SECURED=1

# Use PREFIX to /out instead of /usr to remove RPATH
ENV RELEASE=$RELEASE \
    LOG_LEVEL=$LOG_LEVEL \
    SECURED=$SECURED \
    PREFIX=/out \
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

COPY patch/* /tmp/

# - clone iotivity and related sources
# - apply custom patch (patch/*)
# - remove RPATH from executable and shared library
# - modify iotivity.pc (replace prefix)
RUN git clone --depth 1 http://github.com/iotivity/iotivity -b 1.3.1 \
	&& cd iotivity \
	&& git clone --depth 1 http://github.com/01org/tinycbor.git extlibs/tinycbor/tinycbor -b v0.4.1 \
	&& git clone --depth 1 http://github.com/ARMmbed/mbedtls.git extlibs/mbedtls/mbedtls -b mbedtls-2.4.2 \
	&& git apply /tmp/00*.patch \
	&& rm /tmp/00*.patch \
	&& scons --silent SECURED=${SECURED} RELEASE=${RELEASE} RD_MODE=CLIENT LOG_LEVEL=${LOG_LEVEL} TARGET_TRANSPORT=IP -j8 --prefix=${PREFIX} \
	&& scons SECURED=${SECURED} RELEASE=${RELEASE} RD_MODE=CLIENT LOG_LEVEL=${LOG_LEVEL} TARGET_TRANSPORT=IP -j8 --prefix=${PREFIX} install \
	&& find /out -type f -executable -exec chrpath -d "{}" \; \
	&& find /out -type f -iname "lib*.so" -exec chrpath -d "{}" \; \
	&& sed -i 's/prefix=\/out/prefix=\/usr/g' /out/lib/pkgconfig/iotivity.pc \
	&& rm -rf /iotivity

# Release image
# - included git, pkg-config and cmake for convenience
FROM ubuntu:xenial
LABEL maintainer="webispy@gmail.com" \
      version="0.3" \
      description="IoTivity development environment"
RUN apt-get update && apt-get install -y --no-install-recommends \
		build-essential \
		git \
		pkg-config \
		cmake \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*
COPY --from=builder /out /usr
