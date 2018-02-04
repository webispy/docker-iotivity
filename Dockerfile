FROM webispy/iotivity:base as builder
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

FROM ubuntu:xenial
LABEL maintainer="webispy@gmail.com" \
      version="0.2" \
      description="IoTivity development environment"
RUN apt-get update && apt-get install -y --no-install-recommends \
		build-essential \
		git \
		pkg-config \
		cmake \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*
COPY --from=builder /out /usr
