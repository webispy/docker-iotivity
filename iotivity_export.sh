#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
	echo "Illegal number of parameters"
	exit 1
fi

echo "Export iotivity files to $1 ..."
rsync --files-from=/usr/share/iotivity.list / $1
echo "Done."
