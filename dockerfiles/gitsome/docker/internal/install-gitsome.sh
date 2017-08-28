#!/bin/sh
set -x
set -e

clear
echo

alias python=python3
alias pip=pip3

## #################################################################
## global env variables
## #################################################################

pip install --no-cache --no-cache-dir gitsome

if [[ -f /root/.gitsomeconfig ]]; then
	mv /root/.gitsomeconfig mv /root/.gitsomeconfig-origin
fi

if [[ -f /root/.gitsomeconfig ]]; then
	mv /root/.gitsomeconfig mv /root/.gitsomeconfig-origin
fi

if [[ -f /root/.gitconfig ]]; then
	mv /root/.gitconfig mv /root/.gitconfig-origin
fi

