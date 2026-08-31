# =============================================
# DiskRepair.ps1 - Disk Kontrol ve Onarım
# =============================================

Write-Log "Disk Kontrol ve Onarım modülü başladı" "INFO" "DiskRepair"

function Show-DiskMenu {
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              💾 DİSK KONTROL VE ONARIM v2.1                  ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Write-Host "   1. Tüm Diskleri ve Durumlarını Göster" -ForegroundColor Cyan
    Write-Host "   2. C: Sürücüsünü CHKDSK ile Tara" -ForegroundColor Cyan
    Write-Host "   3. Tüm Sürücüleri Tara" -ForegroundColor Cyan
    Write-Host "   4. Disk Temizleme Aracı" -ForegroundColor Cyan
    Write-Host "   5. SFC + DISM Onarımı" -ForegroundColor Cyan
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-DiskMenu
    $diskChoice = Read-Host

    switch ($diskChoice) {
        "1" {
            Write-Host "`n💾 Diskler listeleniyor..." -ForegroundColor Yellow
            Write-Log "Disk durumu sorgulanıyor" "INFO" "DiskRepair"
            try {
                $disks = Get-PhysicalDisk -ErrorAction Stop
                if ($disks) {
                    $disks | Select-Object FriendlyName, MediaType, HealthStatus, Size, OperationalStatus | 
                        Format-Table -AutoSize
                    Write-Log "Disk bilgileri başarıyla görüntülendi" "SUCCESS" "DiskRepair"
                } else {
                    Write-Host "⚠️  Disk bilgileri alınamadı." -ForegroundColor Yellow
                }
            } catch {
                Write-Log "Disk sorgusu hatası: $($_.Exception.Message)" "WARNING" "DiskRepair"
                Write-Host "⚠️  Disk bilgileri alınamadı: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        "2" {
            Write-Host "`n⚠️  C: sürücüsü CHKDSK ile taranacak (yeniden başlatma gerekebilir)" -ForegroundColor Yellow
            $confirm = Read-Host "Devam etmek istiyor musunuz? (E/H)"
            if ($confirm -match '^[Ee]$') { 
                Write-Log "CHKDSK C: başlatıldı" "WARNING" "DiskRepair"
                try {
                    Write-Host "`n🔍 Tarama başlıyor..." -ForegroundColor Yellow
                    chkdsk C: /f /r 2>&1 | Out-Null
                    Write-Log "CHKDSK C: tamamlandı" "SUCCESS" "DiskRepair"
                    Write-Host "✅ Tarama tamamlandı." -ForegroundColor Green
                } catch {
                    Write-Log "CHKDSK hatası: $($_.Exception.Message)" "ERROR" "DiskRepair"
                    Write-Host "❌ Hata: $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Log "CHKDSK iptal edildi" "INFO" "DiskRepair"
                Write-Host "⏭️  İptal edildi." -ForegroundColor Cyan
            }
        }
        "3" {
            Write-Host "`n🔄 Tüm sürücüler taranıyor..." -ForegroundColor Yellow
            Write-Log "Tüm disk taraması başlatılıyor" "INFO" "DiskRepair"
            try {
                $volumes = Get-Volume -ErrorAction Stop | Where-Object DriveLetter
                $scanCount = 0
                
                foreach ($vol in $volumes) {
                    Write-Host "   → Taranıyor: $($vol.DriveLetter):" -ForegroundColor Yellow
                    chkdsk "$($vol.DriveLetter):" /scan 2>&1 | Out-Null
                    $scanCount++
                }
                
                Write-Log "Tüm diskler tarandı ($scanCount sürücü)" "SUCCESS" "DiskRepair"
                Write-Host "✅ Tüm sürücü taraması tamamlandı ($scanCount sürücü)." -ForegroundColor Green
            } catch {
                Write-Log "Disk taraması hatası: $($_.Exception.Message)" "ERROR" "DiskRepair"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "4" {
            Write-Host "`n🧼 Disk Temizleme aracı açılıyor..." -ForegroundColor Yellow
            Write-Log "Disk Temizleme aracı açılıyor" "INFO" "DiskRepair"
            try {
                cleanmgr.exe 2>&1 | Out-Null
                Write-Log "Disk Temizleme aracı çalıştırıldı" "SUCCESS" "DiskRepair"
            } catch {
                Write-Log "Disk Temizleme hatası: $($_.Exception.Message)" "WARNING" "DiskRepair"
                Write-Host "⚠️  Disk Temizleme aracı açılamadı." -ForegroundColor Yellow
            }
        }
        "5" {
            Write-Host "`n🔧 SFC + DISM onarımı başlatılıyor (uzun sürebilir)..." -ForegroundColor Yellow
            Write-Log "SFC + DISM onarımı başlatılıyor" "INFO" "DiskRepair"
            try {
                Write-Host "   → SFC taraması başlıyor..." -ForegroundColor Yellow
                sfc /scannow 2>&1 | Out-Null
                Write-Log "SFC taraması tamamlandı" "SUCCESS" "DiskRepair"
                
                Write-Host "   → DISM onarımı başlıyor..." -ForegroundColor Yellow
                DISM /Online /Cleanup-Image /RestoreHealth 2>&1 | Out-Null
                Write-Log "DISM onarımı tamamlandı" "SUCCESS" "DiskRepair"
                
                Write-Host "✅ SFC + DISM onarımı tamamlandı." -ForegroundColor Green
            } catch {
                Write-Log "SFC + DISM onarımı hatası: $($_.Exception.Message)" "ERROR" "DiskRepair"
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
    if ($diskChoice -ne "0") { 
        Read-Host "`nDevam etmek için Enter tuşuna basın..." 
    }
} while ($diskChoice -ne "0")
Clear-Host

Write-Log "DiskRepair modülü kapatıldı" "SUCCESS" "DiskRepair"