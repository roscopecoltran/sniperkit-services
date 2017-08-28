#!/bin/bash 

docker run -d -p 8080:8080 -p 7077:7077 --volumes-from spark-drive --name master spark-master:latest