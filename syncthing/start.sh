#!/bin/sh

set -e

CONFIG_FOLDER="/root/.config/syncthing"
CONFIG_FILE="$CONFIG_FOLDER/config.xml"

if [ ! -f "$CONFIG_FILE" ]; then
    /go/bin/syncthing -generate="$CONFIG_FOLDER"
fi

xmlstarlet ed -L -u "/configuration/gui/address" -v "0.0.0.0:8384" "$CONFIG_FILE"

/go/bin/syncthing

