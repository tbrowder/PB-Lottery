#!/usr/bin/env bash
# get-powerball-pdf.sh
# Simple script to download the latest Florida Powerball PDF.
# Requires: wget or curl, network access.
# Destination: /var/local/powerball/pb.pdf

set -euo pipefail

OUTDIR="/var/local/powerball"
OUTFILE="${OUTDIR}/pb.pdf"
URL="https://files.floridalottery.com/exptkt/pb.pdf"
LOGFILE="${OUTDIR}/manage.log"

# Ensure destination directory exists
mkdir -p "${OUTDIR}"

# Download latest Powerball PDF
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Downloading latest Powerball PDF..." | tee -a "${LOGFILE}"

if command -v wget >/dev/null 2>&1; then
    wget -q -O "${OUTFILE}" "${URL}"
elif command -v curl >/dev/null 2>&1; then
    curl -s -L -o "${OUTFILE}" "${URL}"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Neither wget nor curl found." | tee -a "${LOGFILE}"
    exit 1
fi

# Confirm successful download
if [[ -f "${OUTFILE}" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Saved: ${OUTFILE}" | tee -a "${LOGFILE}"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Failed to download PDF." | tee -a "${LOGFILE}"
    exit 1
fi
