# Powerball Automation Package v2 – Installation Guide

This guide covers installing the full package, including prerequisites, directory layout, Raku parsers,
and your choice of scheduler (**cron** or **systemd**). It also includes an optional helper `powerballctl`
for day‑to‑day operations.

## 1) Unpack the archive
```bash
unzip powerball_project_v2.zip
cd powerball_project_v2
```

## 2) Install prerequisites

### Core tools
```bash
sudo apt install -y wget jq poppler-utils
```

### Raku and modules
```bash
sudo apt install -y rakudo zef
zef install LibCurl::Easy JSON::Fast DateTime::Parse
```

## 3) Base directories
```bash
sudo mkdir -p /var/local/powerball/history
sudo chown -R root:root /var/local/powerball
```

These paths will store:
- `pb.pdf` — latest downloaded PDF
- `history/pb-YYYY-MM-DD.pdf` — archived PDFs
- `history/blocks-YYYY-MM-DD.blocks` and `results-YYYY-MM-DD.json` — parsed outputs
- `current.blocks`, `current.json` — symlinks to most recent data
- `cron.log` — script log (when using the cron helper)

## 4) Install the main script
```bash
sudo install -m 755 cron/get-powerball.sh /usr/local/bin/get-powerball.sh
```

This script:
- Downloads the Florida **Powerball** PDF
- Saves an archival copy with date
- Parses to `.blocks` and `.json`
- Updates `current.blocks` / `current.json` symlinks

## 5) Install the Raku parsers
```bash
sudo mkdir -p /usr/local/powerball
sudo cp emit-blocks.raku /usr/local/powerball/
sudo chmod +x /usr/local/powerball/emit-blocks.raku
# (optional) extra util for local archives:
sudo cp extract-from-pdfs.raku /usr/local/powerball/ 2>/dev/null || true
```

Quick test:
```bash
sudo /usr/local/bin/get-powerball.sh
ls -l /var/local/powerball
```

You should see `current.blocks` and `current.json` alongside dated files in `history/`.

## 6) Choose a scheduler (pick one)

### Option A — cron (simple & portable)
```bash
sudo install -m 644 cron/powerball.cron.d /etc/cron.d/powerball
sudo systemctl reload cron
```
Runs **Tue, Thu, Sun** at **05:00** (local).

### Option B — systemd timer (recommended, hardened)
1) Create a dedicated user:
```bash
sudo useradd --system --home /var/local/powerball --shell /usr/sbin/nologin powerball
sudo chown -R powerball:powerball /var/local/powerball
```

2) Install units:
```bash
sudo install -m 644 systemd/powerball-download.service /etc/systemd/system/
sudo install -m 644 systemd/powerball-download.timer   /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now powerball-download.timer
```

3) Verify:
```bash
systemctl status powerball-download.timer
sudo systemctl start powerball-download.service
journalctl -u powerball-download.service --since "1 hour ago"
```

The service is sandboxed: `User=powerball`, `ReadWritePaths=/var/local/powerball`, `ProtectSystem=strict`, `PrivateTmp=yes`, and other hardening options.

> **Note:** Do not enable both cron and systemd simultaneously; you’ll double-run the job.

## 7) Optional helper — powerballctl
```bash
sudo install -m 755 systemd/powerballctl /usr/local/bin/powerballctl

powerballctl status
powerballctl enable
powerballctl run-now
powerballctl logs --since "1 day ago"
powerballctl next-run
powerballctl where
```

## 8) Expected output layout
```text
/var/local/powerball/
  pb.pdf
  current.blocks -> history/blocks-YYYY-MM-DD.blocks
  current.json  -> history/results-YYYY-MM-DD.json
  history/
    pb-YYYY-MM-DD.pdf
    blocks-YYYY-MM-DD.blocks
    results-YYYY-MM-DD.json
  cron.log
```

## 9) Troubleshooting
- Ensure `pdftotext` is installed (`sudo apt install poppler-utils`).
- If the PDF layout changes upstream, re-run with `--emit=both` and inspect generated output:
  ```bash
  raku /usr/local/powerball/emit-blocks.raku --pdf=/var/local/powerball/pb.pdf --emit=both
  ```
- Use `journalctl -u powerball-download.service` or check `/var/local/powerball/cron.log` for detailed errors.
