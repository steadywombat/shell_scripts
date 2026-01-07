#created from google ai mode
#https://www.google.com/search?q=i+would+like+a+bash+script+for+mac+os+renames+folders+in+which+have+video+files+according+to+the+date+on+the+first+video+in+each+file.+keep+the+original+folder+names+but+append+the+date+in+the+format+YYYYMMDD_foldername&num=10&sca_esv=7670df6d756a93b6&hl=en&sxsrf=AE3TifOJ9evo_vpDNhprieLWFfXKvVjuvg%3A1767657750942&source=hp&ei=FlFcaY7aNoTPwbkP-J2EmAE&iflsig=AOw8s4IAAAAAaVxfJqfU5vWy_0Z-ppWoJI2cmH7xSSEN&aep=22&udm=50&ved=0ahUKEwiOvc6izvWRAxWEZzABHfgOARMQteYPCBg&oq=&gs_lp=Egdnd3Mtd2l6IgBIAFAAWABwAHgAkAEAmAEAoAEAqgEAuAEByAEAmAIAoAIAmAMAkgcAoAcAsgcAuAcAwgcAyAcAgAgA&sclient=gws-wiz&mstk=AUtExfAH5o1qOnxOIVsPPRRBgl413hSHsLxIqaSxIBojEaDyu9svccG3FCR19CHYz61z9qN2f-tvEuapExuGs5HP39N25qwUu4pvpq-OeoG2_JHml4IC9kzJiRWZ_LwvD3G1lmBAie8FBWrY0wsjA2vAxQZnXR59fW3yAeYRf9otGDALwIKDuLWw-Gk_PaNcqK5Lwc6KBOu1kX80KpDlfGD8Jl1rOdXDtG1OyYFiSA_0JGNHX9JhNbDS3MDUQQYng9bTEtrY08XtGJaLl6l5prQoDTSQCV14uUL2s1s&csuir=1&mtid=lFFcaaezLvm4seMPjv2e6Qg

#i would like a bash script for mac os renames folders in which have video files according to the date on the first video in each file. keep the original folder names but append the date in the format YYYYMMDD_foldername

#step 2
#can we make the script state what is going to happen before making any changes so the use has the chance to cancel the script

#step 3
#can we add in the color blue the first video to the end of echo "Renaming '$base_name' to '$new_name'"
#!/bin/bash

TARGET_DIR="${1:-.}"
CHANGES_LIST=$(mktemp)

# Define Color Variables
BLUE='\033[0;34m'
NC='\033[0m' # No Color (Reset)

echo "Scanning for folders..."

for dir in "$TARGET_DIR"/*/; do
    dir="${dir%/}"
    if [[ -d "$dir" ]]; then
        # Case-insensitive find for video files
        first_video=$(find "$dir" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.m4v" -o -iname "*.avi" \) | sort | head -n 1)

        if [[ -n "$first_video" ]]; then
            folder_date=$(stat -f "%SB" -t "%Y%m%d" "$first_video")
            base_name=$(basename "$dir")
            video_name=$(basename "$first_video")
            new_name="${folder_date}_${base_name}"
            
            if [[ "$base_name" != "$folder_date"* ]]; then
                # Use printf to safely handle color and formatting without adding '-e'
                printf "RENAME: '%s' -> '%s' [Video: %b%s%b]\n" "$base_name" "$new_name" "$BLUE" "$video_name" "$NC" >> "$CHANGES_LIST"
            fi
        fi
    fi
done

if [[ ! -s "$CHANGES_LIST" ]]; then
    echo "No folders need renaming."
    rm "$CHANGES_LIST"
    exit 0
fi

# Display proposed changes
cat "$CHANGES_LIST"
echo "--------------------------------------------------"

read -p "Do you want to apply these changes? (y/n): " confirm
if [[ $confirm != [yY] ]]; then
    echo "Aborting. No changes were made."
    rm "$CHANGES_LIST"
    exit 1
fi

echo "Renaming folders..."
while IFS= read -r line; do
    # Strip ANSI color codes and clean the line for the mv command
    clean_line=$(echo "$line" | sed $'s/\033\[[0-9;]*m//g')
    old_name=$(echo "$clean_line" | sed -E "s/RENAME: '(.*)' -> '.*/\1/")
    new_name=$(echo "$clean_line" | sed -E "s/.*' -> '(.*)' .*/\1/")
    
    # Ensure correct relative pathing
    mv "$TARGET_DIR/$old_name" "$TARGET_DIR/$new_name"
done < "$CHANGES_LIST"

echo "Done."
rm "$CHANGES_LIST"
