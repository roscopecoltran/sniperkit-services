#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
cd /scripts
. ./common.sh

function repoSizeDisparity {
# Checks the size difference between your current repo, and the size of that 
#   repo's pack files to identify oversized repos (usually due to large, 
#   accidentally-committed files).
    local repoFolder=$1
    local repoSizeBytes=$(du -sb ${repoFolder} | cut -f 1)
    #FIXME: Currently we get the size of the .git, should be including only 
    #  the file database size.
    local packSizeBytes=$(du -sb ${repoFolder}/.git | cut -f 1)
    local currentRevSize=$(echo "${repoSizeBytes} - ${packSizeBytes}" | bc)
    local sizeDiffRatio=$(echo "${packSizeBytes} / ${currentRevSize}" | bc -l)

    echo -e " - repoFolder: 	${repoFolder} "
    echo -e " - repoSizeBytes: 	${repoSizeBytes} "
    echo -e " - currentRevSize: ${currentRevSize} "
    echo -e " - packSizeBytes: 	${packSizeBytes} "
    echo -e " - sizeDiffRatio: 	${sizeDiffRatio} "

}

