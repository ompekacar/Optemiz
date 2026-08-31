# =============================================
# SystemScan.ps1 - Sistem Taraması ve Onarım
# =============================================

Write-Log "Sistem Taraması ve Onarım modülü başladı" "INFO" "SystemScan"

function Show-SystemMenu {
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              🛠️  SİSTEM TARAMASI v2.1                         ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Write-Host "   1. Sistem Dosyalarını Tara (SFC)" -ForegroundColor Cyan
    Write-Host "   2. DISM Onarımı" -ForegroundColor Cyan
    Write-Host "   3. SFC + DISM Tam Onarım (Önerilen)" -ForegroundColor Magenta
    Write-Host "   4. Sistem Sağlığı Raporu" -ForegroundColor Cyan
    Write-Host "   5. Windows Güncellemelerini Kontrol Et" -ForegroundColor Cyan
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-SystemMenu
    $sysChoice = Read-Host

    switch ($sysChoice) {
        "1" { 
            Write-Host "`n🔍 SFC taraması başlatılıyor..." -ForegroundColor Yellow
            Write-Log "SFC taraması başlatılıyor" "INFO" "SystemScan"
            try {
                sfc /scannow 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "SFC taraması tamamlandı (Başarılı)" "SUCCESS" "SystemScan"
                    Write-Host "✅ SFC taraması tamamlandı." -ForegroundColor Green
                } else {
                    Write-Log "SFC taraması sorunla tamamlandı (Kod: $LASTEXITCODE)" "WARNING" "SystemScan"
                    Write-Host "⚠️  SFC taraması sorunla tamamlandı. Detaylar için log'a bakın." -ForegroundColor Yellow
                }
            } catch {
                Write-Log "SFC taraması hatası: $($_.Exception.Message)" "ERROR" "SystemScan"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "2" { 
            Write-Host "`n🔧 DISM onarımı başlatılıyor..." -ForegroundColor Yellow
            Write-Log "DISM onarımı başlatılıyor" "INFO" "SystemScan"
            try {
                DISM /Online /Cleanup-Image /RestoreHealth 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "DISM onarımı tamamlandı" "SUCCESS" "SystemScan"
                    Write-Host "✅ DISM onarımı tamamlandı." -ForegroundColor Green
                } else {
                    Write-Log "DISM onarımı sorunla tamamlandı (Kod: $LASTEXITCODE)" "WARNING" "SystemScan"
                    Write-Host "⚠️  DISM onarımı sorunla tamamlandı." -ForegroundColor Yellow
                }
            } catch {
                Write-Log "DISM onarımı hatası: $($_.Exception.Message)" "ERROR" "SystemScan"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "3" { 
            Write-Host "`n🚀 SFC + DISM Tam Onarımı başlatılıyor (uzun sürebilir)..." -ForegroundColor Magenta
            Write-Log "Tam sistem onarımı başlatılıyor" "INFO" "SystemScan"
            try {
                Backup-Registry -ModuleName "SystemRepair" | Out-Null
                
                Write-Host "   → SFC taraması başlıyor..." -ForegroundColor Yellow
                sfc /scannow 2>&1 | Out-Null
                Write-Log "SFC taraması tamamlandı" "SUCCESS" "SystemScan"
                
                Write-Host "   → DISM onarımı başlıyor..." -ForegroundColor Yellow
                DISM /Online /Cleanup-Image /RestoreHealth 2>&1 | Out-Null
                Write-Log "DISM onarımı tamamlandı" "SUCCESS" "SystemScan"
                
                Write-Log "Tam sistem onarımı başarıyla tamamlandı" "SUCCESS" "SystemScan"
                Write-Host "✅ Tam sistem onarımı tamamlandı." -ForegroundColor Green
            } catch {
                Write-Log "Tam sistem onarımı hatası: $($_.Exception.Message)" "ERROR" "SystemScan"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "4" { 
            Write-Host "`n📊 Sistem Sağlığı Raporu:" -ForegroundColor Cyan
            try {
                $compInfo = Get-ComputerInfo -ErrorAction Stop
                Write-Host ""
                Write-Host "   📌 İşletim Sistemi: $($compInfo.WindowsVersion)" -ForegroundColor White
                Write-Host "   🏗️  Mimari: $($compInfo.OsArchitecture)" -ForegroundColor White
                Write-Host "   🔢 Derleme: $($compInfo.OsBuildNumber)" -ForegroundColor White
                Write-Host "   💾 Toplam RAM: $([math]::Round($compInfo.CsTotalPhysicalMemory / 1GB, 2)) GB" -ForegroundColor White
                Write-Host "   ⚙️  İşlemci: $($compInfo.CsNumberOfProcessors) çekirdek" -ForegroundColor White
                Write-Log "Sistem sağlığı raporu görüntülendi" "SUCCESS" "SystemScan"
            } catch {
                Write-Log "Sistem raporu hatası: $($_.Exception.Message)" "WARNING" "SystemScan"
                Write-Host "⚠️  Sistem bilgileri alınamadı: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        "5" { 
            Write-Host "`n🔄 Windows Güncellemeleri kontrol ediliyor..." -ForegroundColor Yellow
            try {
                usoclient StartScan 2>&1 | Out-Null
                Write-Log "Windows Update taraması başlatıldı" "INFO" "SystemScan"
                Write-Host "✅ Güncelleme kontrolü başlatıldı. (Arka planda devam ediyor)" -ForegroundColor Green
            } catch {
                Write-Log "Windows Update hatası: $($_.Exception.Message)" "WARNING" "SystemScan"
                Write-Host "⚠️  Güncelleme kontrolü başlatılamadı. Daha sonra tekrar deneyiniz." -ForegroundColor Yellow
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
    if ($sysChoice -ne "0") { 
        Read-Host "`nDevam etmek için Enter tuşuna basın..." 
    }
} while ($sysChoice -ne "0")
Clear-Host

Write-Log "SystemScan modülü kapatıldı" "SUCCESS" "SystemScan"