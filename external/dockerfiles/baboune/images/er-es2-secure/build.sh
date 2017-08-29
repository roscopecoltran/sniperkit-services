#!/bin/bash
_version=2.4.3
_name=er/elasticsearch-secure
_registry=armdocker.rnd.ericsson.se/proj_kds

# Build and eventually push
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

# Tag latest
# Not needed 2.x is lower than 5

# Push
if [[ $PUSH ]]; then
  docker push ${_registry}/${_name}:${_version}
  docker push ${_registry}/${_name}:${_version}-$(date +"%Y%m%d")
  if [[ $LATEST ]]; then
    docker push ${_registry}/${_name}:latest
  fi
fi
