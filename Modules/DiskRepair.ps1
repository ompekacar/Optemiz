Write-Log "Disk Kontrol ve Onarım modülü başladı" "INFO"

function Show-DiskMenu {
    Clear-Host
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              💾 DİSK KONTROL VE ONARIM v2.1                  ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "   1. Tüm Diskleri ve Durumlarını Göster" -ForegroundColor Cyan
    Write-Host "   2. C: Sürücüsünü CHKDSK ile Tara" -ForegroundColor Cyan
    Write-Host "   3. Tüm Sürücüleri Tara" -ForegroundColor Cyan
    Write-Host "   4. Disk Temizleme Aracı" -ForegroundColor Cyan
    Write-Host "   5. SFC + DISM Onarımı" -ForegroundColor Cyan
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-DiskMenu
    $diskChoice = Read-Host

    switch ($diskChoice) {
        "1" {
            Write-Host "`n💾 Diskler listeleniyor..." -ForegroundColor Yellow
            Get-PhysicalDisk | Select FriendlyName, MediaType, HealthStatus, Size, OperationalStatus | Format-Table -AutoSize
            Write-Log "Disk durumu sorgulandı" "INFO"
        }
        "2" {
            Write-Host "`n⚠️ C: sürücüsü CHKDSK ile taranacak (yeniden başlatma gerekebilir)" -ForegroundColor Yellow
            $confirm = Read-Host "Devam etmek istiyor musunuz? (E/H)"
            if ($confirm -match '^[Ee]$') { 
                Write-Log "CHKDSK C: başlatıldı" "WARNING"
                chkdsk C: /f /r 
            }
        }
        "3" {
            Write-Host "`n🔄 Tüm sürücüler taranıyor..." -ForegroundColor Yellow
            Get-Volume | Where-Object DriveLetter | ForEach-Object {
                Write-Host "Taranıyor: $($_.DriveLetter):" -ForegroundColor Cyan
                chkdsk "$($_.DriveLetter):" /scan | Out-Null
            }
            Write-Log "Tüm diskler tarandı" "SUCCESS"
        }
        "4" {
            Write-Host "`n🧼 Disk Temizleme aracı açılıyor..." -ForegroundColor Yellow
            cleanmgr.exe
        }
        "5" {
            Write-Host "`n🔧 SFC + DISM onarımı başlatılıyor..." -ForegroundColor Yellow
            sfc /scannow
            DISM /Online /Cleanup-Image /RestoreHealth
            Write-Log "SFC + DISM onarımı tamamlandı" "SUCCESS"
        }
        "0" { Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan; break }
        default { Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red }
    }
    if ($diskChoice -ne "0") { Read-Host "`nDevam etmek için Enter tuşuna basın..." }
} while ($diskChoice -ne "0")
Clear-Host