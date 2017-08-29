#!/bin/bash
set -eux

# Test
# docker run -it --rm --net="host" er/zookeeper3 sha

# Ignore error
docker rm -f zookeeper || true
docker run -d --name="zookeeper" --net="host" -v /mnt/data/zookeeper/log:/opt/zookeeper/log er/zookeeper3
