/* 
   Trivy Scanner - Stable Logic (RESTORED)
   Restored to external file for CSP compliance.
*/

let REPORT_DIR_ABS = null; 
let scanPathAbs = null;
let isRunning = false;
let initialized = false;

const getEl = (id) => document.getElementById(id);

function parseScanDate(filename) {
    const match = filename.match(/scan_(\d{4})-(\d{2})-(\d{2})_(\d{2})-(\d{2})/);
    return match ? `${match[1]}-${match[2]}-${match[3]} ${match[4]}:${match[5]}` : filename;
}

function discoverPaths() {
    return cockpit.script("find /usr/share/cockpit ~/.local/share/cockpit -maxdepth 2 -name scan_system.sh -print -quit 2>/dev/null")
        .then(path => {
            const fullPath = path.trim();
            if (!fullPath) throw new Error("Addon directory not found");
            scanPathAbs = fullPath;
            REPORT_DIR_ABS = fullPath.substring(0, fullPath.lastIndexOf('/')) + "/reports";
            console.log("Addon Root discovered:", REPORT_DIR_ABS);
            return REPORT_DIR_ABS;
        });
}

function updateReportList() {
    // Sidebar removed in Native Overview layout
    return;
}

function showReport(filename) {
    if (!REPORT_DIR_ABS) return;
    return cockpit.file(`${REPORT_DIR_ABS}/${filename}`).read()
        .then(content => {
            if (!content) return;
            if (filename.endsWith('.json')) {
                renderDashboard(JSON.parse(content));
            } else {
                renderLegacyReport(filename);
            }
            document.querySelectorAll('.report-link').forEach(el => {
                el.classList.toggle('active', el.innerText.includes(parseScanDate(filename)));
            });
        })
        .catch(err => console.error("Load failed:", err));
}

function renderDashboard(data) {
    try {
        getEl('empty-state').style.display = 'none';
        getEl('dashboard-summary').style.display = 'flex';
        getEl('dashboard-results').style.display = 'block';
        
        let counts = { CRITICAL: 0, HIGH: 0, MEDIUM: 0, LOW: 0, UNKNOWN: 0 };
        let html = '';

        if (data.Results) {
            data.Results.forEach(target => {
                if (target.Vulnerabilities) {
                    target.Vulnerabilities.forEach(v => {
                        const sev = (v.Severity || 'UNKNOWN').toUpperCase();
                        if (counts.hasOwnProperty(sev)) counts[sev]++;
                        else counts.UNKNOWN++;

                        html += `
                            <div class="vuln-item">
                                <div class="vuln-header-row">
                                    <div>
                                        <span class="vuln-badge badge-${sev.toLowerCase()}">${sev}</span>
                                        <div class="vuln-pkg">${v.PkgName}</div>
                                        <div class="vuln-id" style="font-size:11px; color:var(--text-muted); font-family:monospace;">${v.VulnerabilityID}</div>
                                    </div>
                                    <div style="font-size:12px; color:var(--text-muted)">Installed: ${v.InstalledVersion}</div>
                                </div>
                                <div class="vuln-desc-text">${v.Title || 'No description available.'}</div>
                                <div class="remediation-box">
                                    <div class="remediation-label">Remediation / Fix</div>
                                    <div class="remediation-cmd">${v.FixedVersion ? 'Update to version ' + v.FixedVersion : 'Manual check required'}</div>
                                </div>
                            </div>
                        `;
                    });
                }
            });
        }

        getEl('count-critical').textContent = counts.CRITICAL;
        getEl('count-high').textContent = counts.HIGH;
        getEl('count-medium').textContent = counts.MEDIUM;
        getEl('count-low').textContent = counts.LOW;
        getEl('count-unknown').textContent = counts.UNKNOWN;
        
        getEl('dashboard-results').innerHTML = html || '<div style="text-align:center; padding:40px; color:#555;">No vulnerabilities found. Perfect!</div>';
    } catch (e) {
        console.error("Render crashed:", e);
    }
}

function renderLegacyReport(filename) {
    getEl('empty-state').style.display = 'none';
    getEl('dashboard-summary').style.display = 'none';
    getEl('dashboard-results').style.display = 'block';
    getEl('dashboard-results').innerHTML = `<div style="padding:40px; text-align:center;"><h3 style="color:#eee;">Legacy Report: ${filename}</h3></div>`;
}

function runScan() {
    if (isRunning || !scanPathAbs) return;
    isRunning = true;
    getEl('btn-run').disabled = true;
    getEl('status-label').innerHTML = '<span class="spinner">&circlearrowright;</span> Scanning...';
    getEl('log-panel').classList.add('expanded');
    
    cockpit.spawn(["/usr/bin/bash", scanPathAbs], { superuser: "require", err: "out" })
        .stream(data => {
            const out = getEl('log-output');
            if (out) { out.textContent += data; out.scrollTop = out.scrollHeight; }
        })
        .done(() => {
            isRunning = false;
            getEl('btn-run').disabled = false;
            getEl('status-label').textContent = "Last Scan: Success";
            updateReportList();
            showReport('latest_results.json');
        })
        .fail(err => {
            isRunning = false;
            getEl('btn-run').disabled = false;
            getEl('status-label').textContent = "Scan Failed";
        });
}

function init() {
    if (initialized) return;
    initialized = true;

    getEl('btn-run').addEventListener('click', runScan);
    getEl('btn-logs').addEventListener('click', () => getEl('log-panel').classList.toggle('expanded'));
    getEl('btn-close-logs').addEventListener('click', () => getEl('log-panel').classList.remove('expanded'));

    discoverPaths().then(() => {
        // Sidebar removed, just load latest
        showReport('latest_results.json').catch(() => {});
    }).catch(err => console.error("Init Error:", err));
}

// Cockpit standard onready
cockpit.transport.wait(init);
