# =============================================
# Utils.ps1 - Optemiz v2.1.3 (Geliştirilmiş - FINAL)
# Admin kontrol, error handling, merkezi menü
# =============================================

$LogFolder = "$PSScriptRoot\..\Logs"
$BackupRoot = "$PSScriptRoot\..\Backups"

if (-not (Test-Path $LogFolder)) { New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null }
if (-not (Test-Path $BackupRoot)) { New-Item -Path $BackupRoot -ItemType Directory -Force | Out-Null }

$LogPath     = "$LogFolder\optimization.log"
$HtmlLogPath = "$LogFolder\optimization.html"
$RunID       = Get-Date -Format "yyyyMMdd_HHmmss"

# ====================== ADMIN KONTROL ======================
function Test-AdminRights {
    <#
    .SYNOPSIS
    Scriptin yönetici (Administrator) yetkisiyle çalışıp çalışmadığını kontrol eder
    
    .RETURNS
    $true veya $false
    #>
    try {
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        return $isAdmin
    } catch {
        return $false
    }
}

# Admin yoksa programı durdur
if (-not (Test-AdminRights)) {
    Write-Host "`n❌ HATA: Bu script Yönetici (Administrator) yetkisiyle çalıştırılmalıdır!" -ForegroundColor Red
    Write-Host "   Lütfen Start-Optemiz.bat dosyasını 'Yönetici olarak çalıştır' seçeneğiyle açın." -ForegroundColor Yellow
    Write-Host "`n   veya PowerShell'i Yönetici modunda açıp, şunu yazın:" -ForegroundColor Cyan
    Write-Host "   powershell -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -ForegroundColor Gray
    Start-Sleep -Seconds 3
    exit 1
}

# ====================== YENİ RAPOR BAŞLIĞI ======================
$HtmlHeader = @"
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>Optemiz v2.1.3 - Bakım Raporu</title>
    <style>
        body { font-family: 'Segoe UI', Consolas, monospace; background: #0f1620; color: #e0f0ff; margin: 20px; }
        h1 { color: #00ffaa; text-align: center; }
        h2 { color: #00ddff; margin-top: 30px; border-bottom: 2px solid #00ddff; padding-bottom: 10px; }
        .subtitle { text-align: center; color: #88ccff; margin-bottom: 20px; }
        .summary-box { background: #162050; border-left: 4px solid #00ffaa; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .summary-box .label { color: #88ccff; font-weight: bold; }
        .summary-box .value { color: #00ffaa; font-size: 1.2em; }
        table { width: 95%; margin: 20px auto; border-collapse: collapse; background: #1a2333; }
        th, td { padding: 12px 10px; text-align: left; border-bottom: 1px solid #334455; }
        th { background: #00aaff; color: #000; font-weight: bold; }
        tr:nth-child(even) { background: #162038; }
        .success { color: #00ff88; font-weight: bold; }
        .warning { color: #ffcc00; }
        .error { color: #ff6666; }
        .info { color: #66ddff; }
        .footer { text-align: center; margin-top: 40px; color: #666; font-size: 12px; border-top: 1px solid #334455; padding-top: 20px; }
    </style>
</head>
<body>
    <h1>🚀 Optemiz v2.1.3 - Bakım Raporu</h1>
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

# ====================== GELIŞTIRILMIŞ LOGGING ======================
function Write-Log {
    <#
    .SYNOPSIS
    Hem konsola hem de dosyaya log kaydı yapan merkezi logging fonksiyonu
    
    .PARAMETERS
    $Message: Log mesajı
    $Level: Log seviyesi (SUCCESS, ERROR, WARNING, INFO)
    $Module: Hangi modülden geldiği
    $AdditionalInfo: Ek bilgi (opsiyonel)
    #>
    param(
        [string]$Message, 
        [string]$Level = "INFO", 
        [string]$Module = "Optemiz",
        [string]$AdditionalInfo = ""
    )

    try {
        $Time = Get-Date -Format "HH:mm:ss"
        $LogEntry = "[$Time] [$Level] [$Module] $Message"
        if ($AdditionalInfo) { $LogEntry += " | $AdditionalInfo" }
        
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
            "SUCCESS" { Write-Host "✓ [$Module] $Message" -ForegroundColor Green }
            "ERROR"   { Write-Host "✗ [$Module] $Message" -ForegroundColor Red }
            "WARNING" { Write-Host "! [$Module] $Message" -ForegroundColor Yellow }
            default   { Write-Host "→ [$Module] $Message" -ForegroundColor Cyan }
        }
    } catch {
        Write-Host "⚠️  Logging hatası: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# ====================== REGISTRY BACKUP ======================
function Backup-Registry {
    <#
    .SYNOPSIS
    Registry yedeği alır. Hata durumunda kontrol eder.
    #>
    param([string]$ModuleName = "General")
    
    try {
        $Date = Get-Date -Format "yyyyMMdd_HHmm"
        $Path = "$BackupRoot\Registry_${ModuleName}_$Date.reg"
        
        if (Test-Path $BackupRoot) {
            reg export HKCU "$Path" /y 2>&1 | Out-Null
            if (Test-Path $Path) {
                Write-Log "Registry yedeği alındı" "SUCCESS" $ModuleName $Path
                return $Path
            } else {
                Write-Log "Registry yedeği oluşturulamadı" "WARNING" $ModuleName
                return $null
            }
        }
    } catch {
        Write-Log "Registry yedekleme hatası: $($_.Exception.Message)" "ERROR" $ModuleName
        return $null
    }
}

# ====================== INTERNET BAĞLANTISI KONTROLÜ ======================
function Test-InternetConnection {
    <#
    .SYNOPSIS
    Internet bağlantısını test eder (Google DNS'e ping atar)
    
    .RETURNS
    $true veya $false
    #>
    try {
        $result = Test-Connection -ComputerName 8.8.8.8 -Count 1 -ErrorAction Stop -TimeoutSeconds 3
        return $true
    } catch {
        return $false
    }
}

# ====================== MERKEZI MENÜ SISTEMI ======================
function Show-ModuleMenu {
    <#
    .SYNOPSIS
    Tüm modüller için merkezi menü yapısı. Kodun tekrarını azaltır.
    
    .PARAMETERS
    $Title: Menü başlığı
    $Options: Seçenekler hashtable (@{"1" = "Seçenek 1", "2" = "Seçenek 2"})
    $ActionBlock: Her seçenek için çalıştırılacak scriptblock
    #>
    param(
        [string]$Title,
        [hashtable]$Options,
        [scriptblock]$ActionBlock
    )
    
    do {
        Clear-Host
        Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║  $Title" -ForegroundColor Cyan
        Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host ""
        
        # Seçenekleri sırayla göster
        $Options.GetEnumerator() | Sort-Object { [int]$_.Key } | ForEach-Object {
            Write-Host "   $($_.Key). $($_.Value)" -ForegroundColor Yellow
        }
        
        Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
        Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Green
        $choice = Read-Host "   Seçiminiz"
        
        if ($choice -eq "0") { break }
        
        if ($Options.ContainsKey($choice)) {
            try {
                & $ActionBlock $choice
            } catch {
                Write-Log "Menü işlemi hatası: $($_.Exception.Message)" "ERROR" $Title
                Write-Host "`n❌ Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz." -ForegroundColor Red
            }
        } else {
            Write-Host "`n❌ Geçersiz seçim! Lütfen 0-$($Options.Count) arasında seçim yapın." -ForegroundColor Red
        }
        
        if ($choice -ne "0") { 
            Read-Host "`nDevam etmek için Enter tuşuna basın..." 
        }
    } while ($true)
    Clear-Host
}

# ====================== SAFE DOSYA SILME ======================
function Remove-FileSafely {
    <#
    .SYNOPSIS
    Dosyaları güvenli bir şekilde siler (uyarı + onay)
    
    .PARAMETERS
    $Path: Silinecek dosyanın yolu
    $Description: Kullanıcı için açıklama
    $Force: $true ise uyarı göstermez
    
    .RETURNS
    @{ Success = $true/$false; Message = ""; Removed = sayı }
    #>
    param(
        [string]$Path,
        [string]$Description = "",
        [bool]$Force = $false
    )
    
    if (-not (Test-Path $Path)) {
        return @{ Success = $false; Message = "Dosya/klasör bulunamadı: $Path"; Removed = 0 }
    }
    
    try {
        $items = Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
        $itemCount = @($items).Count
        
        if ($itemCount -gt 0 -and -not $Force) {
            Write-Host "`n⚠️  UYARI: $itemCount dosya/klasör silinecek." -ForegroundColor Yellow
            if ($Description) { Write-Host "   ($Description)" -ForegroundColor Yellow }
            Write-Host "   Bu işlem geri döndürülemez!" -ForegroundColor Red
            $confirm = Read-Host "   Emin misiniz? (E/H)"
            
            if ($confirm -notmatch '^[Ee]$') {
                Write-Log "Silme işlemi kullanıcı tarafından iptal edildi" "WARNING"
                return @{ Success = $false; Message = "İşlem iptal edildi"; Removed = 0 }
            }
        }
        
        Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
        Write-Log "Dosyalar silindi: $itemCount item" "SUCCESS" "" "$Path"
        return @{ Success = $true; Message = "$itemCount dosya silindi"; Removed = $itemCount }
    } catch {
        Write-Log "Dosya silme hatası: $($_.Exception.Message)" "ERROR" "" $Path
        return @{ Success = $false; Message = $_.Exception.Message; Removed = 0 }
    }
}

# ====================== REGISTRY DEĞER YAZMA (SAFE) ======================
function Set-RegistrySafely {
    <#
    .SYNOPSIS
    Registry değerlerini güvenli bir şekilde yazar
    
    .PARAMETERS
    $Path: Registry yolu
    $Name: Değer adı
    $Value: Yazılacak değer
    $Type: Veri tipi (DWord, String, vb.)
    
    .RETURNS
    $true veya $false
    #>
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord"
    )
    
    try {
        # Path yoksa oluştur
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
            Write-Log "Registry yolu oluşturuldu: $Path" "INFO" "" ""
        }
        
        # Değer yaz
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop
        Write-Log "Registry yazıldı: $Name=$Value" "SUCCESS" "" $Path
        return $true
    } catch {
        Write-Log "Registry yazma hatası: $($_.Exception.Message)" "ERROR" "" "$Path\$Name"
        return $false
    }
}

# ====================== SISTEM SNAPSHOT (BAŞLANGIÇ VE SONUŞ) ======================
$global:StartSnapshot = $null
$global:OperationCount = 0
$global:SuccessCount = 0
$global:ErrorCount = 0

function Get-SystemSnapshot {
    <#
    .SYNOPSIS
    Sistemin şu anki durumunu alır (RAM, Disk, CPU)
    
    .RETURNS
    Hashtable ile sistem bilgileri
    #>
    try {
        $osInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        
        $snapshot = @{
            FreeRAM_GB       = [math]::Round($osInfo.FreePhysicalMemory / 1MB, 2)
            FreeDiskSpace_GB = [math]::Round((Get-PSDrive C -ErrorAction SilentlyContinue).Free / 1GB, 2)
            Timestamp        = Get-Date
        }
        
        return $snapshot
    } catch {
        Write-Log "Sistem snapshot hatası: $($_.Exception.Message)" "ERROR" "SystemMonitor"
        return @{ FreeRAM_GB = 0; FreeDiskSpace_GB = 0; Timestamp = Get-Date }
    }
}

function Start-SystemMonitoring {
    <#
    .SYNOPSIS
    Bakımın başında sistem durumunu kaydeder
    #>
    try {
        $global:StartSnapshot = Get-SystemSnapshot
        Write-Log "Sistem durumu kaydedildi" "INFO" "Monitor" "RAM=$($StartSnapshot.FreeRAM_GB)GB, Disk=$($StartSnapshot.FreeDiskSpace_GB)GB"
    } catch {
        Write-Log "Sistem izleme başlatılamadı: $($_.Exception.Message)" "ERROR" "Monitor"
    }
}

# ====================== HTML RAPOR FOOTER ======================
function Close-HtmlReport {
    <#
    .SYNOPSIS
    HTML raporunu kapatır ve özet istatistikleri ekler
    #>
    try {
        # Başarı oranını hesapla
        $SuccessRate = if ($global:OperationCount -gt 0) { 
            [math]::Round(($global:SuccessCount / $global:OperationCount) * 100, 1) 
        } else { 
            0 
        }
        
        $HtmlFooter = @"
    </table>
    
    <h2>📊 İşlem Özeti</h2>
    <div class="summary-box">
        <p>
            <span class="label">Toplam İşlem:</span> <span class="value">$($global:OperationCount)</span><br>
            <span class="label">Başarılı:</span> <span class="value" style="color: #00ff88;">$($global:SuccessCount)</span><br>
            <span class="label">Hata:</span> <span class="value" style="color: #ff6666;">$($global:ErrorCount)</span><br>
            <span class="label">Başarı Oranı:</span> <span class="value">$($SuccessRate)%</span>
        </p>
    </div>
    
    <div class="footer">
        <p>
            🚀 <strong>Optemiz v2.1.3</strong> | Sistem Bakım ve Optimizasyon Aracı<br>
            Geliştirici: Grok & Oğuz | <a href="https://github.com/ompekacar/Optemiz" style="color: #00ddff;">GitHub Repository</a><br>
            Rapor Tarihi: $(Get-Date -Format "dd MMMM yyyy HH:mm:ss")<br>
            <br>
            ℹ️ Bu araç personal ve ticari kullanım için ücretsizdir.<br>
            ⚠️ Tüm işlemler yönetici (Administrator) yetkisiyle yapılmıştır.
        </p>
    </div>
    
</body>
</html>
"@
        
        $HtmlFooter | Add-Content -Path $HtmlLogPath -Encoding UTF8 -Force
        Write-Log "HTML rapor kapatıldı ve tamamlandı" "SUCCESS" "HtmlReport"
    } catch {
        Write-Log "HTML rapor kapatma hatası: $($_.Exception.Message)" "ERROR" "HtmlReport"
    }
}

# ====================== BAŞLANGIÇ LOG ======================
Write-Log "Optemiz v2.1.3 başarıyla başlatıldı" "SUCCESS" "System" "Admin: $(Test-AdminRights)"
Write-Log "═════════════════════════════════════════" "INFO" "System" ""
