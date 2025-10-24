# Power Ball – Minimal Fetch Kit

This bundle gives you a tiny, reproducible way to fetch **Powerball** winning numbers in JSON.
It uses an official open-data endpoint hosted by the State of New York (covers national Powerball draws).
Florida’s site publishes **PDF history** rather than a public JSON feed.

## Sources
- **Winning numbers JSON (national Powerball):**
  - `https://data.ny.gov/resource/d6yy-54nr.json`
- **Florida Lottery “Winning Number History” (PDF links, no JSON):**
  - Go to the history page and pick **POWERBALL**, which links to `pb.pdf`.
- **Jackpot values:** The open-data feed above does **not** include jackpot amounts.
  - Optionally query MUSL’s Powerball game info API for advertised prize data.

## What’s included

- `fetch_latest_powerball.raku` — Fetch the latest draw from the NY Open Data JSON and print a normalized JSON object.
- `fetch_range_powerball.raku` — Fetch a date range (or last N draws) and emit a JSON array.
- `schemas/powerball.json` — Minimal JSON schema for the normalized output.
- `examples/` — Example outputs.
- `LICENSE` — CC-BY 4.0 for the docs and README, Artistic-2.0 for the code (common in Raku).
  
> Note: If you specifically need **Florida-only** presentation, the numbers are the same (Powerball is national). If you need **Florida retailer/jackpot winners**, you’ll need to scrape/parse Florida’s PDF or use a commercial API.

## Requirements

- Raku (Rakudo). On Debian/Ubuntu: `sudo apt install rakudo`
- `curl`

## Usage

### Latest draw
```bash
raku fetch_latest_powerball.raku
```

### Last 10 draws
```bash
raku fetch_range_powerball.raku --last=10
```

### Specific date range
```bash
# Inclusive start, inclusive end (YYYY-MM-DD)
raku fetch_range_powerball.raku --from=2025-08-01 --to=2025-10-13
```

## Normalized JSON shape

```json
{
  "draw_date": "2025-10-11",
  "numbers": [1, 2, 3, 4, 5],
  "powerball": 6,
  "multiplier": "2",
  "source": "data.ny.gov",
  "jackpot_usd": null
}
```

To augment with **jackpot** you can query MUSL’s Game Info API and merge by date (see comments in the scripts).

---

**Why these sources?**
- Florida’s official site provides a **PDF** for Powerball history, not a JSON API.
- The NY Open Data Powerball dataset exposes a stable **JSON API** with recent draws.
- MUSL’s API exposes **advertised jackpot** values for Powerball, which can be combined.

