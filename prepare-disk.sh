#!/bin/bash

#
# Create a new disk, mount it to a new path, and return the path.
#

set -e

if [ "$#" != 1  ]; then
	echo Usage: $0 NAME 
	exit 1
fi

NAME="$1"
disk_name="${NAME}"
mntpath="/mnt/disks/${disk_name}"

gcloud compute ssh provisioner-01  --command "sudo mkdir -p ${mntpath}/RawData"
gcloud compute ssh provisioner-01  --command "sudo mkdir -p ${mntpath}/SharedData"
gcloud compute ssh provisioner-01  --command "sudo mkdir -p ${mntpath}/UserData"
gcloud compute ssh provisioner-01  --command "sudo chmod -R 777  ${mntpath}/RawData"
gcloud compute ssh provisioner-01  --command "sudo chmod -R 777  ${mntpath}/SharedData"
gcloud compute ssh provisioner-01  --command "sudo chmod -R 777  ${mntpath}/UserData"

echo "New disk '${disk_name}' mounted at ${mntpath}"
echo "After running the course-specific data retrieval script, run:"
echo "  umount ${mntpath}"
echo "  gcloud compute instances attach-disk provisioner-01 --disk ${disk_name}"
