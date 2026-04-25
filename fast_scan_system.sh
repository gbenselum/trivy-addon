#!/usr/bin/env bash
set -euo pipefail
# Trivy Fast Scan - OS Only
# (c) 2026 Gabriel & Antigravity

NAME="Trivy Scanner Fast"
DATE_LOG=$(date +%Y-%m-%d_%H-%M)
ABS_PATH=$(dirname "$(realpath "$0")")

# --- PRE-FLIGHT ---
# Ensure Trivy is installed
if ! command -v trivy &> /dev/null; then
    echo "[ERROR] Trivy binary not found in PATH."
    exit 1
fi

mkdir -p "$ABS_PATH/reports"

echo "[FAST SCAN] Initiating OS-only vulnerability audit..."
echo "Target: Local Filesystem (/)"

# Run Trivy with --vuln-type os for maximum speed
trivy fs / \
    --scanners vuln \
    --vuln-type os \
    --severity CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN \
    --format json \
    --output "$ABS_PATH/reports/fast_scan_$DATE_LOG.json" 2>&1

if [ $? -eq 0 ]; then
    ln -sf "$ABS_PATH/reports/fast_scan_$DATE_LOG.json" "$ABS_PATH/reports/latest_results.json"
    echo "[SUCCESS] Fast scan complete. Results: fast_scan_$DATE_LOG.json"
else
    echo "[ERROR] Trivy fast scan encountered an issue."
    exit 1
fi
