#!/bin/sh
set -e

PATH_EXEC="${PATH_EXEC}"
MODULE_NAME="${MODULE_NAME}"

echo "Check current version"
CURRENT_MODULE_VERSION_OUTPUT=$("$PATH_EXEC" --version 2>/dev/null)

MODULE_VERSION=$(curl -s "https://download.swarminference.io/$MODULE_NAME/latest")
echo "Latest version is v$MODULE_VERSION"

case "$CURRENT_MODULE_VERSION_OUTPUT" in
  *"$MODULE_VERSION"*)
    echo "Up to date"
    ;;
  *)
    echo "Updating..."
    ./install.sh
    echo "Successfully updated"
    ;;
esac

"$PATH_EXEC"
