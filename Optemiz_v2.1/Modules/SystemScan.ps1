Write-Log "Sistem Taraması ve Onarım modülü başladı" "INFO"

function Show-SystemMenu {
    Clear-Host
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              🛠️ SİSTEM TARAMASI v2.1                         ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "   1. Sistem Dosyalarını Tara (SFC)" -ForegroundColor Cyan
    Write-Host "   2. DISM Onarımı" -ForegroundColor Cyan
    Write-Host "   3. SFC + DISM Tam Onarım (Önerilen)" -ForegroundColor Magenta
    Write-Host "   4. Sistem Sağlığı Raporu" -ForegroundColor Cyan
    Write-Host "   5. Windows Güncellemelerini Kontrol Et" -ForegroundColor Cyan
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-SystemMenu
    $sysChoice = Read-Host

    switch ($sysChoice) {
        "1" { 
            Write-Host "`n🔍 SFC taraması başlatılıyor..." -ForegroundColor Yellow
            sfc /scannow 
            Write-Log "SFC taraması tamamlandı" "SUCCESS"
        }
        "2" { 
            Write-Host "`n🔧 DISM onarımı başlatılıyor..." -ForegroundColor Yellow
            DISM /Online /Cleanup-Image /RestoreHealth 
            Write-Log "DISM onarımı tamamlandı" "SUCCESS"
        }
        "3" { 
            Write-Host "`n🚀 SFC + DISM Tam Onarımı başlatılıyor (uzun sürebilir)..." -ForegroundColor Magenta
            Backup-Registry -ModuleName "SystemRepair"
            sfc /scannow
            DISM /Online /Cleanup-Image /RestoreHealth 
            Write-Log "Tam sistem onarımı tamamlandı" "SUCCESS"
            Write-Host "✅ Tam sistem onarımı tamamlandı." -ForegroundColor Green
        }
        "4" { 
            Write-Host "`n📊 Sistem Sağlığı Raporu:" -ForegroundColor Cyan
            Get-ComputerInfo | Select WindowsVersion, OsArchitecture, OsBuildNumber, CsTotalPhysicalMemory, CsNumberOfProcessors | Format-List
            Write-Log "Sistem sağlığı raporu görüntülendi" "INFO"
        }
        "5" { 
            Write-Host "`n🔄 Windows Güncellemeleri kontrol ediliyor..." -ForegroundColor Yellow
            usoclient StartScan | Out-Null
            Write-Host "✅ Güncelleme kontrolü başlatıldı." -ForegroundColor Green
            Write-Log "Windows Update taraması başlatıldı" "INFO"
        }
        "0" { Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan; break }
        default { Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red }
    }
    if ($sysChoice -ne "0") { Read-Host "`nDevam etmek için Enter tuşuna basın..." }
} while ($sysChoice -ne "0")
Clear-Host