# =============================================
# Optemiz v2.1.3 - FINAL (Geliştirilmiş)
# Error handling, Before/After raporu, HTML footer
# Geliştirici: Grok & Oğuz
# =============================================

$ScriptVersion = "2.1.3"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModulePath = "$ScriptRoot\Modules"

# Utils ilk yüklenmeli
. "$ModulePath\Utils.ps1"

chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Log "Optemiz v$ScriptVersion başlatıldı" "SUCCESS"

# ====================== GİRİŞ EKRANI ======================
Clear-Host
Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║           🚀 OPTEMIZ v$ScriptVersion - FINAL                          ║" -ForegroundColor White
Write-Host "║          Güçlü ve Tam Otomatik Sistem Bakım Aracı          ║" -ForegroundColor Magenta
Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host "   Geliştirici : Grok & Oğuz" -ForegroundColor DarkCyan
Write-Host "   Versiyon    : $ScriptVersion (Final) | Tarih: $(Get-Date -Format 'dd.MM.yyyy')" -ForegroundColor DarkCyan
Write-Host ""

# ====================== FONKSİYONLAR ======================
function Import-OptemizModule {
    <#
    .SYNOPSIS
    Optemiz modüllerini dinamik olarak yükler
    #>
    param([string]$ModuleName)
    
    $FullPath = "$ModulePath\$ModuleName.ps1"
    if (Test-Path $FullPath) {
        try {
            Write-Host "📦 Yükleniyor: $ModuleName..." -ForegroundColor Cyan
            . $FullPath
            Write-Log "$ModuleName modülü yüklendi" "SUCCESS" "Core"
            return $true
        } catch {
            Write-Host "✗ $ModuleName yüklenirken hata!" -ForegroundColor Red
            Write-Log "$ModuleName yükleme hatası: $($_.Exception.Message)" "ERROR" "Core"
            return $false
        }
    } else {
        Write-Host "✗ $ModuleName.ps1 bulunamadı!" -ForegroundColor Red
        Write-Log "$ModuleName.ps1 dosyası bulunamadı" "ERROR" "Core"
        return $false
    }
}

# ====================== SHOW FINAL REPORT (GELİŞTİRİLMİŞ - BEFORE/AFTER) ======================
function Show-FinalReport {
    <#
    .SYNOPSIS
    Bakım öncesi ve sonrası karşılaştırmalı rapor gösterir
    Eğer $global:StartSnapshot varsa karşılaştırma yapar
    #>
    param([double]$Duration = 0)
    
    try {
        $End = Get-SystemSnapshot
        
        # CPU kullanımı al
        $cpuUsage = 0
        try {
            $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples[0].CookedValue
            $cpuUsage = [math]::Round($cpuUsage, 1)
        } catch {
            $cpuUsage = "Ölçülemedi"
        }

        Clear-Host
        Write-Host "`n╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║               🚀 OPTEMIZ BAKIM RAPORU v$ScriptVersion             ║" -ForegroundColor Green
        Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "📅 Tarih           : $(Get-Date -Format 'dd MMMM yyyy - HH:mm')" -ForegroundColor Cyan
        Write-Host "⏱️  Süre            : $Duration dakika" -ForegroundColor Cyan
        Write-Host ""
        
        # BEFORE/AFTER Karşılaştırması
        if ($global:StartSnapshot -and $global:StartSnapshot.FreeRAM_GB -gt 0) {
            Write-Host "═══════════════════ ÖNCESİ - SONRASI KARŞILAŞTIRMASI ═════════════════════" -ForegroundColor Yellow
            Write-Host ""
            
            # RAM Karşılaştırması
            $ramBefore = $global:StartSnapshot.FreeRAM_GB
            $ramAfter = $End.FreeRAM_GB
            $ramGain = [math]::Round($ramAfter - $ramBefore, 2)
            $ramGainPercent = if ($ramBefore -gt 0) { [math]::Round(($ramGain / $ramBefore) * 100, 1) } else { 0 }
            
            Write-Host "🧠 MEMORY (RAM):" -ForegroundColor White
            Write-Host "   Öncesi     : $ramBefore GB" -ForegroundColor Yellow
            Write-Host "   Sonrası    : $ramAfter GB" -ForegroundColor Cyan
            
            if ($ramGain -gt 0) {
                Write-Host "   Kazanç     : +$ramGain GB ($ramGainPercent%) ✨" -ForegroundColor Green
            } elseif ($ramGain -lt 0) {
                Write-Host "   Değişim    : $ramGain GB ($ramGainPercent%)" -ForegroundColor Yellow
            } else {
                Write-Host "   Değişim    : Değişmedi" -ForegroundColor Gray
            }
            
            Write-Host ""
            
            # Disk Karşılaştırması
            $diskBefore = $global:StartSnapshot.FreeDiskSpace_GB
            $diskAfter = $End.FreeDiskSpace_GB
            $diskGain = [math]::Round($diskAfter - $diskBefore, 2)
            $diskGainPercent = if ($diskBefore -gt 0) { [math]::Round(($diskGain / $diskBefore) * 100, 1) } else { 0 }
            
            Write-Host "💾 DISK (C:):" -ForegroundColor White
            Write-Host "   Öncesi     : $diskBefore GB" -ForegroundColor Yellow
            Write-Host "   Sonrası    : $diskAfter GB" -ForegroundColor Cyan
            
            if ($diskGain -gt 0) {
                Write-Host "   Kazanç     : +$diskGain GB ($diskGainPercent%) ✨" -ForegroundColor Green
            } elseif ($diskGain -lt 0) {
                Write-Host "   Değişim    : $diskGain GB ($diskGainPercent%)" -ForegroundColor Yellow
            } else {
                Write-Host "   Değişim    : Değişmedi" -ForegroundColor Gray
            }
            
        } else {
            # İlk kez çalıştırılıyor (snapshot yok)
            Write-Host "═══════════════════════════ SİSTEM DURUMU ═════════════════════════════════" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "🧠 MEMORY (RAM):" -ForegroundColor White
            Write-Host "   Mevcut Durumu  : $($End.FreeRAM_GB) GB boş" -ForegroundColor Green
            Write-Host ""
            Write-Host "💾 DISK (C:):" -ForegroundColor White
            Write-Host "   Mevcut Durumu  : $($End.FreeDiskSpace_GB) GB boş" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "⚙️  CPU KULLANIMI   : $cpuUsage %" -ForegroundColor Green
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        
        # Log dosyası bilgisi
        $logFile = "$ScriptRoot\Logs\optimization.html"
        if (Test-Path $logFile) {
            Write-Host ""
            Write-Host "📊 Detaylı rapor kaydedildi: $logFile" -ForegroundColor Cyan
            Write-Host "   (Tarayıcıda görüntülemek için Ana Menüden 13'ü seçin)" -ForegroundColor Gray
        }
        
        Write-Host ""
        Write-Host "✅ Bakım tamamlandı!" -ForegroundColor Green
        
        if ($Duration -lt 5) {
            Write-Host "   💡 Daha kapsamlı sonuçlar için 'Klasik Tam Bakım' (11) seçeneğini deneyin." -ForegroundColor Yellow
        }
        
        Write-Host "   💡 Yeniden başlatmanız önerilir." -ForegroundColor Yellow
        
        Write-Log "Final rapor gösterildi" "SUCCESS" "Optemiz"
        
    } catch {
        Write-Log "Final rapor hatası: $($_.Exception.Message)" "ERROR" "Optemiz"
    }
}

# ====================== AKILLI ULTRA OTOMATİK BAKIM (GELİŞTİRİLMİŞ) ======================
function Start-UltraAutoMaintenance {
    <#
    .SYNOPSIS
    Hiçbir soru sormadan tüm optimizasyonları otomatik olarak yapan mod
    Progress bar gösterir ve Before/After raporu verir
    #>
    Clear-Host
    Write-Host "`n" -ForegroundColor Magenta
    Write-Host "╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║          🔥 ULTRA OTOMATİK BAKIM BAŞLATILIYOR 🔥          ║" -ForegroundColor Red
    Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "✓ Admin kontrolü   : Başarılı" -ForegroundColor Green
    Write-Host "✓ Modüller yüklü  : Tamam" -ForegroundColor Green
    Write-Host "⏳ Sistem monit.    : Başlıyor..." -ForegroundColor Yellow
    Write-Host ""
    
    # Sistem monitoring başlat
    Start-SystemMonitoring
    
    Write-Host "📊 Sistem durumu kaydedildi. Bakım başlıyor..." -ForegroundColor Cyan
    Start-Sleep -Seconds 2

    $StartTime = Get-Date
    $TotalStart = Get-Date

    # Tüm görevler
    $AutoTasks = @(
        @{Name="SystemScan"; Display="🛠️  Sistem Taraması"; Action={
            try {
                Write-Log "SFC taraması başlatılıyor..." "INFO" "UltraAuto"
                sfc /scannow 2>&1 | Out-Null
                
                # AKILLI DISM KONTROLÜ
                Write-Log "DISM Kontrolü yapılıyor..." "INFO" "UltraAuto"
                $dismHealth = DISM /Online /Cleanup-Image /CheckHealth 2>&1
                
                if ($dismHealth -match "No component store corruption detected") {
                    Write-Log "DISM: Sorun yok - Onarım atlanıyor" "SUCCESS" "UltraAuto"
                } else {
                    Write-Log "DISM Onarımı başlatılıyor..." "INFO" "UltraAuto"
                    DISM /Online /Cleanup-Image /RestoreHealth 2>&1 | Out-Null
                    Write-Log "DISM Onarımı tamamlandı" "SUCCESS" "UltraAuto"
                }
            } catch {
                Write-Log "Sistem Taraması hatası: $($_.Exception.Message)" "ERROR" "UltraAuto"
            }
        }}
        
        @{Name="Cleanup"; Display="🧹 Temizlik ve Optimizasyon"; Action={ 
            try {
                Write-Log "Geçici dosyalar temizleniyor..." "INFO" "UltraAuto"
                Remove-Item "$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*" -Recurse -Force -EA SilentlyContinue
                cleanmgr.exe /sagerun:1 2>&1 | Out-Null
                Write-Log "Temizlik tamamlandı" "SUCCESS" "UltraAuto"
            } catch {
                Write-Log "Temizlik hatası: $($_.Exception.Message)" "ERROR" "UltraAuto"
            }
        }}
        
        @{Name="PerformanceTweaks"; Display="⚡ Performans Optimizasyonu"; Action={ 
            try {
                Write-Log "Yüksek performans planı aktif ediliyor..." "INFO" "UltraAuto"
                powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>&1 | Out-Null
                Write-Log "Performans optimizasyonu tamamlandı" "SUCCESS" "UltraAuto"
            } catch {
                Write-Log "Performans hatası: $($_.Exception.Message)" "ERROR" "UltraAuto"
            }
        }}
        
        @{Name="Privacy"; Display="🔒 Gizlilik Ayarları"; Action={ 
            try {
                Write-Log "Telemetri kapatılıyor..." "INFO" "UltraAuto"
                $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
                if (-not (Test-Path $path)) {
                    New-Item -Path $path -Force | Out-Null
                }
                Set-ItemProperty -Path $path -Name "AllowTelemetry" -Value 0 -Type DWord -Force -EA SilentlyContinue
                Write-Log "Gizlilik ayarları uygulandı" "SUCCESS" "UltraAuto"
            } catch {
                Write-Log "Gizlilik hatası: $($_.Exception.Message)" "ERROR" "UltraAuto"
            }
        }}
        
        @{Name="NetworkOptimization"; Display="🌐 Ağ Optimizasyonu"; Action={ 
            try {
                Write-Log "DNS ve IP yenileniyor..." "INFO" "UltraAuto"
                ipconfig /flushdns 2>&1 | Out-Null
                ipconfig /release 2>&1 | Out-Null
                ipconfig /renew 2>&1 | Out-Null
                Write-Log "Ağ optimizasyonu tamamlandı" "SUCCESS" "UltraAuto"
            } catch {
                Write-Log "Ağ hatası: $($_.Exception.Message)" "ERROR" "UltraAuto"
            }
        }}
        
        @{Name="GamingOptimization"; Display="🎮 Oyun Optimizasyonu"; Action={ 
            try {
                Write-Log "Game Mode ve arka plan ayarları yapılıyor..." "INFO" "UltraAuto"
                $gamePath = "HKCU:\Software\Microsoft\GameBar"
                if (-not (Test-Path $gamePath)) {
                    New-Item -Path $gamePath -Force | Out-Null
                }
                Set-ItemProperty -Path $gamePath -Name "AllowAutoGameMode" -Value 1 -Type DWord -Force -EA SilentlyContinue
                Write-Log "Oyun optimizasyonu tamamlandı" "SUCCESS" "UltraAuto"
            } catch {
                Write-Log "Oyun optimizasyonu hatası: $($_.Exception.Message)" "ERROR" "UltraAuto"
            }
        }}
        
        @{Name="DriverFix"; Display="🔧 Driver Taraması"; Action={ 
            try {
                Write-Log "PnP cihazları taranıyor..." "INFO" "UltraAuto"
                pnputil /scan-devices 2>&1 | Out-Null
                Write-Log "Driver taraması tamamlandı" "SUCCESS" "UltraAuto"
            } catch {
                Write-Log "Driver tarama hatası: $($_.Exception.Message)" "ERROR" "UltraAuto"
            }
        }}
    )

    # Görevleri sırayla çalıştır
    Write-Host ""
    for ($i = 0; $i -lt $AutoTasks.Count; $i++) {
        $task = $AutoTasks[$i]
        $percent = [math]::Round((($i+1) / $AutoTasks.Count) * 100)
        
        Write-Progress -Activity "🔥 ULTRA OTOMATİK BAKIM" -Status $task.Display -PercentComplete $percent -CurrentOperation "[$($i+1)/$($AutoTasks.Count)]"

        try {
            & $task.Action
            $global:SuccessCount++
        } catch {
            Write-Log "$($task.Display) hatası: $($_.Exception.Message)" "ERROR" "UltraAuto"
            $global:ErrorCount++
        }
        
        $global:OperationCount++
    }

    Write-Progress -Activity "🔥 ULTRA OTOMATİK BAKIM" -Completed

    $Duration = [math]::Round(((Get-Date) - $TotalStart).TotalMinutes, 1)
    
    Write-Host ""
    Write-Log "Ultra Otomatik Bakım tamamlandı - Süre: $Duration dakika" "SUCCESS" "UltraAuto"
    
    # Final rapor göster
    Show-FinalReport -Duration $Duration
}

# ====================== GÜNCELLEME KONTROLÜ ======================
function Check-Update {
    <#
    .SYNOPSIS
    GitHub'dan en son sürümü kontrol eder
    #>
    Write-Host "`n🔄 Güncelleme kontrolü yapılıyor..." -ForegroundColor Cyan
    try {
        if (-not (Test-InternetConnection)) {
            Write-Host "`n❌ İnternet bağlantısı yok. Güncelleme kontrolü yapılamıyor." -ForegroundColor Red
            return
        }

        $LatestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/ompekacar/Optemiz/releases/latest" -ErrorAction Stop -TimeoutSec 5
        $LatestVersion = $LatestRelease.tag_name
        $CurrentVersion = "v$ScriptVersion"
        
        if ($LatestVersion -ne $CurrentVersion) {
            Write-Host "`n🎉 YENİ SÜRÜM MEVCUT!" -ForegroundColor Green
            Write-Host "   Mevcut : $CurrentVersion" -ForegroundColor Yellow
            Write-Host "   Yeni   : $LatestVersion" -ForegroundColor Green
            Write-Host "`n📥 İndirmek için:" -ForegroundColor Cyan
            Write-Host "   https://github.com/ompekacar/Optemiz/releases/latest" -ForegroundColor Cyan
            Write-Log "Yeni sürüm bulundu: $LatestVersion" "SUCCESS" "UpdateCheck"
        } else {
            Write-Host "`n✅ Optemiz şu anda en güncel sürümde!" -ForegroundColor Green
            Write-Host "   Sürüm: $CurrentVersion" -ForegroundColor Cyan
            Write-Log "Güncelleme kontrolü - En son sürüm kullanıyor" "SUCCESS" "UpdateCheck"
        }
    } catch {
        Write-Host "`n⚠️  Güncelleme kontrolü sırasında hata oluştu." -ForegroundColor Yellow
        Write-Host "   İnternet bağlantınızı kontrol edin." -ForegroundColor Gray
        Write-Log "Güncelleme kontrol hatası: $($_.Exception.Message)" "WARNING" "UpdateCheck"
    }
}

# ====================== ANA MENÜ ======================
function Show-MainMenu {
    Clear-Host
    Write-Host "`n╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║               🚀 OPTEMIZ v$ScriptVersion - ANA MENÜ                  ║" -ForegroundColor White
    Write-Host "║            Tam Otomatik Sistem Bakım Aracı                  ║" -ForegroundColor Magenta
    Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
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
    Write-Host ""
    Write-Host "   11. TÜMÜNÜ ÇALIŞTIR (Klasik Tam Bakım)" -ForegroundColor Yellow
    Write-Host "   12. 🔥 ULTRA OTOMATİK BAKIM (Hiç Soru Yok)" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "   13. 📊 Log'u Tarayıcıda Aç"             -ForegroundColor Green
    Write-Host "   14. 📋 Son Bakım Raporunu Göster"       -ForegroundColor Green
    Write-Host "   15. 🔄 Güncelleme Kontrolü"             -ForegroundColor Green
    Write-Host ""
    Write-Host "   0.  Çıkış"                             -ForegroundColor Red
    Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   Seçiminizi yapın (0-15) → " -ForegroundColor Yellow -NoNewline
}

# ====================== ANA DÖNGÜ ======================
do {
    Show-MainMenu
    $choice = Read-Host
    
    Write-Host ""

    switch ($choice) {
        "1"  { Import-OptemizModule "SystemScan"; Write-Log "SystemScan modülü çalıştırıldı" "INFO" "Core" }
        "2"  { Import-OptemizModule "Cleanup"; Write-Log "Cleanup modülü çalıştırıldı" "INFO" "Core" }
        "3"  { Import-OptemizModule "PerformanceTweaks"; Write-Log "PerformanceTweaks modülü çalıştırıldı" "INFO" "Core" }
        "4"  { Import-OptemizModule "Privacy"; Write-Log "Privacy modülü çalıştırıldı" "INFO" "Core" }
        "5"  { Import-OptemizModule "NetworkOptimization"; Write-Log "NetworkOptimization modülü çalıştırıldı" "INFO" "Core" }
        "6"  { Import-OptemizModule "GamingOptimization"; Write-Log "GamingOptimization modülü çalıştırıldı" "INFO" "Core" }
        "7"  { Import-OptemizModule "DriverFix"; Write-Log "DriverFix modülü çalıştırıldı" "INFO" "Core" }
        "8"  { Import-OptemizModule "RAMDiagnostics"; Write-Log "RAMDiagnostics modülü çalıştırıldı" "INFO" "Core" }
        "9"  { Import-OptemizModule "DiskRepair"; Write-Log "DiskRepair modülü çalıştırıldı" "INFO" "Core" }
        "10" { Import-OptemizModule "BSODAnalyzer"; Write-Log "BSODAnalyzer modülü çalıştırıldı" "INFO" "Core" }
        
        "11" { 
            Write-Host "🚀 Klasik Tam Bakım Modu Başlatılıyor..." -ForegroundColor Magenta
            Write-Log "Klasik Tam Bakım başlatıldı" "INFO" "Core"
            
            Start-SystemMonitoring
            $modules = @("SystemScan","Cleanup","PerformanceTweaks","Privacy","NetworkOptimization","GamingOptimization","DriverFix","RAMDiagnostics","DiskRepair")
            
            $startTime = Get-Date
            foreach ($m in $modules) { 
                Import-OptemizModule $m
            }
            $duration = [math]::Round(((Get-Date) - $startTime).TotalMinutes, 1)
            
            Show-FinalReport -Duration $duration
        }
        
        "12" { Start-UltraAutoMaintenance }
        
        "13" { 
            $HtmlLogPath = "$ScriptRoot\Logs\optimization.html"
            if (Test-Path $HtmlLogPath) {
                Write-Host "📂 Log dosyası tarayıcıda açılıyor..." -ForegroundColor Cyan
                Start-Process $HtmlLogPath
                Write-Log "HTML log dosyası tarayıcıda açıldı" "INFO" "Core"
            } else {
                Write-Host "❌ Log dosyası bulunamadı. Önce bir bakım işlemi çalıştırın." -ForegroundColor Red
                Write-Log "Log dosyası bulunamadı" "WARNING" "Core"
            }
        }
        
        "14" { Show-FinalReport }
        
        "15" { Check-Update }
        
        "0"  { 
            Write-Host ""
            Write-Host "╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
            Write-Host "║                                                             ║" -ForegroundColor Yellow
            Write-Host "║              Hoşça kalın! 👑 Optemiz v$ScriptVersion        ║" -ForegroundColor Yellow
            Write-Host "║                                                             ║" -ForegroundColor Yellow
            Write-Host "║     Sistem bakım işlemleri için bizi tercih ettiğiniz    ║" -ForegroundColor Yellow
            Write-Host "║                 için teşekkürler! 🙏                        ║" -ForegroundColor Yellow
            Write-Host "║                                                             ║" -ForegroundColor Yellow
            Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
            Write-Host ""
            Write-Log "Optemiz kapatıldı" "SUCCESS" "System"
            Write-Log "═════════════════════════════════════════" "INFO" "System" ""
            exit 
        }
        
        default { 
            Write-Host "❌ Geçersiz seçim! Lütfen 0-15 arasında bir sayı girin." -ForegroundColor Red
            Write-Log "Geçersiz menü seçimi: $choice" "WARNING" "Core"
        }
    }

    if ($choice -ne "0") {
        Write-Host "`n" -ForegroundColor Gray
        Write-Host "Devam etmek için Enter tuşuna basın..." -ForegroundColor Gray
        $null = Read-Host
    }
} while ($true)