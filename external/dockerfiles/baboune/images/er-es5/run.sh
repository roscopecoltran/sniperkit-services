#!/bin/bash
#docker run -it --rm --net='host' er/elasticsearch:2.3 bash
# Bind to localhost by default
docker run --rm -D -p 9200:9200 -p 9300:9300 er/elasticsearch5
# Bind to a specific inteface, and mount a data volume
#docker run --rm --net=host -it -e "HOST=147.214.206.54" -v /opt/elasticsearch/data  er/elasticsearch:5.1.1