#

FROM ubuntu:xenial
LABEL maintainer="webispy@gmail.com" \
      version="0.2" \
      description="IoTivity development environment"

ENV DEBIAN_FRONTEND=noninteractive

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

