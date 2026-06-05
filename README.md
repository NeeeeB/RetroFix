# <img src="https://raw.githubusercontent.com/NeeeeB/RetroFix/main/screenshots/RetroFix.png" width="48" align="center" /> RetroFix

**Fix your game collection for Retrobat**

RetroFix is a utility for [Retrobat](https://www.retrobat.org/) that scans your installation and helps you identify and fix issues in your game collection — missing BIOS files, unscraped ROMs, missing or orphaned media files, and more.

---

## Screenshots

![Main window](https://raw.githubusercontent.com/NeeeeB/RetroFix/main/screenshots/Main.png)

![BIOS Details](https://raw.githubusercontent.com/NeeeeB/RetroFix/main/screenshots/Bios.png)

![Gamelist Details](https://raw.githubusercontent.com/NeeeeB/RetroFix/main/screenshots/Games.png)

---

## Features

### BIOS Checker
- Extracts the BIOS reference list directly from your Retrobat installation (`batocera-systems.exe`)
- Verifies presence of all required BIOS files
- Checks MD5 hashes against expected values
- **Strict mode**: treats MD5 mismatches as errors (by default Retrobat only checks file presence)
- Detailed report with filtering by status (OK, missing, MD5 mismatch, no hash)
- Export results to CSV
- Grouping by system or by status

### Gamelist Scanner
- Scans all `gamelist.xml` files across your ROM folders
- Detects **missing ROMs** — referenced in the gamelist but absent on disk
- Detects **unscraped ROMs** — present on disk but not referenced in any gamelist, including systems with no gamelist at all
- Detects **games with no media** — in the gamelist but with no scraped images/videos
- Detects **missing media files** — referenced in the gamelist but absent on disk
- Detects **orphan media files** — present on disk but not referenced in any game
- Filter results by system
- Add missing media files directly from the UI
- Delete orphan media files directly from the UI (single or batch)
- Remove missing ROM entries from gamelist, with optional deletion of resulting orphan media files
- **PS3 support**: when deleting missing PS3/PSN ROMs, optionally also removes the corresponding RPCS3 game data folder (`saves\ps3\rpcs3\dev_hdd0\game\`), matched by game title via `PARAM.SFO` lookup
- ROM hash verification (MD5 / CRC32 / SHA1) against values stored in the gamelist
- Copy expected hash to clipboard on mismatch

### ScreenScraper Integration
- Scrape unscraped ROMs directly from the UI using [ScreenScraper](https://www.screenscraper.fr)
- Scrape games with no media
- Re-download missing media files for already scraped games
- Single or batch scraping with progress indicator and cancel button
- Automatically reads your scraping preferences from Retrobat (`es_settings.cfg`): image source, logo source, box source, language, region, and media options (videos, fanart, box back, manual, map, bezel)
- Respects your preferred language and region for metadata and media selection
- Language and region detection from ROM filename, consistent with Retrobat's behavior
- ROM identification uses MD5/CRC32/SHA1 hashes, extracted from inside ZIP archives when appropriate (consistent with Retrobat's behavior)
- Writes scraped data directly to `gamelist.xml` in Retrobat format
- Configurable scraping options via the Settings dialog

---

## Requirements

- Windows 10 / 11
- [Retrobat](https://www.retrobat.org/) installed
- PowerShell (for initial BIOS list extraction — included in Windows)
- A [ScreenScraper](https://www.screenscraper.fr) account (free) for scraping features

---

## ScreenScraper credentials

### Developer credentials
To build RetroFix from source, rename `screenscraper_credentials.inc.template`
to `screenscraper_credentials.inc` and fill in your developer credentials
from [screenscraper.fr](https://www.screenscraper.fr).

### User credentials
Your ScreenScraper username and password are automatically read from your Retrobat `es_settings.cfg` if available. Otherwise, RetroFix will prompt you on first launch, or you can enter them manually via the **Settings** dialog.

---

## Usage

1. Launch RetroFix
2. Select your Retrobat installation folder
3. Click **Scan BIOS** to verify your BIOS files
4. Click **Scan Gamelists** to analyze your game collection
5. Click **Details...** to open the detailed report for each module
6. Right-click on items in the **Unscraped**, **No media**, **Missing medias** or **Missing ROMs** tabs to take action

---

## Built with

- [Delphi 12](https://www.embarcadero.com/products/delphi) (VCL)
- [Neslib.Xml](https://github.com/neslib/Neslib.Xml) — fast XML parser (BSD license)

---

## License

MIT License — see [LICENSE](LICENSE) for details.
