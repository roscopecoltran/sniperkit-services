#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
. ${DIR}/internal/common.sh
. ${DIR}/internal/env-aliases.sh
. ${DIR}/internal/vcs-git.sh

