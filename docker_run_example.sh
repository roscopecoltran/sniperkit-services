#!/bin/bash

SCRIPT_DIR=$(cd $(dirname ${0});pwd)
REPOSITORY_DIR=${SCRIPT_DIR}/example
REPOSITORY_DIRNAME=$(basename $REPOSITORY_DIR)

docker run -it \
  --volume $REPOSITORY_DIR:/tmp/$REPOSITORY_DIRNAME \
  --workdir /tmp/$REPOSITORY_DIRNAME \
  makotonagai/pyspark-pytest pytest --cov=. --pep8
