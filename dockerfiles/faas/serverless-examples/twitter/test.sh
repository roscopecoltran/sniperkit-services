#!/bin/bash
set -x

./build.sh

PAYLOAD='{"username": "zengqingguo"}'

# test it
echo $PAYLOAD | docker run --rm -i hub.faas.pro/func-twitter