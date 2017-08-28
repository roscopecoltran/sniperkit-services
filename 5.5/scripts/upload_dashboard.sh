#!/bin/sh

set -e

json_data=$1

echo ${json_data} | jq -r '._type'
# curl -s -XPOST "http://elasticsearch:9200/.kibana/${doc_type}" -d ${json_data}
eval "$(jq -r '.[] | ["./upload_dashboard.sh"] + [. | @sh] | join(" ")' nginx_data/nginx_kibana.json)"
