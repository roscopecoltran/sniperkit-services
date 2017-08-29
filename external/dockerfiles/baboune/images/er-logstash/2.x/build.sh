#!/bin/bash
#docker build -t er/logstash:2.4.0 .
#docker tag er/logstash:2.4.0 er/logstash2

_version=2.4.1 
_name=er/logstash
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
