#!/bin/bash

IFS=: read server port <<< $1
if [ -z "$server" ] || [ -z "$port" ]; then
  echo "Usage: wait-for-kafka.sh <zookeeper-host>:<port>"
  exit 1
fi

zookeeper=$1
wait-for-zookeeper.sh $zookeeper
echo "Waiting for kafka at: $zookeeper"

re='^-?[0-9]+([.][0-9]+)?$'
function test {
 broker_count=$(echo "ls /brokers/ids" | $CONFLUENT_HOME/bin/zookeeper-shell $zookeeper 2> /dev/null | tail -n 1 | jq length 2> /dev/null)
 if [[ "$broker_count" =~ $re ]] && [ "$broker_count" -gt "0" ]; then
   echo "$(date) -- Found kafka"
 else
   echo "$(date) -- Didn't find kafka $server:$yet. Sleeping for 1s."
   sleep 1
   test
 fi

}

test
