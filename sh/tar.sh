#!/bin/bash
set -eux

rm -rf /tmp/er-save
mkdir -p /tmp/er-save
docker save er/elasticsearch5 > /tmp/er-save/elasticsearch5.tar

~/sshall/sshall-dn.sh 'mkdir -p /tmp/er-load/'
~/sshall/scpall-dn.sh /tmp/er-save/* /tmp/er-load/.

# if there was something generated
if [ -s /tmp/er-save/elasticsearch5.tar ]; then 
  #~/sshall/sshall-dn.sh 'docker rmi -f er/elasticsearch5:latest'
  ~/sshall/sshall-dn.sh 'docker load < /tmp/er-load/elasticsearch5.tar'
fi
