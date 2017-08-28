#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: wait-for-url.sh http://<host>:<port>"
  exit 1
fi

url=$1
echo "Waiting for 200 at: $url"

function test {
  if curl -i $url 2>/dev/null | grep -q "200 OK"; then
    echo "$(date) -- Found URL"
  else
    echo "$(date) -- Didn't find $url yet. Sleeping for 1s."
    sleep 1
    test
  fi
}

test
