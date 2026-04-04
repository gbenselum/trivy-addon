# Trivy Cockpit Addon Documentation

This document provides a comprehensive overview of the Trivy Cockpit Addon, its self-contained architecture, and maintenance procedures.

## Overview
The Trivy Cockpit Addon provides a high-performance, native interface for the [Trivy](https://github.com/aquasecurity/trivy) security scanner. It allows administrators to run full filesystem audits directly from the Cockpit shell, featuring a modern "Traffic Light" dashboard and real-time log streaming.

## Architecture (Ultra-Stable Native)

### Frontend (`index.html` & `index.js`)
- **Technology**: Vanilla JavaScript (ES6+), PatternFly 5, and Custom CSS.
- **Native Dashboard**: Unlike earlier versions that used iframes, the UI now parses raw **JSON** results and renders a rich, theme-aware dashboard directly in the Cockpit viewport.
- **One-Time Initialization**: Uses a `cockpit.transport.wait(init)` guard to prevent redundant event listeners and bridge crashes.
- **Portability**: Uses a local `reports/` directory and dynamic script discovery to remain 100% self-contained.

### Backend (`scan_system.sh`)
- **Technology**: Bash (optimized for portability).
- **Scanning Engine**: Trivy (Filesystem scan).
- **Output Format**: **JSON** (for the Native Dashboard).
- **Automation**: Automatically manages report rotation and creates `latest_results.json` symlinks.
- **Permissions**: Runs with elevated privileges via Cockpit's `superuser: require`.

### Styling (`index.css`)
- **Design System**: A custom-built PatternFly 5 implementation that supports both Light and Dark modes.
- **Performance**: All styles are externalized for browser caching and strict Content Security Policy (CSP) compliance.

## Data Management (Self-Contained)

All data is now stored within the addon's own directory for maximum portability and security.

| Resource | Path | Description |
| --- | --- | --- |
| **Reports Directory** | `reports/` | Local storage for all scan results and logs. |
| **JSON Reports** | `reports/scan_YYYY-MM-DD_HH-MM.json` | The primary data source for the Native Dashboard. |
| **Latest Results** | `reports/latest_results.json` | Symlink to the most recent successful JSON scan. |
| **Legacy Reports** | `reports/scan_*.html` | Historical HTML reports (viewable in "Legacy" mode). |
| **System Logs** | `reports/trivy-scan.log` | Persistent real-time log of the scanner engine. |

## Installation & Usage

1. **Prerequisites**: Install `trivy` on the host system.
2. **Installation**: Place the `trivy-addon` directory in `~/.local/share/cockpit/` (User level) or `/usr/share/cockpit/` (System level).
3. **Usage**:
   - Navigate to the **Security Scans** menu.
   - Click **Run Full Scan**. A log panel will automatically slide up to show progress.
   - Once finished, the **Traffic Light** dashboard will update automatically.
   - Browse previous results in the **Recent Reports** sidebar, which are sorted by date.

## Developer Notes

### The "Clean Slate" Sidebar Logic
The sidebar discovery uses a deterministic approach based on filenames to ensure perfect sorting:
```javascript
cockpit.file("reports").readdir()
    .then(files => {
        const reports = files.filter(f => f.name.startsWith('scan_'))
                             .sort((a, b) => b.name.localeCompare(a.name));
        // ... rendering logic ...
    });
```

### Self-Contained Pathing
To maintain zero-dependency on system paths like `/var/lib`, the script calculates its location dynamically:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="${SCRIPT_DIR}/reports"
```

### Troubleshooting "Internal Errors"
If Cockpit shows an "Unexpected internal error", verify that `index.js` is correctly linked and that `cockpit.js` is loaded at the start of `index.html`. The current architecture uses a `initialized` flag to prevent bridge sync collisions.
