#!/usr/bin/env bash
set -euo pipefail

VIDEO_URL="$1"
OUTPUT_FILE="${2:-transcript.txt}"
MODEL="/opt/local/share/whisper/ggml/ggml-medium.bin"

# Create temporary folder
TMP_DIR=$(mktemp -d /tmp/whisperXXXX)
echo "Using temporary folder: $TMP_DIR"

# Download audio only
yt-dlp -f bestaudio -o "$TMP_DIR/audio.%(ext)s" "$VIDEO_URL"

# Find downloaded audio
AUDIO_FILE=$(ls "$TMP_DIR"/audio.* | head -n 1)

# Convert to 16-bit WAV, 16 kHz mono
WAV_FILE="$TMP_DIR/audio.wav"
ffmpeg -y -i "$AUDIO_FILE" -ac 1 -ar 16000 -sample_fmt s16 "$WAV_FILE"

# Transcribe with whisper.cpp
whisper "$WAV_FILE" \
  --model "$MODEL" \
  --language english \
  --output-txt \
  --output-file transcript

# Move transcript to desired filename
mv transcript.txt "$OUTPUT_FILE"

# Clean up temporary folder
rm -rf "$TMP_DIR"

echo "Transcript saved to $OUTPUT_FILE"
