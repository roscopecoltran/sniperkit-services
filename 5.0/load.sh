#!/bin/sh

set -e

# Ingest data into Elasticsearch
ingest

# Add Kibana Dashboard
: ${ES_URL:=http://elasticsearch:9200}

if [ -z ${ES_USERNAME} ]; then
  import_dashboards -es ${ES_URL} -dir /nginx_data/nginx-dashboard;
else
  import_dashboards -es ${ES_URL} -user $ES_USERNAME -pass $ES_PASSWORD -dir /nginx_data/nginx-dashboard;
fi
