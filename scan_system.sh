#!/bin/bash
set -euo pipefail

# --- CONFIGURATION ---
# Script-local storage instead of /var/lib for better portability
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="${SCRIPT_DIR}/reports"
LOG_FILE="${REPORT_DIR}/trivy-scan.log"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
REPORT_FILE="${REPORT_DIR}/scan_${TIMESTAMP}.json"

# --- PRE-FLIGHT ---
# Create reports directory in the addon folder if it doesn't exist
if [ ! -d "$REPORT_DIR" ]; then
    mkdir -p "$REPORT_DIR"
    chmod 755 "$REPORT_DIR"
fi

# Setup logging
exec > >(tee -a "$LOG_FILE") 2>&1

echo "--- SCAN STARTED AT $(date) ---"
echo "[+] Base Directory: $SCRIPT_DIR"
echo "[+] Output Format: JSON"
echo "[+] Destination: $REPORT_FILE"

# --- PRE-FLIGHT CHECK ---
if ! command -v trivy &> /dev/null; then
    echo "[ERROR] Trivy is not installed or not in PATH."
    exit 1
fi

# --- SCAN EXECUTION ---
echo "[+] Starting Trivy Engine (Estimated time: up to 30 minutes)..."

# Note: We now output JSON so the UI can render it natively.
trivy fs \
  --severity HIGH,CRITICAL \
  --format json \
  --output "$REPORT_FILE" \
  --timeout 30m \
  /

# --- FINALIZING ---
if [ $? -eq 0 ]; then
    echo "[SUCCESS] Scan finished successfully."
    chmod 644 "$REPORT_FILE"
    # Create the 'latest' symlink (ending in .json for the UI to fetch)
    ln -sf "$REPORT_FILE" "${REPORT_DIR}/latest_results.json"
    chmod 644 "${REPORT_DIR}/latest_results.json"
    echo "[+] Report generated: $(basename "$REPORT_FILE")"
else
    echo "[ERROR] Trivy encountered an issue during the scan."
    exit 1
fi

echo "--- SCAN FINISHED AT $(date) ---"
