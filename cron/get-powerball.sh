#!/bin/bash
# get-powerball.sh — Download the latest Florida Powerball results PDF.
# Overwrites pb.pdf in /var/local/powerball and keeps dated history copies.
# Requires: wget

BASE_DIR="/var/local/powerball"
HIST_DIR="$BASE_DIR/history"
URL="https://files.floridalottery.com/exptkt/pb.pdf"
TODAY=$(date +%Y-%m-%d)
OUTFILE="$BASE_DIR/pb.pdf"
HISTFILE="$HIST_DIR/pb-$TODAY.pdf"
LOGFILE="$BASE_DIR/cron.log"

mkdir -p "$HIST_DIR"

# Download directly to pb.pdf, overwriting previous
wget -q -O "$OUTFILE" "$URL"

# Keep a dated copy if download succeeded and not empty
if [ -s "$OUTFILE" ]; then
    cp -f "$OUTFILE" "$HISTFILE"
    echo "$(date '+%F %T') OK: downloaded $URL -> $OUTFILE" >> "$LOGFILE"
else
    echo "$(date '+%F %T') ERROR: failed to download $URL" >> "$LOGFILE"
fi

# Optionally keep only the most recent N files
# find "$OUTDIR" -type f -name 'pb-*.pdf' -mtime +90 -delete
