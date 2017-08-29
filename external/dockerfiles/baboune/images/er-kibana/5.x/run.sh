#!/bin/bash
docker run -it --net="host" --rm -e ELASTICSEARCH_URL=http://147.214.206.54:9200 er/kibana:5.1.1 kibana