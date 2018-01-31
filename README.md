[![Docker Pulls](https://img.shields.io/docker/pulls/webispy/iotivity.svg)](https://hub.docker.com/r/webispy/iotivity/)

# docker-iotivity

## build test

```sh
$ git clone https://github.com/webispy/docker-iotivity
$ docker build docker-iotivity -t iotivity
$ docker run -it --rm -v docker-iotivity/sample:/src iotivity bash -c "rm -rf src/build; mkdir src/build; cd src/build; cmake ..; make"
$ cd docker-iotivity/sample/build
$ ./myclient
```

