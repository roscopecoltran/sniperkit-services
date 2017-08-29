#!/bin/bash

#
# Un-mount a disk and delete the provisioner instance.
#
set -e

if [ "$#" != 1  ]; then
	echo Usage: $0 NAME 
	exit 1
fi

NAME="$1"
disk_name="${NAME}"
mntpath="/mnt/disks/${disk_name}"
gcloud compute ssh provisioner-01  --command "sudo umount ${mntpath}"
gcloud compute instances delete provisioner-01  -q  

