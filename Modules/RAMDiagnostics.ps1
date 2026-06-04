Write-Log "RAM Test ve Tanılama modülü başladı" "INFO"

function Show-RAMMenu {
    Clear-Host
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              🧠 RAM TANI VE TEST v2.1                        ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "   1. RAM Bilgilerini Göster (Ayrıntılı)" -ForegroundColor Cyan
    Write-Host "   2. Windows Bellek Tanılama Aracını Çalıştır" -ForegroundColor Cyan
    Write-Host "   3. Mevcut RAM Kullanımını Göster" -ForegroundColor Cyan
    Write-Host "   4. RAM Sorunlarını Tara (SFC + DISM)" -ForegroundColor Cyan
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-RAMMenu
    $ramChoice = Read-Host

    switch ($ramChoice) {
        "1" { 
            Write-Host "`n🧠 Detaylı RAM bilgileri alınıyor..." -ForegroundColor Yellow
            Get-WmiObject Win32_PhysicalMemory | Select Manufacturer, Capacity, Speed, BankLabel, DeviceLocator | Format-Table -AutoSize
        }
        "2" { 
            Write-Host "`n⚠️ Windows Bellek Tanılama aracı başlatılacak!" -ForegroundColor Yellow
            $confirm = Read-Host "Bilgisayar yeniden başlatılacak. Devam etmek istiyor musunuz? (E/H)"
            if ($confirm -match '^[Ee]$') { 
                Write-Log "Windows Memory Diagnostic başlatıldı" "WARNING"
                mdsched.exe 
            }
        }
        "3" { 
            $total = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
            $free = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)
            Write-Host "`n╔════════════════ RAM DURUMU ════════════════╗" -ForegroundColor Cyan
            Write-Host "   Toplam RAM     : $total GB" -ForegroundColor White
            Write-Host "   Kullanılan     : $($total - $free) GB" -ForegroundColor Yellow
            Write-Host "   Boş RAM        : $free GB" -ForegroundColor Green
            Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
        }
        "4" { 
            Write-Host "`n🔧 RAM ile ilgili sistem taraması yapılıyor..." -ForegroundColor Yellow
            sfc /scannow
            DISM /Online /Cleanup-Image /RestoreHealth
            Write-Log "SFC + DISM (RAM taraması) tamamlandı" "SUCCESS"
        }
        "0" { Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan; break }
        default { Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red }
    }
    if ($ramChoice -ne "0") { Read-Host "`nDevam etmek için Enter tuşuna basın..." }
} while ($ramChoice -ne "0")
Clear-Host