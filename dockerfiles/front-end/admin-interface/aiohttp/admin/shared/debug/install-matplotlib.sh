#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
. ${DIR}/common.sh

## #################################################################
## global env variables
## #################################################################

MATPLOTLIB_APK_BUILD=${MATPLOTLIB_APK_BUILD:-"musl-dev linux-headers gfortran g++ jpeg-dev zlib-dev cairo-dev"}

apk add --no-cache --no-progress --virtual matplotlib.deps ${MATPLOTLIB_APK_BUILD}

pip install --no-cache --no-cache-dir -r /shared/conf.d/pip/requirements.plot.txt
# apk add py-matplotlib 				# better install with pip
# apk add --update py-numpy@community 	# better install with pip

apk del --no-cache matplotlib.deps