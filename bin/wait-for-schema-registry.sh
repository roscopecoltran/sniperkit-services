#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: wait-for-schema-registry.sh http://<host>:<port>"
  exit 1
fi

url=$1
echo "Waiting for schema registry at: $url"

function test {
  if curl -i $url/subjects 2>/dev/null | grep -q "200 OK"; then
    echo "$(date) -- Found Schema registry"
  else
    echo "$(date) -- Didn't find schema-registry $url yet. Sleeping for 1s."
    sleep 1
    test
  fi
}

test
