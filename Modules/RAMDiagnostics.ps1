# =============================================
# RAMDiagnostics.ps1 - RAM Test ve Tanılama
# =============================================

Write-Log "RAM Test ve Tanılama modülü başladı" "INFO" "RAMDiagnostics"

function Show-RAMMenu {
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              🧠 RAM TANI VE TEST v2.1                        ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Write-Host "   1. RAM Bilgilerini Göster (Ayrıntılı)" -ForegroundColor Cyan
    Write-Host "   2. Windows Bellek Tanılama Aracını Çalıştır" -ForegroundColor Cyan
    Write-Host "   3. Mevcut RAM Kullanımını Göster" -ForegroundColor Cyan
    Write-Host "   4. RAM Sorunlarını Tara (SFC + DISM)" -ForegroundColor Cyan
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-RAMMenu
    $ramChoice = Read-Host

    switch ($ramChoice) {
        "1" { 
            Write-Host "`n🧠 Detaylı RAM bilgileri alınıyor..." -ForegroundColor Yellow
            Write-Log "Detaylı RAM bilgileri sorgulanıyor" "INFO" "RAMDiagnostics"
            try {
                $ramInfo = Get-WmiObject Win32_PhysicalMemory -ErrorAction Stop
                if ($ramInfo) {
                    Write-Host ""
                    $ramInfo | Select-Object `
                        @{Name="Üretici";Expression={$_.Manufacturer}},
                        @{Name="Kapasitesi";Expression={[math]::Round($_.Capacity/1GB, 2).ToString() + " GB"}},
                        @{Name="Hızı";Expression={$_.Speed.ToString() + " MHz"}},
                        @{Name="Banka";Expression={$_.BankLabel}},
                        @{Name="Konumu";Expression={$_.DeviceLocator}} | Format-Table -AutoSize
                    
                    Write-Log "RAM bilgileri başarıyla görüntülendi" "SUCCESS" "RAMDiagnostics"
                } else {
                    Write-Host "⚠️  RAM bilgileri alınamadı." -ForegroundColor Yellow
                }
            } catch {
                Write-Log "RAM sorgusu hatası: $($_.Exception.Message)" "ERROR" "RAMDiagnostics"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "2" { 
            Write-Host "`n⚠️  Windows Bellek Tanılama aracı başlatılacak!" -ForegroundColor Yellow
            $confirm = Read-Host "Bilgisayar yeniden başlatılacak. Devam etmek istiyor musunuz? (E/H)"
            if ($confirm -match '^[Ee]$') { 
                Write-Log "Windows Memory Diagnostic başlatıldı" "WARNING" "RAMDiagnostics"
                Write-Host "`n💻 Bilgisayar yeniden başlıyor..." -ForegroundColor Cyan
                Start-Sleep -Seconds 2
                try {
                    mdsched.exe 2>&1 | Out-Null
                } catch {
                    Write-Log "Memory Diagnostic başlatma hatası: $($_.Exception.Message)" "ERROR" "RAMDiagnostics"
                    Write-Host "⚠️  Memory Diagnostic başlatılamadı." -ForegroundColor Yellow
                }
            } else {
                Write-Log "Memory Diagnostic iptal edildi" "INFO" "RAMDiagnostics"
                Write-Host "⏭️  İptal edildi." -ForegroundColor Cyan
            }
        }
        "3" { 
            Write-Host "`n" -ForegroundColor Cyan
            try {
                $osInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
                $total = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 2)
                $free = [math]::Round($osInfo.FreePhysicalMemory / 1MB, 2)
                $used = [math]::Round($total - $free, 2)
                $usedPercent = [math]::Round(($used / $total) * 100, 1)
                
                Write-Host "╔════════════════ RAM DURUMU ════════════════╗" -ForegroundColor Cyan
                Write-Host "   Toplam RAM        : $total GB" -ForegroundColor White
                Write-Host "   Kullanılan RAM    : $used GB ($usedPercent%)" -ForegroundColor Yellow
                Write-Host "   Boş RAM           : $free GB" -ForegroundColor Green
                Write-Host "╚═══════════════════════════════════════════════╝" -ForegroundColor Cyan
                
                Write-Log "RAM kullanım durumu görüntülendi" "SUCCESS" "RAMDiagnostics"
            } catch {
                Write-Log "RAM kullanım sorgusu hatası: $($_.Exception.Message)" "ERROR" "RAMDiagnostics"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "4" { 
            Write-Host "`n🔧 RAM ile ilgili sistem taraması yapılıyor (uzun sürebilir)..." -ForegroundColor Yellow
            Write-Log "SFC + DISM (RAM taraması) başlatılıyor" "INFO" "RAMDiagnostics"
            try {
                Write-Host "   → SFC taraması başlıyor..." -ForegroundColor Yellow
                sfc /scannow 2>&1 | Out-Null
                
                Write-Host "   → DISM onarımı başlıyor..." -ForegroundColor Yellow
                DISM /Online /Cleanup-Image /RestoreHealth 2>&1 | Out-Null
                
                Write-Log "SFC + DISM (RAM taraması) tamamlandı" "SUCCESS" "RAMDiagnostics"
                Write-Host "✅ RAM sistem taraması tamamlandı." -ForegroundColor Green
            } catch {
                Write-Log "RAM taraması hatası: $($_.Exception.Message)" "ERROR" "RAMDiagnostics"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "0" { 
            Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan
            break 
        }
        default { 
            Write-Host "❌ Geçersiz seçim! Lütfen 0-4 arasında seçim yapın." -ForegroundColor Red 
        }
    }
    if ($ramChoice -ne "0") { 
        Read-Host "`nDevam etmek için Enter tuşuna basın..." 
    }
} while ($ramChoice -ne "0")
Clear-Host

Write-Log "RAMDiagnostics modülü kapatıldı" "SUCCESS" "RAMDiagnostics"