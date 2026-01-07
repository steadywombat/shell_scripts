#!/bin/bash

# 1. Configuration & Dependency Check
shopt -s nocaseglob
BLUE='\033[0;34m'
NC='\033[0m'
MODEL_PATH="$HOME/shell_scripts/models/ggml-base.en.bin"
THREADS=$(sysctl -n hw.logicalcpu 2>/dev/null || nproc) # Works for Mac and Linux

[[ ! -f "$MODEL_PATH" ]] && echo "Model not found at $MODEL_PATH" && exit 1

mkdir -p whisper_wavs
FOLDER_NAME=${PWD##*/}
TRANSCRIPT_FILE="${FOLDER_NAME}_transcript.txt"

echo "Starting batch processing with $THREADS threads..."

# 2. Processing Loop
for FILE in *.{MP4,MOV,WAV}; do
    [[ -e "$FILE" ]] || continue # Handle empty glob

    # Clean up naming
    
    OUTPUT_WAV="whisper_wavs/${FILE}.wav"

    echo "===================================================="
    echo -e " PROCESSING: ${BLUE}${FILE}${NC}"
    echo "===================================================="
    
    # 1. FFmpeg Conversion (only if wav doesn't exist)
    if [[ ! -f "$OUTPUT_WAV" ]]; then
        echo -e "[FFmpeg] Converting to 16kHz mono WAV..."
        ffmpeg -i "$FILE" -vn -ac 1 -ar 16000 -acodec pcm_s16le "$OUTPUT_WAV" -hide_banner -loglevel error -stats
    fi

    # 2. Whisper Transcription
    echo "[Whisper] Transcribing ${FILE}..."
    #echo "----------------------------------------------------" >> "$TRANSCRIPT_FILE"
    echo -e "--- FILE: ${FILE} ---\n" >> "$TRANSCRIPT_FILE"
    
    # Added -t for speed and stripped unnecessary flags for a clean log
    whisper-cli -t "$THREADS" --max-context 32 -et 2.8 -bs 5 \
                -m "$MODEL_PATH" -f "$OUTPUT_WAV" | tee -a "$TRANSCRIPT_FILE"

    echo "\n\n\n" >> "$TRANSCRIPT_FILE"
    
    echo -e "\nFinished: ${BLUE}${FILE}${NC}\n"

done

echo "===================================================="
echo "Batch process complete. Output saved to $TRANSCRIPT_FILE"
echo "Removing all temporary WAV files..."
say "ai Transcribe $TRANSCRIPT_FILE finished." &
# Ask for confirmation before cleaning up the directory
echo "===================================================="
read -p "Batch complete. Delete all temporary WAV files? (y/n): " confirm

if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
    echo "Deleting whisper_wavs/ folder..."
    rm -rf whisper_wavs/
    echo "Cleanup finished."
else
    echo "WAV files preserved in whisper_wavs/ folder."
fi


open . # Opens the folder (macOS)
