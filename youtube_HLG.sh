#!/bin/bash

# Define colors for terminal output
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to ask for user confirmation
function confirm_action() {
    while true; do
        read -r -p "No specific file provided. Convert ALL .mov files in the directory? (y/n): " yn
        case $yn in
            [Yy]* ) return 0;; # Return success (0) if Yes
            [Nn]* ) return 1;; # Return failure (1) if No
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Check if a filename was provided as an argument ($# is the argument count)
if [ "$#" -eq 1 ]; then
    # If one argument is provided, set the file list to just that file
    files_to_process=("$1")
    echo -e "${BLUE}Processing single file provided as argument: $1${NC}"
else
    # If no argument is provided, prompt the user
    if confirm_action; then
        # If user confirms (returns 0), find all .mov files
        files_to_process=(*.mov)
        echo -e "${BLUE}Proceeding with all .mov files.${NC}"
    else
        # If user declines (returns 1), exit the script
        echo "Operation cancelled by user. Exiting."
        exit 0
    fi
fi

# Loop through the list of files to process
for file in "${files_to_process[@]}"
do
    # Check if the file actually exists before trying to process it
    if [ -f "$file" ]; then
        echo -e "\nConverting: ${BLUE}$file${NC}"
        
        # --- KEY CHANGE IS HERE ---
        # Define the output filename using parameter expansion to strip the extension
        # ${file%.*} removes the shortest match of .* from the end of the filename
        output_file_hlg="${file%.*}"_youtube_hevc_hdr_HLG_v65.mp4
        #output_file_hlg="${file%.*}"_youtube_hevc_hdr_HLG_v80.mp4
        
        echo -e "Output filename will be: ${BLUE}$output_file_hlg${NC}"

        # --- HLG transfer command using the new output filename ---
        time ffmpeg -i "$file" -c:v hevc_videotoolbox -q:v 65 -profile:v main10 -pix_fmt p010le -color_primaries bt2020 -color_trc arib-std-b67 -colorspace bt2020nc -tag:v hvc1 -c:a aac -b:a 320k -movflags +faststart "$output_file_hlg"
 #        time ffmpeg -i "$file" -c:v hevc_videotoolbox -q:v 80 -profile:v main10 -pix_fmt p010le -color_primaries bt2020 -color_trc arib-std-b67 -colorspace bt2020nc -tag:v hvc1 -c:a aac -b:a 320k -movflags +faststart "$output_file_hlg"
  

       say -v Fiona "$output_file_hlg finished " &
    else
        echo -e "\n${BLUE}Skipping: $file does not exist or is not a regular file.${NC}"
    fi
done
say -v Fiona "youtube HLG finished" &

