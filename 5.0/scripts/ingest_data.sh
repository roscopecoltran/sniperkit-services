#!/bin/sh

set -e

# Use Logstash to ingest data into Elasticsearch
cat nginx_logs | /logstash-entrypoint.sh -f nginx_logstash.conf

# Add Kibana Dashboard
curl -s -XPOST http://elasticsearch:9200/.kibana/_bulk -d @nginx_kibana.json

jq -r --arg command port_script.sh '.[] 
