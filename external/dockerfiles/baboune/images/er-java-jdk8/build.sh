#!/bin/bash

_version=111u14
_name=er/java-jdk8
_registry=armdocker.rnd.ericsson.se/proj_kds

# Functionality
for key in "$@"
do
  #echo "key: $key"
  case $key in
    -p|--push)
    PUSH=true
    shift # past argument
    ;;    
    -l|--latest)
    LATEST=true
    shift # past argument
    ;;  
    --default)
    DEFAULT=YES
    ;;
    *)
      # unknown option
      echo "Unsupported option \'$key\'. Supported options are:\n   -p|--push  Push to registry."
      exit
    ;;
  esac
  shift
done

docker build -t ${_name}:${_version} -t ${_registry}/${_name}:${_version} -t ${_registry}/${_name}:${_version}-$(date +"%Y%m%d") .
if [[ $LATEST ]]; then
  docker tag ${_name}:${_version} ${_registry}/${_name}:latest
  docker tag ${_name}:${_version} ${_name}:latest
fi

# Push
if [[ $PUSH ]]; then
  docker push ${_registry}/${_name}:${_version}
  docker push ${_registry}/${_name}:${_version}-$(date +"%Y%m%d")
  if [[ $LATEST ]]; then
    docker push ${_registry}/${_name}:latest
  fi
fi
