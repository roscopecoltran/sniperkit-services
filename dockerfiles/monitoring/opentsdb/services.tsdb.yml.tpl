version: "2"

services:

## tsdb
  tsdb-${i}:
    container_name: tsdb-${i}
    networks: ["${network_name}"]
    hostname: tsdb-${i}.${network_name}
    image: smizy/opentsdb:2.2.2-alpine
    ports: 
      - 4242:4242
    environment:
      - SERVICE_4242_NAME=opentsdb
      ${SWARM_FILTER_TSDB_${i}}
    volumes_from:
      - regionserver-${i}
##/ tsdb