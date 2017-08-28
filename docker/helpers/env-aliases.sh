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

# python v2.x & v3.x
alias python=python3
alias clearpyc='find . \( -type f -name "*.pyc" -o -type d -name __pycache__ \) -delete'
alias watchredis='redis-cli -n 1 monitor | cut -b -200'

# py-pip v2.x & v3.x
alias pip=pip3

# ls, the common ones I use a lot shortened for rapid fire usage
alias l='ls -lFh'     #size,show type,human readable
alias la='ls -lAFh'   #long list,show almost all,show type,human readable
alias lr='ls -tRFh'   #sorted by date,recursive,show type,human readable
alias lt='ls -ltFh'   #long list,sorted by date,show type,human readable
alias ll='ls -l'      #long list
alias ldot='ls -ld .*'
alias lS='ls -1FSsh'
alias lart='ls -1Fcart'
alias lrt='ls -1Fcrt'

# grep
alias grep='grep --color -nIE --exclude-dir=htmlcov --exclude-dir=.hg --exclude-dir=.git'


