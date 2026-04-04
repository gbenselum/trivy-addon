{{- /* modern.tpl - SonarQube-inspired Dashboard with Actionable Remediation */ -}}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Trivy Security Dashboard - Pop!_OS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap');
        body { font-family: 'Inter', sans-serif; background-color: #f3f4f6; }
        .severity-CRITICAL { border-left: 6px solid #dc2626; }
        .severity-HIGH { border-left: 6px solid #ea580c; }
        .severity-MEDIUM { border-left: 6px solid #d97706; }
        .severity-LOW { border-left: 6px solid #16a34a; }
    </style>
</head>
<body class="p-6">
    <div class="max-w-6xl mx-auto">
        <header class="flex justify-between items-center mb-8 bg-white p-6 rounded-xl shadow-sm">
            <div>
                <h1 class="text-2xl font-bold text-gray-800">System Vulnerability Report</h1>
                <p class="text-gray-500 text-sm"><i class="fa-solid fa-laptop mr-2"></i>{{ (index . 0).Target }}</p>
            </div>
            <div class="text-right">
                <span class="bg-blue-100 text-blue-800 text-xs font-semibold px-3 py-1 rounded-full uppercase tracking-wider">
                    Scan Date: {{ now | date "2006-01-02 15:04" }}
                </span>
            </div>
        </header>

        <h2 class="text-xl font-semibold mb-4 text-gray-700">Scan Targets & Findings</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
            {{- range . }}
            <div class="bg-white p-4 rounded-xl shadow-sm border-t-4 {{ if .Vulnerabilities }}border-red-500{{ else }}border-green-500{{ end }}">
                <p class="text-gray-400 text-[10px] font-bold uppercase truncate" title="{{ .Target }}">{{ .Target }}</p>
                <p class="text-lg font-bold text-gray-700">{{ len .Vulnerabilities }} Issues Found</p>
                <p class="text-xs text-gray-500 capitalize">Manager: {{ .Type | default "System File" }}</p>
            </div>
            {{- end }}
        </div>

        <h2 class="text-xl font-semibold mb-4 text-gray-700">Vulnerability Details & Remediation</h2>
        <div class="space-y-6">
            {{- range . }}
                {{- $targetType := .Type -}} {{/* Capture Target Type context */}}
                {{- range .Vulnerabilities }}
                <div class="bg-white rounded-xl shadow-sm p-6 severity-{{ .Severity }}">
                    <div class="flex justify-between items-start">
                        <div>
                            <span class="px-2 py-0.5 rounded text-[10px] font-bold 
                                {{ if eq .Severity "CRITICAL" }}bg-red-100 text-red-700{{ end }}
                                {{ if eq .Severity "HIGH" }}bg-orange-100 text-orange-700{{ end }}
                                {{ if eq .Severity "MEDIUM" }}bg-amber-100 text-amber-700{{ end }}
                                {{ if eq .Severity "LOW" }}bg-green-100 text-green-700{{ end }}">
                                {{ .Severity }}
                            </span>
                            <h3 class="text-lg font-bold mt-2 text-gray-900">{{ .PkgName }} <span class="text-gray-400 font-normal">|</span> {{ .VulnerabilityID }}</h3>
                            <p class="text-gray-600 text-sm mt-1">
                                Installed: <span class="font-mono bg-gray-100 px-1 rounded">{{ .InstalledVersion }}</span> 
                                {{ if .FixedVersion }}| <span class="text-green-600 font-semibold text-xs">Fixed in: {{ .FixedVersion }}</span>{{ end }}
                            </p>
                        </div>
                        {{ if .PrimaryURL }}
                        <a href="{{ .PrimaryURL }}" target="_blank" class="text-blue-600 hover:text-blue-800 text-sm font-medium transition-colors">
                            View CVE Details <i class="fa-solid fa-external-link ml-1 text-[10px]"></i>
                        </a>
                        {{ end }}
                    </div>

                    <div class="mt-4 p-3 bg-gray-50 rounded text-xs text-gray-600 italic leading-relaxed">
                        {{ .Title | default "No detailed description available." }}
                    </div>

                    <div class="mt-4 p-4 bg-slate-900 rounded-lg shadow-inner">
                        <p class="text-[10px] font-bold uppercase text-slate-400 mb-2 flex items-center">
                            <i class="fa-solid fa-terminal mr-2"></i>Run to Fix
                        </p>
                        <code class="text-xs font-mono text-emerald-400 break-all">
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
                                    # Manual update required: {{ .PkgName }} to {{ .FixedVersion }}
                                {{- end -}}
                            {{- end -}}
                        </code>
                    </div>
                </div>
                {{- end }}
            {{- end }}
        </div>
    </div>
</body>
</html>
