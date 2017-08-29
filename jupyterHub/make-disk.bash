#!/bin/bash

#
# Create a new disk, mount it to a new path, and return the path.
#

set -e

if [ "$#" != 2  ]; then
	echo Usage: $0 NAME SIZE
	exit 1
fi

NAME="$1"
SIZE="$2"
disk_name="${NAME}"

gcloud compute instances create provisioner-01 --zone us-central1-c	
gcloud compute disks create ${disk_name} --zone us-central1-c --size ${SIZE} --type pd-ssd
gcloud compute instances attach-disk provisioner-01 --disk ${disk_name} --zone us-central1-c

devpath="/dev"
device="$(gcloud compute ssh provisioner-01 --zone us-central1-c --command "sudo lsblk --output name | tail -1")"
blkdev=${devpath}/${device}
echo $blkdev
mntpath="/mnt/disks/${disk_name}"
echo $mntpath

gcloud compute ssh provisioner-01 --zone us-central1-c --command "sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard ${blkdev}"
gcloud compute ssh provisioner-01 --zone us-central1-c --command "sudo mkdir -p ${mntpath}"
gcloud compute ssh provisioner-01 --zone us-central1-c --command "sudo mount -o discard,defaults ${blkdev} ${mntpath}"
gcloud compute ssh provisioner-01 --zone us-central1-c --command "sudo umount ${mntpath}"
gcloud compute instances delete provisioner-01 --zone us-central1-c -q  

echo "New disk '${disk_name}' mounted at ${mntpath}"
echo "After running the course-specific data retrieval script, run:"
echo "  umount ${mntpath}"
echo "  gcloud compute instances attach-disk provisioner-01 --disk ${disk_name}"
