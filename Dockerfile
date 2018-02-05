# Temporary image for IoTivity build
FROM multiarch/crossbuild as builder

ARG RELEASE=false
ARG LOG_LEVEL=ERROR
ARG SECURED=1

# Use PREFIX to /out instead of /usr to remove RPATH
ENV CROSS_TRIPLE={cross} \
    RELEASE=$RELEASE \
    LOG_LEVEL=$LOG_LEVEL \
    SECURED=$SECURED \
    PREFIX=/out \
    DEBIAN_FRONTEND=noninteractive

ENV SCONS_OPTS="TARGET_ARCH={arch} TC_PREFIX={cross}- SECURED=${SECURED} RELEASE=${RELEASE} RD_MODE=CLIENT LOG_LEVEL=${LOG_LEVEL} TARGET_TRANSPARENT=IP -j4 --prefix=${PREFIX}" \
    PKG_CONFIG_PATH=/usr/lib/{cross}/pkgconfig

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		build-essential \
		git \
		scons \
		ssh \
		unzip \
		doxygen \
		libtool \
		autoconf \
		pkg-config \
		libsqlite3-dev:{dist} \
		uuid-dev:{dist} \
		libglib2.0-dev:{dist} \
		libcurl4-gnutls-dev:{dist} \
		libbz2-dev:{dist} \
		cmake \
		chrpath \
		sed \
		apt-utils \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

COPY patch/* /tmp/

# - clone iotivity and related sources
# - apply custom patch (patch/*)
# - fix to use PKG_CONFIG_PATH
# - remove --coverage flags
# - remove RPATH from executable and shared library
# - modify iotivity.pc (replace prefix)
RUN git clone --depth 1 http://github.com/iotivity/iotivity -b 1.3.1 \
	&& cd iotivity \
	&& git clone --depth 1 http://github.com/01org/tinycbor.git extlibs/tinycbor/tinycbor -b v0.4.1 \
	&& git clone --depth 1 http://github.com/ARMmbed/mbedtls.git extlibs/mbedtls/mbedtls -b mbedtls-2.4.2 \
	&& git apply /tmp/00*.patch \
	&& rm /tmp/00*.patch \
	&& echo $PKG_CONFIG_PATH \
	&& echo $SCONS_OPTS \
	&& sed -i "378i\env['ENV']['PKG_CONFIG_PATH'] = os.environ.get('PKG_CONFIG_PATH')" build_common/SConscript \
	&& sed -i "23,26d" build_common/linux/SConscript \
	&& scons $SCONS_OPTS \
	&& echo "Build done." \
	&& scons install $SCONS_OPTS \
	&& echo "Install done." \
	&& ls -al / \
	&& find /out -type f -executable -exec chrpath -d "{}" \; \
	&& find /out -type f -iname "lib*.so" -exec chrpath -d "{}" \; \
	&& sed -i 's/prefix=\/out/prefix=\/usr/g' /out/lib/pkgconfig/iotivity.pc \
	&& find /out/* | tee /iotivity.list \
	&& sed -i 's/\/out/\/usr/g' /iotivity.list \
	&& rm -rf /iotivity

# Release image
# - included git, pkg-config and cmake for convenience
FROM multiarch/ubuntu-core:{dist}-xenial
LABEL maintainer="webispy@gmail.com" \
      version="0.5" \
      description="IoTivity development environment"
RUN apt-get update && apt-get install -y --no-install-recommends \
		build-essential \
		git \
		pkg-config \
		cmake \
		rsync \
		libglib2.0-dev \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*
COPY --from=builder /out /usr
COPY --from=builder /iotivity.list /usr/share/
COPY iotivity_export.sh /usr/bin/
