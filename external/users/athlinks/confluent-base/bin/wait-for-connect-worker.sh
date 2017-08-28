#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: wait-for-connect-worker.sh http://<host>:<port>"
  exit 1
fi

url=$1
echo "Waiting for connect worker at: $url"


function test {
  if curl -i $url/connectors 2>/dev/null | grep -q "200 OK"; then
    echo "$(date) -- Found connect worker."
  else
    echo "$(date) -- Didn't find worker $url yet. Sleeping for 1s."
    sleep 1
    test
  fi
}

test
