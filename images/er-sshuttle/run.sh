#!/bin/bash

docker run --net=host --rm -it --privileged -v /Users/lmcnise/.ssh/:/keys armdocker.rnd.ericsson.se/proj_kds/er/sshuttle:0.78.1 /bin/sh
