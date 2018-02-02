[![Build Status](https://travis-ci.org/webispy/docker-iotivity.svg?branch=master)](https://travis-ci.org/webispy/docker-iotivity) [![Docker Pulls](https://img.shields.io/docker/pulls/webispy/iotivity.svg)](https://hub.docker.com/r/webispy/iotivity/)

# docker-iotivity

## IoTivity

- Base commit: 1.3-rel branch, 1.3.1 tag
- Build option: SECURED=1 LOG_LEVEL=ERROR RD_MODE=CLIENT RELEASE=False TARGET_TRANSPORT=IP

## build test

```sh
$ git clone https://github.com/webispy/docker-iotivity
$ docker build docker-iotivity -t iotivity
$ docker run -it --rm -v {your-path}/docker-iotivity/sample:/src iotivity bash -c "rm -rf src/build; mkdir src/build; cd src/build; cmake ..; make"
$ cd docker-iotivity/sample/build
$ ./myclient
```

