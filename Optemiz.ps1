# =============================================
# Optemiz v2.1.0 - TAM FİNAL
# Geliştirici: Grok & Oğuz
# =============================================

$ScriptVersion = "2.1.0"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModulePath = "$ScriptRoot\Modules"   # ← Bu satır önemli

. "$ModulePath\Utils.ps1"             # Utils ilk yüklenmeli

# ====================== GİRİŞ EKRANI ======================
Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           🚀 OPTEMIZ v$ScriptVersion - FINAL                                   ║" -ForegroundColor White
Write-Host "║          Güçlü ve Tam Otomatik Sistem Bakım Aracı                ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "   Geliştirici : Grok & Oğuz" -ForegroundColor DarkCyan
Write-Host ""

. "$ModulePath\Utils.ps1"

chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Log "Optemiz v$ScriptVersion başlatıldı" "SUCCESS"

# ====================== FONKSİYONLAR ======================
function Import-OptemizModule {
    param([string]$ModuleName)
    $FullPath = "$ModulePath\$ModuleName.ps1"
    if (Test-Path $FullPath) {
        try { . $FullPath; return $true } 
        catch { Write-Host "✗ $ModuleName yüklenirken hata!" -ForegroundColor Red; return $false }
    } else {
        Write-Host "✗ $ModuleName.ps1 bulunamadı!" -ForegroundColor Red
        return $false
    }
}

function Get-SystemSnapshot {
    $snapshot = @{
        FreeRAM_GB       = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)
        FreeDiskSpace_GB = [math]::Round((Get-PSDrive C).Free / 1GB, 2)
    }
    return $snapshot
}

function Show-FinalReport {
    param([double]$Duration = 0)
    
    $End = Get-SystemSnapshot
    $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples[0].CookedValue
    $cpuUsage = [math]::Round($cpuUsage, 1)

    Clear-Host
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║               🚀 OPTEMIZ BAKIM RAPORU v$ScriptVersion                 ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "📅 Tarih           : $(Get-Date -Format 'dd MMMM yyyy - HH:mm')" -ForegroundColor Cyan
    Write-Host "⏱️  Süre            : $Duration dakika" -ForegroundColor Cyan
    Write-Host "🧠 Boş RAM         : $($End.FreeRAM_GB) GB" -ForegroundColor Green
    Write-Host "💾 Boş Disk (C:)   : $($End.FreeDiskSpace_GB) GB" -ForegroundColor Green
    Write-Host "⚙️  CPU Kullanımı   : $cpuUsage %" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Bakım tamamlandı. Yeniden başlatmanızı öneririm." -ForegroundColor Green
}

function Start-UltraAutoMaintenance {
    Clear-Host
    Write-Host "`n🚀 ULTRA OTOMATİK BAKIM BAŞLATILIYOR..." -ForegroundColor Magenta
    Write-Host "Hiçbir menü çıkmayacak, tamamen otomatik ilerliyor...`n" -ForegroundColor Yellow

    $StartSnapshot = Get-SystemSnapshot
    $RepairStart = Get-Date

    $AutoTasks = @(
        @{Name="SystemScan";        Display="🛠️ Sistem Taraması";        Action={ sfc /scannow | Out-Null; DISM /Online /Cleanup-Image /RestoreHealth | Out-Null }}
        @{Name="Cleanup";           Display="🧹 Temizlik";               Action={ 
            Remove-Item "$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*" -Recurse -Force -EA SilentlyContinue
            cleanmgr.exe /sagerun:1 | Out-Null 
        }}
        @{Name="PerformanceTweaks"; Display="⚡ Performans";             Action={ powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c }}
        @{Name="Privacy";           Display="🔒 Gizlilik";               Action={ 
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force -EA SilentlyContinue 
        }}
        @{Name="NetworkOptimization"; Display="🌐 Ağ";                   Action={ ipconfig /flushdns | Out-Null; ipconfig /renew | Out-Null }}
        @{Name="GamingOptimization";  Display="🎮 Oyun";                 Action={ powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c }}
        @{Name="DriverFix";         Display="🔧 Driver";                 Action={ pnputil /scan-devices | Out-Null }}
        @{Name="RAMDiagnostics";    Display="🧠 RAM";                    Action={}}
        @{Name="DiskRepair";        Display="💾 Disk";                   Action={}}
    )

    for ($i = 0; $i -lt $AutoTasks.Count; $i++) {
        $task = $AutoTasks[$i]
        $percent = [math]::Round((($i+1) / $AutoTasks.Count) * 100)
        Write-Progress -Activity "Ultra Otomatik Bakım" -Status $task.Display -PercentComplete $percent

        try {
            & $task.Action
            Write-Log "$($task.Display) tamamlandı" "SUCCESS"
        } catch {
            Write-Log "$($task.Display) hatası" "WARNING"
        }
    }

    Write-Progress -Activity "Ultra Otomatik Bakım" -Completed

    $Duration = [math]::Round(((Get-Date) - $RepairStart).TotalMinutes, 1)

    Show-FinalReport -Duration $Duration
}

function Check-Update {
    Write-Host "`n🔄 Güncelleme kontrolü yapılıyor..." -ForegroundColor Cyan
    Write-Host "En son sürüm kontrol ediliyor (GitHub)..." -ForegroundColor Cyan

    try {
        $LatestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/ompekacar/Optemiz/releases/latest" -ErrorAction Stop
        
        $LatestVersion = $LatestRelease.tag_name
        $CurrentVersion = "v$ScriptVersion"
        
        if ($LatestVersion -ne $CurrentVersion) {
            Write-Host "`n🎉 Yeni sürüm mevcut: $LatestVersion" -ForegroundColor Green
            Write-Host "İndirmek için: https://github.com/ompekacar/Optemiz/releases/latest" -ForegroundColor Cyan
            Write-Log "Yeni sürüm bulundu: $LatestVersion" "SUCCESS"
        } else {
            Write-Host "`n✅ Optemiz şu anda en güncel sürümde ($CurrentVersion)" -ForegroundColor Green
            Write-Log "Güncelleme kontrolü - En son sürüm kullanıyor" "SUCCESS"
        }
    } catch {
        Write-Host "`n⚠️ Güncelleme kontrolü sırasında hata oluştu." -ForegroundColor Yellow
        Write-Host "İnternet bağlantınızı kontrol edin." -ForegroundColor Gray
    }
}

# ====================== ANA MENÜ ======================
function Show-MainMenu {
    Clear-Host
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║               🚀 OPTEMIZ v$ScriptVersion                              ║" -ForegroundColor White
    Write-Host "║            Tam Otomatik Bakım Aracı                          ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "   1.  Sistem Taraması ve Onarım"           -ForegroundColor Cyan
    Write-Host "   2.  Temizlik ve Optimizasyon"           -ForegroundColor Cyan
    Write-Host "   3.  Performans Optimizasyonu"           -ForegroundColor Cyan
    Write-Host "   4.  Gizlilik Ayarları"                   -ForegroundColor Cyan
    Write-Host "   5.  Ağ Optimizasyonu"                    -ForegroundColor Cyan
    Write-Host "   6.  Oyun Optimizasyonu"                  -ForegroundColor Cyan
    Write-Host "   7.  Driver Kontrol ve Yedekleme"        -ForegroundColor Cyan
    Write-Host "   8.  RAM Test ve Tanılama"               -ForegroundColor Cyan
    Write-Host "   9.  Disk Kontrol ve Onarım"             -ForegroundColor Cyan
    Write-Host "   10. BSOD Analizi"                       -ForegroundColor Cyan
    Write-Host "   11. TÜMÜNÜ ÇALIŞTIR (Klasik Tam Bakım)" -ForegroundColor Yellow
    Write-Host "   12. 🔥 ULTRA OTOMATİK BAKIM (Hiç Soru Yok)" -ForegroundColor Magenta
    Write-Host "   13. Log’u Tarayıcıda Aç"               -ForegroundColor Cyan
    Write-Host "   14. Son Bakım Raporunu Göster"         -ForegroundColor Magenta
    Write-Host "   15. 🔄 Güncelleme Kontrolü"             -ForegroundColor Cyan
    Write-Host "   0.  Çıkış"                             -ForegroundColor Red
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   Seçiminizi yapın (0-15) → " -ForegroundColor Yellow -NoNewline
}

# ====================== GÜNCELLEME KONTROLÜ ======================
function Check-Update {
    Write-Host "`n🔄 GitHub üzerinden güncelleme kontrolü yapılıyor..." -ForegroundColor Cyan
    
    try {
        $Latest = Invoke-RestMethod -Uri "https://api.github.com/repos/ompekacar/Optemiz/releases/latest" -TimeoutSec 10
        $LatestVersion = $Latest.tag_name
        $CurrentVersion = "v$ScriptVersion"

        if ($LatestVersion -ne $CurrentVersion) {
            Write-Host "`n🎉 Yeni sürüm mevcut: $LatestVersion" -ForegroundColor Green
            Write-Host "İndirmek için: https://github.com/ompekacar/Optemiz/releases/latest" -ForegroundColor Cyan
            Write-Log "Yeni sürüm bulundu: $LatestVersion" "SUCCESS"
        } else {
            Write-Host "`n✅ Optemiz şu anda en güncel sürümde ($CurrentVersion)" -ForegroundColor Green
            # Sadece bir kez log yazması için
            Write-Log "Güncelleme kontrolü - En son sürüm kullanılıyor" "SUCCESS"
        }
    }
    catch {
        Write-Host "`n⚠️ Güncelleme kontrolü yapılamadı. İnternet bağlantınızı kontrol edin." -ForegroundColor Yellow
        Write-Log "Güncelleme kontrolü başarısız" "WARNING"
    }
}

# ====================== ANA DÖNGÜ ======================
do {
    Show-MainMenu
    $choice = Read-Host

    switch ($choice) {
        "1"  { Import-OptemizModule "SystemScan" }
        "2"  { Import-OptemizModule "Cleanup" }
        "3"  { Import-OptemizModule "PerformanceTweaks" }
        "4"  { Import-OptemizModule "Privacy" }
        "5"  { Import-OptemizModule "NetworkOptimization" }
        "6"  { Import-OptemizModule "GamingOptimization" }
        "7"  { Import-OptemizModule "DriverFix" }
        "8"  { Import-OptemizModule "RAMDiagnostics" }
        "9"  { Import-OptemizModule "DiskRepair" }
        "10" { Import-OptemizModule "BSODAnalyzer" }
        "11" { 
            Write-Host "`n🚀 Klasik Tam Bakım Modu Başlatılıyor..." -ForegroundColor Magenta
            $modules = @("SystemScan","Cleanup","PerformanceTweaks","Privacy","NetworkOptimization","GamingOptimization","DriverFix","RAMDiagnostics","DiskRepair")
            foreach ($m in $modules) { Import-OptemizModule $m }
        }
        "12" { Start-UltraAutoMaintenance }
        "13" { 
            $HtmlLogPath = "$ScriptRoot\Logs\optimization.html"
            if (Test-Path $HtmlLogPath) { Start-Process $HtmlLogPath }
        }
        "14" { Show-FinalReport }
        "15" { 
            Check-Update 
        }
        "0"  { 
            Write-Host "`nHoşça kalın 👑 Optemiz v$ScriptVersion" -ForegroundColor Yellow
            exit 
        }
        default { Write-Host "`n❌ Geçersiz seçim!" -ForegroundColor Red }
    }

    if ($choice -ne "0") {
        Write-Host "`nDevam etmek için Enter tuşuna basın..." -ForegroundColor Gray
        $null = Read-Host
    }
} while ($true)
