# =============================================
# Utils.ps1 - Optemiz v2.1.0 (Son Versiyon)
# =============================================

$LogFolder = "$PSScriptRoot\..\Logs"
$BackupRoot = "$PSScriptRoot\..\Backups"

if (-not (Test-Path $LogFolder)) { New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null }
if (-not (Test-Path $BackupRoot)) { New-Item -Path $BackupRoot -ItemType Directory -Force | Out-Null }

$LogPath     = "$LogFolder\optimization.log"
$HtmlLogPath = "$LogFolder\optimization.html"
$RunID       = Get-Date -Format "yyyyMMdd_HHmmss"

# ====================== YENİ RAPOR BAŞLIĞI ======================
$HtmlHeader = @"
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>Optemiz v2.1.0 - Bakım Raporu</title>
    <style>
        body { font-family: 'Segoe UI', Consolas, monospace; background: #0f1620; color: #e0f0ff; margin: 20px; }
        h1 { color: #00ffaa; text-align: center; }
        .subtitle { text-align: center; color: #88ccff; margin-bottom: 20px; }
        table { width: 95%; margin: 20px auto; border-collapse: collapse; background: #1a2333; }
        th, td { padding: 12px 10px; text-align: left; border-bottom: 1px solid #334455; }
        th { background: #00aaff; color: #000; font-weight: bold; }
        tr:nth-child(even) { background: #162038; }
        .success { color: #00ff88; font-weight: bold; }
        .warning { color: #ffcc00; }
        .error { color: #ff6666; }
        .info { color: #66ddff; }
        .summary { background: #00aa66; color: #000; font-weight: bold; }
    </style>
</head>
<body>
    <h1>🚀 Optemiz v2.1.0 - Bakım Raporu</h1>
    <p class="subtitle">Çalıştırma ID: $RunID | Tarih: $(Get-Date -Format "dd MMMM yyyy HH:mm:ss")</p>
    <table>
        <tr>
            <th>Zaman</th>
            <th>Seviye</th>
            <th>Modül</th>
            <th>Mesaj</th>
        </tr>
"@

$HtmlHeader | Out-File -FilePath $HtmlLogPath -Encoding UTF8 -Force

function Write-Log {
    param([string]$Message, [string]$Level = "INFO", [string]$Module = "")

    $Time = Get-Date -Format "HH:mm:ss"
    $LogEntry = "[$Time] [$Level] $Module $Message"
    Add-Content -Path $LogPath -Value $LogEntry -Encoding UTF8 -Force

    $Class = switch ($Level) {
        "SUCCESS" { "success" }
        "WARNING" { "warning" }
        "ERROR"   { "error" }
        default   { "info" }
    }

    $HtmlLine = "<tr><td>$Time</td><td class='$Class'>$Level</td><td>$Module</td><td>$Message</td></tr>"
    $HtmlLine | Add-Content -Path $HtmlLogPath -Encoding UTF8 -Force

    switch ($Level) {
        "SUCCESS" { Write-Host "✓ $Module $Message" -ForegroundColor Green }
        "ERROR"   { Write-Host "✗ $Module $Message" -ForegroundColor Red }
        "WARNING" { Write-Host "! $Module $Message" -ForegroundColor Yellow }
        default   { Write-Host "→ $Module $Message" -ForegroundColor Cyan }
    }
}

function Backup-Registry {
    param([string]$ModuleName = "General")
    $Date = Get-Date -Format "yyyyMMdd_HHmm"
    $Path = "$BackupRoot\Registry_${ModuleName}_$Date.reg"
    try {
        reg export HKCU "$Path" /y | Out-Null
        Write-Log "Registry yedeği alındı" "SUCCESS" $ModuleName
        return $Path
    } catch {
        Write-Log "Registry yedeği alınamadı" "WARNING" $ModuleName
        return $null
    }
}

Write-Log "Optemiz v2.1.0 başarıyla başlatıldı" "SUCCESS"