[![Build Status](https://travis-ci.org/webispy/docker-iotivity.svg?branch=master)](https://travis-ci.org/webispy/docker-iotivity) [![Docker Pulls](https://img.shields.io/docker/pulls/webispy/iotivity.svg)](https://hub.docker.com/r/webispy/iotivity/)

# docker-iotivity

- Based IoTivity 1.3.1
- IoTivity stack was built with the SECURED=1 option.
- Includes tools to conver JSON to CBOR. (json2cbor, svrdbeditor)
- Support build with IoTivity static library. (Custom patch has been applied.)

# Build test

```sh
# Get sample code
$ docker clone https://github.com/webispy/docker-iotivity

# Build
$ docker run -t --rm -v {your-path}/docker-iotivity/sample:/src webispy/iotivity \
		bash -c "rm -rf src/build; mkdir src/build; cd src/build; cmake ..; make"

# Run the sample program(static build)
$ cd docker-iotivity/sample/build
$ ./myclient_static
```

