{{- /* modern2-dark.tpl - DASHBOARD CLEAN - NO EXTERNAL SCRIPTS */ -}}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Trivy Security Dashboard - Dark Mode</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap');
        
        :root {
            --bg: #0f172a;
            --card-bg: #1e293b;
            --text-primary: #f1f5f9;
            --text-secondary: #94a3b8;
            --border: #334155;
            --blue: #3b82f6;
            --red: #ef4444;
            --orange: #f97316;
            --amber: #f59e0b;
            --green: #10b981;
        }

        body { 
            font-family: 'Inter', -apple-system, sans-serif; 
            background-color: var(--bg); 
            color: var(--text-primary); 
            margin: 0; padding: 24px;
            line-height: 1.5;
        }

        .container { max-width: 1200px; margin: 0 auto; }

        header {
            display: flex; justify-content: space-between; align-items: center;
            background-color: var(--card-bg);
            padding: 24px; border-radius: 12px; margin-bottom: 32px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            border: 1px solid var(--border);
        }

        h1 { margin: 0; font-size: 24px; font-weight: 700; color: #fff; }
        .subtitle { font-size: 14px; color: var(--text-secondary); margin-top: 4px; }
        .date-badge { 
            background-color: rgba(59, 130, 246, 0.2); 
            color: #60a5fa; padding: 4px 12px; border-radius: 99px;
            font-size: 11px; font-weight: 600; text-transform: uppercase;
        }

        .section-title { font-size: 18px; font-weight: 600; margin-bottom: 16px; color: #cbd5e1; }

        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 16px; margin-bottom: 32px; }

        .stat-card {
            background-color: var(--card-bg);
            padding: 16px; border-radius: 12px;
            border-top: 4px solid var(--green);
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border-right: 1px solid var(--border);
            border-bottom: 1px solid var(--border);
            border-left: 1px solid var(--border);
        }
        .stat-card.has-issues { border-top-color: var(--red); }
        .stat-target { font-size: 10px; font-weight: 700; text-transform: uppercase; color: var(--text-secondary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .stat-count { font-size: 18px; font-weight: 700; margin: 4px 0; }
        .stat-type { font-size: 11px; color: var(--text-secondary); }

        .details-list { display: flex; flex-direction: column; gap: 24px; }

        .vuln-card {
            background-color: var(--card-bg); border-radius: 12px; padding: 24px;
            border-left: 6px solid var(--border);
            border-top: 1px solid var(--border);
            border-right: 1px solid var(--border);
            border-bottom: 1px solid var(--border);
        }
        .severity-CRITICAL { border-left-color: var(--red); }
        .severity-HIGH { border-left-color: var(--orange); }
        .severity-MEDIUM { border-left-color: var(--amber); }
        .severity-LOW { border-left-color: var(--green); }

        .vuln-header { display: flex; justify-content: space-between; align-items: start; }
        .badge { font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 4px; display: inline-block; margin-bottom: 8px; }
        .badge-CRITICAL { background: rgba(239, 68, 68, 0.2); color: #f87171; }
        .badge-HIGH { background: rgba(249, 115, 22, 0.2); color: #fb923c; }
        .badge-MEDIUM { background: rgba(245, 158, 11, 0.2); color: #fbbf24; }
        .badge-LOW { background: rgba(16, 185, 129, 0.2); color: #34d399; }

        .vuln-title { font-size: 18px; font-weight: 700; margin: 0; color: #fff; }
        .vuln-subtitle { font-size: 14px; color: var(--text-secondary); margin-top: 4px; }
        .version-tag { font-family: monospace; background: #0f172a; padding: 2px 6px; border-radius: 4px; color: #e2e8f0; }

        .vuln-desc { background: #0f172a; padding: 12px; border-radius: 8px; font-size: 13px; color: #cbd5e1; margin-top: 16px; font-style: italic; }

        .cmd-box { background: #000; padding: 16px; border-radius: 8px; margin-top: 16px; }
        .cmd-label { font-size: 10px; font-weight: 700; color: #475569; text-transform: uppercase; display: flex; align-items: center; margin-bottom: 8px; }
        .cmd-text { font-family: monospace; font-size: 13px; color: #10b981; }

        a { color: var(--blue); text-decoration: none; font-size: 14px; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div>
                <h1>System Vulnerability Report</h1>
                <div class="subtitle">Target: {{ (index . 0).Target }}</div>
            </div>
            <div class="date-badge">Scan Date: {{ now | date "2006-01-02 15:04" }}</div>
        </header>

        <div class="section-title">Scan Targets & Findings</div>
        <div class="grid">
            {{- range . }}
            <div class="stat-card {{ if .Vulnerabilities }}has-issues{{ end }}">
                <div class="stat-target" title="{{ .Target }}">{{ .Target }}</div>
                <div class="stat-count">{{ len .Vulnerabilities }} Issues Found</div>
                <div class="stat-type">Manager: {{ .Type | default "System File" }}</div>
            </div>
            {{- end }}
        </div>

        <div class="section-title">Vulnerability Details & Remediation</div>
        <div class="details-list">
            {{- range . }}
                {{- $targetType := .Type -}}
                {{- range .Vulnerabilities }}
                <div class="vuln-card severity-{{ .Severity }}">
                    <div class="vuln-header">
                        <div>
                            <div class="badge badge-{{ .Severity }}">{{ .Severity }}</div>
                            <div class="vuln-title">{{ .PkgName }} | {{ .VulnerabilityID }}</div>
                            <div class="vuln-subtitle">
                                Installed: <span class="version-tag">{{ .InstalledVersion }}</span> 
                                {{ if .FixedVersion }}| <span style="color:var(--green)">Fixed in: {{ .FixedVersion }}</span>{{ end }}
                            </div>
                        </div>
                        {{ if .PrimaryURL }}
                        <a href="{{ .PrimaryURL }}" target="_blank">View CVE Details ↗</a>
                        {{ end }}
                    </div>

                    <div class="vuln-desc">
                        {{ .Title | default "No detailed description available." }}
                    </div>

                    <div class="cmd-box">
                        <div class="cmd-label">Run to Fix</div>
                        <div class="cmd-text">
                            {{- if eq $targetType "debian" -}}
                                sudo apt-get install --only-upgrade {{ .PkgName }}
                            {{- else if eq $targetType $targetType -}}
                                {{- if eq $targetType "npm" -}}
                                    npm install {{ .PkgName }}@{{ .FixedVersion }}
                                {{- else if eq $targetType "pip" -}}
                                    pip install --upgrade {{ .PkgName }}=={{ .FixedVersion }}
                                {{- else if eq $targetType "bun" -}}
                                    bun add {{ .PkgName }}@{{ .FixedVersion }}
                                {{- else if eq $targetType "gomod" -}}
                                    go get {{ .PkgName }}@{{ .FixedVersion }}
                                {{- else -}}
                                    # Manual update: {{ .PkgName }} to {{ .FixedVersion }}
                                {{- end -}}
                            {{- end -}}
                        </div>
                    </div>
                </div>
                {{- end }}
            {{- end }}
        </div>
    </div>
</body>
</html>
