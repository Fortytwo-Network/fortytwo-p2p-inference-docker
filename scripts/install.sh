#!/bin/sh
set -e

PATH_EXEC="${PATH_EXEC}"
MODULE_NAME="${MODULE_NAME}"

MODULE_VERSION=$(curl -s "https://download.swarminference.io/$MODULE_NAME/latest")

case "$MODULE_NAME" in
    protocol) FILE_NAME="FortytwoProtocolNode-linux-amd64" ;;
    capsule)  FILE_NAME="FortytwoCapsule-linux-amd64-cuda124" ;;
    utilities)  FILE_NAME="FortytwoUtilsLinux" ;;
    *)
        echo "Error: Invalid MODULE_NAME: $MODULE_NAME" >&2
        exit 1
        ;;
esac

DOWNLOAD_MODULE_URL="https://download.swarminference.io/$MODULE_NAME/v$MODULE_VERSION/$FILE_NAME"

curl -fsSL -o "$PATH_EXEC" "$DOWNLOAD_MODULE_URL"

chmod +x "$PATH_EXEC"
