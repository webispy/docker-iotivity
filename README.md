[![Build Status](https://travis-ci.org/webispy/docker-iotivity.svg?branch=master)](https://travis-ci.org/webispy/docker-iotivity) [![Docker Pulls](https://img.shields.io/docker/pulls/webispy/iotivity.svg)](https://hub.docker.com/r/webispy/iotivity/)

# docker-iotivity

- Based on IoTivity 1.3.1
- IoTivity stack was built with the SECURED=1 option.
- Includes tools to conver JSON to CBOR. (json2cbor, svrdbeditor)
- Support build with IoTivity static and shared library. (Custom patch has been applied.)
- Support only C library. (No more fucking IoTivity C++ API and boost library)
- Support amd64(x86_64), armhf and arm64

# Docker images

```sh
# IoTivity stack built with RELEASE=1 LOG_LEVEL=ERROR
$ docker pull webispy/iotivity:amd64
$ docker pull webispy/iotivity:armhf
$ docker pull webispy/iotivity:arm64

# IoTivity stack built with RELEASE=0 LOG_LEVEL=DEBUG
$ docker pull webispy/iotivity:amd64_dev
$ docker pull webispy/iotivity:armhf_dev
$ docker pull webispy/iotivity:arm64_dev
```

All images are based on [multiarch/ubuntu-core](https://hub.docker.com/r/multiarch/ubuntu-core/) xenial.

# Sample code build test

```sh
# Get sample code
$ docker clone https://github.com/webispy/docker-iotivity

# Build
$ docker run -t --rm -v ~/docker-iotivity/sample:/src webispy/iotivity:amd64 \
		bash -c "rm -rf src/build; mkdir src/build; cd src/build; cmake ..; make"

# Run the sample program(static build)
$ cd docker-iotivity/sample/build
$ ./myclient_static
```

# Export IoTivity development files

```sh
# Export iotivity header/library to ~/my_usr directory.
$ docker run -t --rm -v ~/my_usr:/target webispy/iotivity:amd64 iotivity_export.sh /target
$ find ~/my_usr
my_usr/usr/bin/json2cbor
my_usr/usr/bin/svrdbeditor
my_usr/usr/include/...
my_usr/usr/lib/pkgconfig/iotivity.pc
my_usr/usr/lib/...
```

# License

[The MIT License](http://opensource.org/licenses/MIT)

Copyright (c) 2018 Inho Oh <webispy@gmail.com>
