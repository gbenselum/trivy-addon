/* 
   Trivy Scanner - Stable Logic (RESTORED)
   Restored to external file for CSP compliance.
*/

let isRunning = false;
let initialized = false;
let currentData = null; 
let activeFilter = null; 
let absRoot = ""; 
let absReports = ""; 

const getEl = (id) => document.getElementById(id);

function discoverPaths() {
    return cockpit.script("find /usr/share/cockpit ~/.local/share/cockpit -maxdepth 2 -name scan_system.sh -print -quit 2>/dev/null")
        .then(path => {
            const fullPath = path.trim();
            if (!fullPath) return; // Fallback
            absRoot = fullPath.substring(0, fullPath.lastIndexOf('/'));
            absReports = absRoot + "/reports";
            console.log("Absolute paths discovered:", absRoot);
        });
}

function updateReportList() {
    const sel = getEl('report-selector');
    if (!sel || !absReports) return;

    return cockpit.script(`ls -1 ${absReports} 2>/dev/null`)
        .then(content => {
            const files = content.trim().split('\n').filter(f => f.startsWith('scan_'));
            sel.innerHTML = '<option value="">Load History...</option>';
            files.forEach(filename => {
                const opt = document.createElement('option');
                opt.value = filename;
                opt.textContent = filename;
                sel.appendChild(opt);
            });
        })
        .catch(err => console.error("Dropdown failed:", err));
}

function showReport(filename) {
    if (!filename || !absReports) return;
    return cockpit.file(`${absReports}/${filename}`).read()
        .then(content => {
            if (!content) return;
            currentData = JSON.parse(content);
            activeFilter = null; 
            renderDashboard(currentData);
        })
        .catch(err => console.error("Load failed:", err));
}

function setFilter(severity) {
    if (activeFilter === severity) activeFilter = null;
    else activeFilter = severity;
    ['critical', 'high', 'medium', 'low', 'unknown'].forEach(s => {
        getEl(`card-${s}`).classList.toggle('active-filter', activeFilter === s.toUpperCase());
    });
    if (currentData) renderDashboard(currentData);
}

function getFixCommand(v, dsName) {
    if (!v.FixedVersion) return "Manual review required";
    const pkg = v.PkgName;
    const ver = v.FixedVersion;
    const ds = (dsName || '').toLowerCase();
    if (ds.includes('debian') || ds.includes('ubuntu') || ds.includes('apt')) return `sudo apt install ${pkg}=${ver}`;
    if (ds.includes('redhat') || ds.includes('alma') || ds.includes('dnf') || ds.includes('yum')) return `sudo dnf update ${pkg}-${ver}`;
    if (ds.includes('npm')) return `npm install ${pkg}@${ver}`;
    if (ds.includes('pypi') || ds.includes('python')) return `pip install ${pkg}==${ver}`;
    if (ds.includes('rubygems')) return `gem install ${pkg}:${ver}`;
    return `Update ${pkg} to ${ver}`;
}

function renderDashboard(data) {
    try {
        getEl('empty-state').style.display = 'none';
        getEl('dashboard-summary').style.display = 'grid'; // Force grid
        getEl('dashboard-results').style.display = 'block';
        let counts = { CRITICAL: 0, HIGH: 0, MEDIUM: 0, LOW: 0, UNKNOWN: 0 };
        let html = '';
        if (data.Results) {
            data.Results.forEach(target => {
                const dsName = (target.Vulnerabilities && target.Vulnerabilities[0] && target.Vulnerabilities[0].DataSource) 
                               ? target.Vulnerabilities[0].DataSource.Name : "Generic";
                if (target.Vulnerabilities) {
                    target.Vulnerabilities.forEach(v => {
                        const sev = (v.Severity || 'UNKNOWN').toUpperCase();
                        if (counts.hasOwnProperty(sev)) counts[sev]++;
                        else counts.UNKNOWN++;
                        if (activeFilter && activeFilter !== sev) return;
                        const fixCmd = getFixCommand(v, dsName);
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
                                    <div class="remediation-label">Remediation / Fix Command</div>
                                    <div class="remediation-cmd">${fixCmd}</div>
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
    } catch (e) { console.error("Render crashed:", e); }
}

function renderLegacyReport(filename) {
    getEl('empty-state').style.display = 'none';
    getEl('dashboard-summary').style.display = 'none';
    getEl('dashboard-results').style.display = 'block';
    getEl('dashboard-results').innerHTML = `<div style="padding:40px; text-align:center;"><h3 style="color:#eee;">Legacy Report: ${filename}</h3></div>`;
}

function runScan() {
    if (isRunning || !absRoot) return;
    isRunning = true;
    getEl('btn-run').disabled = true;
    getEl('status-label').innerHTML = '<span class="spinner">&circlearrowright;</span> Scanning...';
    getEl('log-panel').classList.add('expanded');
    cockpit.spawn(["/usr/bin/bash", absRoot + "/scan_system.sh"], { superuser: "require", err: "out" })
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
        .fail(() => {
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
    const sel = getEl('report-selector');
    if (sel) sel.onchange = (e) => { if (e.target.value) showReport(e.target.value); };
    ['critical', 'high', 'medium', 'low', 'unknown'].forEach(sev => {
        const card = getEl(`card-${sev}`);
        if (card) card.onclick = () => setFilter(sev.toUpperCase());
    });
    
    discoverPaths().then(() => {
        updateReportList();
        showReport('latest_results.json').catch(() => {});
    }).catch(err => console.error("Discovery Error:", err));
}

cockpit.transport.wait(init);
