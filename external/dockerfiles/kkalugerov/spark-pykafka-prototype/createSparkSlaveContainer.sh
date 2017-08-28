#!/bin/bash

docker run -d --link master:master --volumes-from spark-drive spark-slave:latest