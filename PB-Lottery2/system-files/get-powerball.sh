#!/bin/bash
set -euo pipefail
BASE_DIR="/var/local/powerball"
HIST_DIR="$BASE_DIR/history"
URL="https://files.floridalottery.com/exptkt/pb.pdf"
TODAY=$(date +%Y-%m-%d)
OUTFILE="$BASE_DIR/pb.pdf"
HISTFILE="$HIST_DIR/pb-$TODAY.pdf"
LOGFILE="$BASE_DIR/cron.log"
PARSER="/usr/local/powerball/emit-blocks.raku"
mkdir -p "$HIST_DIR"
if wget -q -O "$OUTFILE" "$URL"; then
  if [ -s "$OUTFILE" ]; then
    cp -f "$OUTFILE" "$HISTFILE"
    echo "$(date '+%F %T') OK: downloaded $URL -> $OUTFILE" >> "$LOGFILE"
    if [ -x "$PARSER" ]; then
      TMP="$BASE_DIR/tmp.out"
      OUT_BLOCKS="$BASE_DIR/latest.blocks"
      OUT_JSON="$BASE_DIR/latest.json"
      raku "$PARSER" --pdf="$OUTFILE" --emit=both > "$TMP" 2>>"$LOGFILE" || {
        echo "$(date '+%F %T') ERROR: emit-blocks.raku failed" >> "$LOGFILE"; exit 1; }
      grep -E '^[0-9]' "$TMP" > "$OUT_BLOCKS" || true
      if command -v jq >/dev/null 2>&1; then jq '.' "$TMP" > "$OUT_JSON" 2>>"$LOGFILE" || true
      else cp -f "$TMP" "$OUT_JSON"; fi
      # determine draw date
      DRAW_DATE=""
      if command -v jq >/dev/null 2>&1; then
        DRAW_DATE=$(jq -r '.[].draw_date' "$OUT_JSON" 2>/dev/null | sort | tail -1 || true)
      else
        DRAW_DATE=$(grep -oE '"draw_date"\s*:\s*"[0-9]{4}-[0-9]{2}-[0-9]{2}' "$OUT_JSON" | sed -E 's/.*"([0-9]{4}-[0-9]{2}-[0-9]{2})/\1/' | sort | tail -1 || true)
      fi
      [ -z "$DRAW_DATE" ] && DRAW_DATE="$TODAY"
      cp -f "$OUT_BLOCKS" "$HIST_DIR/blocks-$DRAW_DATE.blocks"
      cp -f "$OUT_JSON"   "$HIST_DIR/results-$DRAW_DATE.json"
      ln -sf "$HIST_DIR/blocks-$DRAW_DATE.blocks" "$BASE_DIR/current.blocks"
      ln -sf "$HIST_DIR/results-$DRAW_DATE.json"  "$BASE_DIR/current.json"
      rm -f "$TMP"
      echo "$(date '+%F %T') OK: parsed -> $OUT_BLOCKS / $OUT_JSON; dated=$DRAW_DATE" >> "$LOGFILE"
    else
      echo "$(date '+%F %T') WARN: parser $PARSER not found or not executable" >> "$LOGFILE"
    fi
  else
    echo "$(date '+%F %T') ERROR: empty file after download from $URL" >> "$LOGFILE"; exit 1
  fi
else
  echo "$(date '+%F %T') ERROR: wget failed for $URL" >> "$LOGFILE"; exit 1
fi
