#!/usr/bin/env bash
set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 input_media"
  exit 1
fi

INPUT="$1"

if [ ! -f "$INPUT" ]; then
  echo "Error: input file does not exist: $INPUT" >&2
  exit 1
fi

BASENAME="${INPUT%.*}"
TMP_WAV="$(mktemp /tmp/whisper_audio_XXXX.wav)"

trap 'rm -f "$TMP_WAV" "${TMP_WAV}.srt" "${TMP_WAV}.txt"' EXIT

echo "→ Extracting audio..."
ffmpeg -v error -y -i "$INPUT" -ar 16000 -ac 1 "$TMP_WAV"

echo "→ Transcribing with Whisper... (this can take a while)"
whisper \
  -m /opt/local/share/whisper/ggml/ggml-medium.bin \
  --output-srt \
  --output-txt \
  "$TMP_WAV" \
  > /dev/null 2>&1

echo "→ Writing output files..."
mv "${TMP_WAV}.srt" "${BASENAME}.srt"
mv "${TMP_WAV}.txt" "${BASENAME}.txt"

echo "✓ Done"
