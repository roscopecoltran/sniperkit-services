#!/bin/bash

docker run --rm -it --link master:master --net sparkproofofconcept_default  --volumes-from spark-datastore spark-submit:latest spark-submit --master spark://172.22.0.$1:7077 /data/$2 
 
