#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
cd /scripts
if [ -f ${DIR}/common.sh ]; then
	. ${DIR}/common.sh
fi

if [ -f ${DIR}/aliases.sh ]; then
	. ${DIR}/aliases.sh
fi

## #################################################################
## global env variables
## #################################################################

# ref. https://github.com/docker-library/python/blob/master/3.6/alpine3.6/Dockerfile#L105-L126

cd /tmp
wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'
python get-pip.py --disable-pip-version-check --no-cache-dir "pip==$PYTHON_PIP_VERSION"
pip --version
find /usr/local -depth \
	\( \
		\( -type d -a \( -name test -o -name tests \) \) \
		-o \
		\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
	\) -exec rm -rf '{}' +; 
rm -f get-pip.py

# ref.
#  - https://github.com/frol/docker-alpine-python3/blob/master/Dockerfile 
pip install --upgrade pip setuptools

# if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi