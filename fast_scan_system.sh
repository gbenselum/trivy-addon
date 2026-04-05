#!/usr/bin/env bash
# Trivy Fast Scan - OS Only
# (c) 2026 Gabriel & Antigravity

set -euo pipefail

NAME="Trivy Scanner Fast"
DATE_LOG=$(date +%Y-%m-%d_%H-%M)
ABS_PATH=$(dirname "$(realpath "$0")")

mkdir -p "$ABS_PATH/reports"

echo "[FAST SCAN] Initiating OS-only vulnerability audit..."
echo "Target: Local Filesystem (/)"

# Run Trivy with --vuln-type os for maximum speed
# Added --no-progress for cleaner logs
trivy fs / \
    --scanners vuln \
    --vuln-type os \
    --severity CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN \
    --format json \
    --no-progress \
    --output "$ABS_PATH/reports/fast_scan_$DATE_LOG.json" 2>&1

# Symlink management (safe with set -e)
ln -sf "$ABS_PATH/reports/fast_scan_$DATE_LOG.json" "$ABS_PATH/reports/latest_results.json"
echo "[SUCCESS] Fast scan complete. Results: fast_scan_$DATE_LOG.json"
