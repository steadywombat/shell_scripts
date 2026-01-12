#!/bin/bash

# 1. Get the name of the folder where this script is located
# Use "${PWD##*/}" as a more robust alternative to basename
NEW_NAME="${PWD##*/}"
OLD_NAME="20010101_template"
SOURCE_PATH="../${OLD_NAME}/${OLD_NAME}.fcpbundle"

# Check if the source template actually exists before copying
if [ ! -d "$SOURCE_PATH" ]; then
    echo "Error: Source template not found at $SOURCE_PATH"
    exit 1
fi

echo "Copying template..."
ditto "$SOURCE_PATH" "${OLD_NAME}.fcpbundle"

echo "Updating Library name to: $NEW_NAME"

# 2. Rename the .fcpbundle package folder
if [ -d "${OLD_NAME}.fcpbundle" ]; then
    mv "${OLD_NAME}.fcpbundle" "${NEW_NAME}.fcpbundle"
    echo "Done. Internal Events and Projects remain named '$OLD_NAME'."
else
    echo "Error: Failed to copy ${OLD_NAME}.fcpbundle."
    exit 1
fi
