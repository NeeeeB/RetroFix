# RetroFix 🎮

**Fix your game collection for Retrobat**

RetroFix is a utility for [Retrobat](https://www.retrobat.org/) that scans your installation and helps you identify and fix issues in your game collection — missing BIOS files, unscraped ROMs, missing or orphaned media files, and more.

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
- Detects **unscraped ROMs** — present on disk but not referenced in any gamelist
- Detects **games with no media** — in the gamelist but with no scraped images/videos
- Detects **missing media files** — referenced in the gamelist but absent on disk
- Detects **orphan media files** — present on disk but not referenced in any game
- Filter results by system
- Add missing media files directly from the UI
- Delete orphan media files directly from the UI
- ROM hash verification (MD5 / CRC32) against values stored in the gamelist

---

## Requirements

- Windows 10 / 11
- [Retrobat](https://www.retrobat.org/) installed
- PowerShell (for initial BIOS list extraction — included in Windows)

---

## ScreenScraper credentials

To use the scraping features, rename `screenscraper_credentials.inc.template` 
to `screenscraper_credentials.inc` and fill in your developer credentials 
from [screenscraper.fr](https://www.screenscraper.fr).

---

## Usage

1. Launch RetroFix
2. Select your Retrobat installation folder
3. Click **Scan BIOS** to verify your BIOS files
4. Click **Scan Gamelists** to analyze your game collection
5. Click **Details...** to open the detailed report for each module

---

## Built with

- [Delphi 12](https://www.embarcadero.com/products/delphi) (VCL)

---

## License

MIT License — see [LICENSE](LICENSE) for details.
