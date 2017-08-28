#!/bin/bash

IFS=: read server port <<< $1
if [ -z "$server" ] || [ -z "$port" ]; then
  echo "Usage: wait-for-zookeeper.sh <zookeeper-host>:<port>"
  exit 1
fi

echo "Waiting for zookeeper at: $server:$port"

function test {
  if echo srvr | nc $server $port | grep -q -e "[Mode: follower|Mode: leader]"; then
    echo Found zookeeper
  else
    echo "Didn't find zookeeper $server:$port yet. Sleeping for 1s."
    sleep 1
    test
  fi
}

test
