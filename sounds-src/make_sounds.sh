#!/bin/bash
# Generates the announcer voice pack with Piper TTS (voice: en_US-joe-medium, CC0) + ffmpeg effects.
# Output: ../dist/czero/sound/tdm/*.wav (22050 Hz, mono, 16-bit PCM - what GoldSrc expects)
set -e
PIPER=${PIPER:-~/.cache/cz-tts/bin/piper}
VOICE=${VOICE:-~/.cache/cz-voices/en_US-joe-medium.onnx}
OUT=${OUT:-../dist/czero/sound/tdm}
mkdir -p "$OUT" tmp
while IFS='|' read -r name text; do
  [ -z "$name" ] && continue
  echo "$text" | $PIPER -m "$VOICE" --length-scale 1.05 -f "tmp/$name.wav" >/dev/null 2>&1
  # deeper "arena announcer" voice: lower pitch, short echo, loud
  ffmpeg -nostdin -loglevel error -y -i "tmp/$name.wav" \
    -af "asetrate=22050*0.84,aresample=22050,atempo=1.12,aecho=0.8:0.5:60|120:0.35|0.2,highpass=f=80,loudnorm=I=-12:TP=-1.0,aresample=22050" \
    -ac 1 -ar 22050 -c:a pcm_s16le "$OUT/$name.wav"
done <<'LIST'
headshot|Headshot!
firstblood|First blood!
humiliation|Humiliation!
doublekill|Double kill!
triplekill|Triple kill!
multikill|Multi kill!
megakill|Mega kill!
ultrakill|Ultra kill!
monsterkill|Monster kill!
killingspree|Killing spree!
rampage|Rampage!
dominating|Dominating!
unstoppable|Unstoppable!
godlike|God like!
LIST
rm -rf tmp
