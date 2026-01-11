#!/bin/bash

# 1. Get the name of the folder where this script is located
NEW_NAME=$(basename "$PWD")
OLD_NAME="20010101_template"

ditto "../${OLD_NAME}/${OLD_NAME}.fcpbundle" "${OLD_NAME}.fcpbundle"

echo "Updating Library name to: $NEW_NAME"

# 2. Rename only the .fcpbundle package folder
if [ -d "${OLD_NAME}.fcpbundle" ]; then
    mv "${OLD_NAME}.fcpbundle" "${NEW_NAME}.fcpbundle"
    echo "Done. Internal Events and Projects remain named '$OLD_NAME'."
else
    echo "Error: ${OLD_NAME}.fcpbundle not found in this directory."
fi