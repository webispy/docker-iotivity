#!/bin/sh
set -e

if [ "$#" -ne 4 ]; then
	echo "Illegal number of parameters"
	exit 1
fi

DIST=$1
ARCH=$2
CROSS=$3
RELEASE=$4

echo "dist=$DIST"
echo "arch=$ARCH"
echo "cross=$CROSS"

echo "RELEASE=$RELEASE"

LOG_LEVEL="ERROR"
IMAGE="webispy/iotivity:$DIST"
if [ "$RELEASE" = "0" ]; then
	LOG_LEVEL="DEBUG"
	IMAGE="$IMAGE""_dev"
fi

echo "LOG_LEVEL=$LOG_LEVEL"
echo "IMAGE=$IMAGE"

sed -i 's/{dist}/'$DIST'/g' Dockerfile
sed -i 's/{arch}/'$ARCH'/g' Dockerfile
sed -i 's/{cross}/'$CROSS'/g' Dockerfile

docker build --build-arg RELEASE=$RELEASE --build-arg LOG_LEVEL=$LOG_LEVEL -t $IMAGE .
