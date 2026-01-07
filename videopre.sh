#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
# --- Configuration ---
EXTENSIONS=(
    MOV mov MP4 mp4 AVI avi LOG jpg JPG RAW CR2 DNG dng UFR XMP tif TIF 
    WAV wav MP3 mp3 XML ARW png PNG aae LRF AAC jpeg HEIC
)
MARKER_FILE="videopre_run"
DESCRIPTION="$1"

# ** NEW: capture optional second argument (single-file mode) **
SECOND_FILE="$2"

CURRENT_DIR=$(pwd)
PARENT_DIR=$(dirname "$CURRENT_DIR")
DIR_NAME=$(basename "$CURRENT_DIR")

# Define ANSI Color Codes (simplified definitions)
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color (resets the color)

FIRST_FILE_DATE=""
# --- Pre-run Checks (No Colors Here) ---
# Ignore marker file check if SECOND_FILE is set
if [ -f "$MARKER_FILE" ] && [ -z "$SECOND_FILE" ]; then
    echo "Warning: Directory already processed. Marker file ('$MARKER_FILE') exists."
    echo "To run the script again in this directory, please delete '$MARKER_FILE' manually."
    exit 1
fi

if [ -z "$DESCRIPTION" ]; then
    echo "Error: Description argument not set."
    echo "Usage: $0 <description_tag>"
    echo "Example: $0 hawaii_vacation"
    exit 1
fi

touch "$MARKER_FILE"
echo "Starting file renaming and directory organization process."

# --- Main Logic (File Renaming with Colors) ---

for ext in "${EXTENSIONS[@]}"; do
    shopt -s nullglob
    # ** FIXED: Proper handling of single-file mode **
    if [ -n "$SECOND_FILE" ]; then
        # If second argument is provided, process only that file (if it matches the extension)
        if [[ "$SECOND_FILE" == *."$ext" ]]; then
            file="$SECOND_FILE"
            timestamp_formatted=$(stat -f '%SB' -t '%Y%m%d%H%M%S_' "$file")
            new_name="${timestamp_formatted}${DESCRIPTION}_$file"
            
            if [ "$file" != "$new_name" ]; then
                mv "$file" "$new_name"
                # THIS LINE NOW HAS COLOR CODING
                echo -e "Renamed: ${BLUE}$file${NC} -> ${GREEN}$new_name${NC}" 

                if [ -z "$FIRST_FILE_DATE" ]; then
                    FIRST_FILE_DATE=$(echo "$timestamp_formatted" | cut -c 1-8)
                    # This status message remains plain text/no color
                    echo "Captured earliest date from first file: $FIRST_FILE_DATE"
                fi
            fi
        fi
    else
        # Original behavior: process all files of this extension
        for file in *."$ext"; do
            timestamp_formatted=$(stat -f '%SB' -t '%Y%m%d%H%M%S_' "$file")
            new_name="${timestamp_formatted}${DESCRIPTION}_$file"
            
            if [ "$file" != "$new_name" ]; then
                mv "$file" "$new_name"
                # THIS LINE NOW HAS COLOR CODING
                echo -e "Renamed: ${BLUE}$file${NC} -> ${GREEN}$new_name${NC}" 

                if [ -z "$FIRST_FILE_DATE" ]; then
                    FIRST_FILE_DATE=$(echo "$timestamp_formatted" | cut -c 1-8)
                    # This status message remains plain text/no color
                    echo "Captured earliest date from first file: $FIRST_FILE_DATE"
                fi
            fi
        done
    fi
    shopt -u nullglob
done

# --- Post-Processing: Rename Directory using the first date found ---

if [ -z "$FIRST_FILE_DATE" ]; then
    echo "No files were found or processed to determine a date. Directory not renamed."
    exit 1
fi

# If we're in single file mode, don't rename the directory
if [ -n "$SECOND_FILE" ]; then
    echo "Single file mode: Directory not renamed."
    echo "Process complete."
    exit 0
fi

NEW_DIR_NAME="${FIRST_FILE_DATE}_${DESCRIPTION}"
# --- Final Step: Rename Directory and Leave (No Colors Here) ---
# The line below uses ANSI color codes: 
# ${BLUE} changes text color to blue, ${GREEN} changes to green, ${NC} resets to normal.
echo -e "Renaming directory: ${BLUE}$DIR_NAME${NC} -> ${GREEN}$NEW_DIR_NAME${NC}"

cd "$PARENT_DIR"

mv "$DIR_NAME" "$NEW_DIR_NAME"

open .

echo "Process complete."
