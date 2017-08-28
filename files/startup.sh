#!/bin/bash
echo "Starting elasticsearch"
/opt/elasticsearch/bin/elasticsearch &
sleep 10
echo "Starting logstash"
/opt/logstash/bin/logstash -f /opt/logstash/config/conf.d &
sleep 10
echo "Starting kibana"
/opt/kibana/bin/kibana
