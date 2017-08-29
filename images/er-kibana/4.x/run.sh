#!/bin/bash
docker run -it --net="host" --rm -e ELASTICSEARCH_URL=http://147.214.206.54:9200 armdocker.rnd.ericsson.se/proj_kds/er/kibana:4.6.2 kibana

