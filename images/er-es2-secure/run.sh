#!/bin/bash

# Bind to localhost by default
docker run --rm -p 9200:9200 -p 9300:9300 er/elasticsearch-secure:2.4.3
# Bind to a specific inteface, and mount a data volume
#docker run --rm --net=host -it -e "HOST=147.214.206.54" -v /opt/elasticsearch/data  er/elasticsearch-secure:2.4.3