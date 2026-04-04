# Trivy Security Dashboard for Cockpit
[![Version](https://img.shields.io/badge/version-3.0-blue.svg)](file:///home/gabriel/.local/share/cockpit/trivy-addon/version3)
[![Platform](https://img.shields.io/badge/platform-Debian%20/%20Ubuntu-orange.svg)](https://www.debian.org/)

A professional, native security scanner addon for [Cockpit](https://cockpit-project.org/). This tool integrates the powerful **Trivy** vulnerability scanner directly into your server management interface, providing real-time audits, historical reporting, and interactive remediation.

---

## 🚀 Key Features
- **Native Overview UI**: Seamlessly integrated with Cockpit's PatternFly 5 design system.
- **Dual-Speed Auditing**: 
    - **Fast Scan**: 5-second OS-only vulnerability audit.
    - **Full Scan**: Deep-dive audit of all system and application packages.
- **Interactive Filtering**: One-click "Traffic Light" cards to drill down into Critical, High, and Medium threats.
- **Smart Remediation Engine**: Automatically synthesizes `apt`, `dnf`, or `npm` repair commands for detected vulnerabilities.
- **Integrated History**: Native header dropdown to switch between all past scan reports.
- **TrivyTerminal**: Real-time log streaming of the scanner's output.

---

## 🛠️ Requirements
The addon is designed for **Debian-based** systems (Ubuntu, Pop!_OS, Debian, etc.).

### 1. Prerequisites
Ensure the following packages are installed on your host:
- **Cockpit**: `sudo apt install cockpit`
- **JQ**: `sudo apt install jq` (Used for JSON processing)
- **Trivy**: [Official Installation Guide](https://aquasecurity.github.io/trivy/v0.18.3/getting-started/installation/)
  ```bash
  wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
  sudo apt update && sudo apt install trivy
  ```

---

## 📦 Installation
1. Create the local cockpit addon directory:
   ```bash
   mkdir -p ~/.local/share/cockpit/
   ```
2. Clone or copy this repository into the folder:
   ```bash
   cp -r trivy-addon ~/.local/share/cockpit/
   ```
3. Refresh your Cockpit interface. The **"Trivy Scanner"** menu will appear under the Tools section.

---

## 📖 Usage
- **Running a Scan**: Click "Fast Scan" for a quick OS check or "Full Scan" for a comprehensive audit.
- **Filtering Results**: Click the colored severity cards (Critical, High, etc.) to instantly filter the vulnerability list below.
- **Remediating**: Copy the synthesized "Fix Command" from any vulnerability card and run it in the Cockpit Terminal to repair the package.
- **Reviewing History**: Use the dropdown in the top header to load and compare previous scan results.

---

## 🧪 Security & Permissions
The addon requires `superuser` permissions to perform the file system scan. It communicates with the host via the standard Cockpit bridge (`cockpit.js`). All reports are stored locally within the addon's `reports/` folder for maximum portability and security.

---
## 🏆 Attribution & Derivative Work
This project is an independent extension of the **[Cockpit Project](https://cockpit-project.org/)**. It leverages the following technologies and standards:
- **Cockpit Native Bridge**: For secure, high-performance communication with the host filesystem.
- **PatternFly 5**: The design system that provides the addon's professional and integrated look.
- **Trivy by [Aqua Security](https://aquasecurity.github.io/trivy/)**: The core scanning engine that powers the vulnerability audits.
- **Antigravity AI (Google Deepmind)**: The engineering assistant that participated in the architecture and development of this V3 release.

---
**Maintained by**: Gabriel  
**Engineered with**: Antigravity AI  
**License**: [LGPL-2.1](file:///home/gabriel/.local/share/cockpit/trivy-addon/LICENSE)
