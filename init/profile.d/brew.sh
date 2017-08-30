#!/bin/bash
if [ -f $(brew --prefix)/etc/bash_completion ]; then
	. $(brew --prefix)/etc/bash_completion
fi

export PATH=/usr/local/opt/gnu-sed/libexec/gnubin:$PATH

export export HOMEBREW_GITHUB_API_TOKEN="b99148ff9022e5e2a93abd632789bfcf682da4b2"
