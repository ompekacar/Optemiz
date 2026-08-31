# =============================================
# PerformanceTweaks.ps1 - Performans Optimizasyonu
# =============================================

Write-Log "Performans Optimizasyonu modülü başladı" "INFO" "PerformanceTweaks"

function Show-PerfMenu {
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              ⚡ PERFORMANS OPTİMİZASYONU v2.1                ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Write-Host "   1. Yüksek Performans Güç Planı" -ForegroundColor Cyan
    Write-Host "   2. Görsel Efektleri Azalt" -ForegroundColor Cyan
    Write-Host "   3. Hizmetleri Optimize Et" -ForegroundColor Cyan
    Write-Host "   4. Başlangıç Programlarını Göster" -ForegroundColor Cyan
    Write-Host "   5. ⚡ Full Performance Optimization" -ForegroundColor Magenta
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-PerfMenu
    $perfChoice = Read-Host

    switch ($perfChoice) {
        "1" {
            Write-Host "`n⚡ Yüksek Performans planı aktif ediliyor..." -ForegroundColor Yellow
            Write-Log "Yüksek Performans planı aktif ediliyor" "INFO" "PerformanceTweaks"
            try {
                powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>&1 | Out-Null
                Write-Log "Yüksek Performans planı aktif edildi" "SUCCESS" "PerformanceTweaks"
                Write-Host "✅ Yüksek Performans planı aktif edildi." -ForegroundColor Green
            } catch {
                Write-Log "Performans planı hatası: $($_.Exception.Message)" "ERROR" "PerformanceTweaks"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "2" {
            Write-Host "`n🎨 Görsel efektler azaltılıyor..." -ForegroundColor Yellow
            Write-Log "Görsel efektler azaltılıyor" "INFO" "PerformanceTweaks"
            try {
                Backup-Registry -ModuleName "VisualEffects" | Out-Null
                $visualPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
                if (-not (Test-Path $visualPath)) {
                    New-Item -Path $visualPath -Force | Out-Null
                }
                Set-ItemProperty -Path $visualPath -Name "VisualFXSetting" -Value 2 -Type DWord -Force -EA SilentlyContinue
                Write-Log "Görsel efektler performans için azaltıldı" "SUCCESS" "PerformanceTweaks"
                Write-Host "✅ Görsel efektler performans için azaltıldı." -ForegroundColor Green
            } catch {
                Write-Log "Görsel efektler hatası: $($_.Exception.Message)" "WARNING" "PerformanceTweaks"
                Write-Host "⚠️  Görsel efektler değiştirilemedi." -ForegroundColor Yellow
            }
        }
        "3" {
            Write-Host "`n🔧 Hizmetler optimize ediliyor..." -ForegroundColor Yellow
            Write-Log "Hizmet optimizasyonu başlatılıyor" "INFO" "PerformanceTweaks"
            try {
                Backup-Registry -ModuleName "Services" | Out-Null
                $Services = @("SysMain","WSearch","DiagTrack","dps","XblAuthManager","XblGameSave")
                $optimizedCount = 0
                
                foreach ($svc in $Services) {
                    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
                        Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
                        $optimizedCount++
                    }
                }
                
                Write-Log "Hizmet optimizasyonu tamamlandı ($optimizedCount hizmet)" "SUCCESS" "PerformanceTweaks"
                Write-Host "✅ Hizmet optimizasyonu uygulandı ($optimizedCount hizmet)." -ForegroundColor Green
            } catch {
                Write-Log "Hizmet optimizasyonu hatası: $($_.Exception.Message)" "WARNING" "PerformanceTweaks"
                Write-Host "⚠️  Bazı hizmetler değiştirilemedi." -ForegroundColor Yellow
            }
        }
        "4" {
            Write-Host "`n🚀 Başlangıç Programları:" -ForegroundColor Cyan
            try {
                Write-Log "Başlangıç programları sorgulanıyor" "INFO" "PerformanceTweaks"
                $startupApps = Get-CimInstance Win32_StartupCommand -ErrorAction Stop
                if ($startupApps) {
                    $startupApps | Select-Object Name, Command | Format-Table -AutoSize
                    Write-Log "Başlangıç programları görüntülendi" "SUCCESS" "PerformanceTweaks"
                } else {
                    Write-Host "   Başlangıç programı bulunamadı." -ForegroundColor Yellow
                }
            } catch {
                Write-Log "Başlangıç programları sorgusu hatası: $($_.Exception.Message)" "WARNING" "PerformanceTweaks"
                Write-Host "⚠️  Başlangıç programları alınamadı." -ForegroundColor Yellow
            }
        }
        "5" {
            Write-Host "`n🚀 FULL PERFORMANS OPTİMİZASYONU BAŞLIYOR..." -ForegroundColor Magenta
            Write-Log "Full performans optimizasyonu başlatılıyor" "INFO" "PerformanceTweaks"
            try {
                Backup-Registry -ModuleName "Performance_Full" | Out-Null
                
                Write-Host "   → Yüksek performans planı aktif ediliyor..." -ForegroundColor Yellow
                powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>&1 | Out-Null
                
                Write-Host "   → Görsel efektler azaltılıyor..." -ForegroundColor Yellow
                $visualPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
                if (-not (Test-Path $visualPath)) {
                    New-Item -Path $visualPath -Force | Out-Null
                }
                Set-ItemProperty -Path $visualPath -Name "VisualFXSetting" -Value 2 -Type DWord -Force -EA SilentlyContinue
                
                Write-Host "   → Arka plan hizmetleri optimize ediliyor..." -ForegroundColor Yellow
                $Services = @("SysMain","WSearch")
                foreach ($svc in $Services) {
                    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
                        Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
                    }
                }
                
                Write-Log "Full Performans Optimizasyonu tamamlandı" "SUCCESS" "PerformanceTweaks"
                Write-Host "✅ Tam performans optimizasyonu tamamlandı!" -ForegroundColor Green
            } catch {
                Write-Log "Full performans hatası: $($_.Exception.Message)" "ERROR" "PerformanceTweaks"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "0" { 
            Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan
            break 
        }
        default { 
            Write-Host "❌ Geçersiz seçim! Lütfen 0-5 arasında seçim yapın." -ForegroundColor Red 
        }
    }
    if ($perfChoice -ne "0") { 
        Read-Host "`nDevam etmek için Enter tuşuna basın..." 
    }
} while ($perfChoice -ne "0")
Clear-Host

Write-Log "PerformanceTweaks modülü kapatıldı" "SUCCESS" "PerformanceTweaks"