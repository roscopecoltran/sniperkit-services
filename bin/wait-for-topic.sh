#!/bin/bash

IFS=: read server port <<< $1
topic=$2
if [ -z "$server" ] || [ -z "$port" ] || [ -z "$topic" ]; then
  echo "Usage: wait-for-topic.sh <zookeeper-host>:<port> <topic>"
  exit 1
fi

zookeeper=$1
wait-for-kafka.sh $zookeeper

echo "Waiting for topic $topic at: $url"

re='^-?[0-9]+([.][0-9]+)?$'
function test {

 if kafka-topics --zookeeper $zookeeper --list | grep -e "^$topic\$" 2>&1> /dev/null; then
   echo "$(date) -- Found Topic"
 else
   echo "$(date) -- Didn't find topic $topic on $server:$port. Sleeping for 1s."
   sleep 1
   test
 fi

}

test
