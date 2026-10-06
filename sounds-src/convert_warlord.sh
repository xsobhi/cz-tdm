#!/bin/bash
# Converts the WARLORD Announcer Audio Pack (VoiceBosch, CC BY-SA 4.0)
# https://voicebosch.itch.io/warlord-announcer-audio-pack
# into dist/czero/sound/tdm/*.wav: 22050 Hz mono 16-bit (GoldSrc format),
# trailing silence trimmed, loudness normalized so it is heard over gunfire.
# Usage: convert_warlord.sh /path/to/extracted/warlord/wavs
set -e
SRC="$1"; OUT="$(dirname "$0")/../dist/czero/sound/tdm"
mkdir -p "$OUT"
while IFS='|' read -r name file; do
  ffmpeg -nostdin -loglevel error -y -i "$SRC/$file" \
    -af "areverse,silenceremove=start_periods=1:start_threshold=-50dB:start_silence=0.08,areverse,silenceremove=start_periods=1:start_threshold=-50dB,loudnorm=I=-12:TP=-1.0,aresample=22050" \
    -ac 1 -ar 22050 -c:a pcm_s16le "$OUT/$name.wav"
  echo "$name <- $file"
done <<'MAP'
headshot|09. Headshot.wav
firstblood|08. First Blood.wav
doublekill|03. Double Kill.wav
triplekill|04. Triple Kill.wav
annihilation|24. Annihilation.wav
eradication|26. Eradication.wav
rampage|02. Rampage.wav
dominating|05. Dominating.wav
unstoppable|06. Unstoppable.wav
revenge|27. Revenge Kill.wav
teamdeathmatch|12. Team Deathmatch.wav
MAP
