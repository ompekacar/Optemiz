# =============================================
# NetworkOptimization.ps1 - Ağ Optimizasyonu
# =============================================

Write-Log "Ağ Optimizasyonu modülü başladı" "INFO" "NetworkOptimization"

function Show-NetMenu {
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              🌐 AĞ OPTİMİZASYONU v2.1                        ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Write-Host "   1. IP Yenile ve DNS Flush" -ForegroundColor Cyan
    Write-Host "   2. Ağ Adaptörlerini Sıfırla" -ForegroundColor Cyan
    Write-Host "   3. DNS Sunucularını Google Yap" -ForegroundColor Cyan
    Write-Host "   4. Ağ Durumunu Göster" -ForegroundColor Cyan
    Write-Host "   5. ⚡ Tam Ağ Optimizasyonu (Önerilen)" -ForegroundColor Magenta
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-NetMenu
    $netChoice = Read-Host

    switch ($netChoice) {
        "1" { 
            Write-Host "`n🔄 IP yenileniyor ve DNS temizleniyor..." -ForegroundColor Yellow
            Write-Log "IP yenileme ve DNS flush başlatılıyor" "INFO" "NetworkOptimization"
            try {
                ipconfig /flushdns 2>&1 | Out-Null
                ipconfig /release 2>&1 | Out-Null
                ipconfig /renew 2>&1 | Out-Null
                
                Write-Log "IP yenileme ve DNS flush yapıldı" "SUCCESS" "NetworkOptimization"
                Write-Host "✅ IP ve DNS yenilendi." -ForegroundColor Green
            } catch {
                Write-Log "IP yenileme hatası: $($_.Exception.Message)" "WARNING" "NetworkOptimization"
                Write-Host "⚠️  IP yenilenemedi." -ForegroundColor Yellow
            }
        }
        "2" {
            Write-Host "`n⚠️  Ağ adaptörleri sıfırlanıyor (Yeniden başlatma önerilir)..." -ForegroundColor Yellow
            Write-Log "Ağ adaptörleri sıfırlanıyor" "INFO" "NetworkOptimization"
            try {
                Backup-Registry -ModuleName "Network" | Out-Null
                
                netsh winsock reset 2>&1 | Out-Null
                netsh int ip reset 2>&1 | Out-Null
                
                Write-Log "Ağ adaptörleri sıfırlandı" "SUCCESS" "NetworkOptimization"
                Write-Host "✅ Ağ sıfırlama tamamlandı. Yeniden başlatmanızı öneririm." -ForegroundColor Green
            } catch {
                Write-Log "Ağ sıfırlama hatası: $($_.Exception.Message)" "ERROR" "NetworkOptimization"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "3" {
            Write-Host "`n🌍 DNS Google olarak ayarlanıyor..." -ForegroundColor Yellow
            Write-Log "DNS ayarları değiştiriliyor (Google)" "INFO" "NetworkOptimization"
            try {
                netsh interface ip set dns "Wi-Fi" static 8.8.8.8 2>&1 | Out-Null
                netsh interface ip add dns "Wi-Fi" 8.8.4.4 index=2 2>&1 | Out-Null
                netsh interface ip set dns "Ethernet" static 8.8.8.8 2>&1 | Out-Null
                netsh interface ip add dns "Ethernet" 8.8.4.4 index=2 2>&1 | Out-Null
                
                Write-Log "DNS Google olarak ayarlandı" "SUCCESS" "NetworkOptimization"
                Write-Host "✅ DNS Google olarak değiştirildi (8.8.8.8, 8.8.4.4)." -ForegroundColor Green
            } catch {
                Write-Log "DNS ayarı hatası: $($_.Exception.Message)" "WARNING" "NetworkOptimization"
                Write-Host "⚠️  DNS ayarı yapılamadı. Ağ adaptörü adını kontrol edin." -ForegroundColor Yellow
            }
        }
        "4" {
            Write-Host "`n📡 Mevcut Ağ Durumu:" -ForegroundColor Cyan
            Write-Log "Ağ durumu sorgulanıyor" "INFO" "NetworkOptimization"
            try {
                $netAdapters = Get-NetAdapter -ErrorAction Stop
                if ($netAdapters) {
                    $netAdapters | Select-Object Name, Status, LinkSpeed, MacAddress | Format-Table -AutoSize
                    Write-Log "Ağ durumu görüntülendi" "SUCCESS" "NetworkOptimization"
                } else {
                    Write-Host "   Ağ adaptörü bulunamadı." -ForegroundColor Yellow
                }
            } catch {
                Write-Log "Ağ sorgusu hatası: $($_.Exception.Message)" "WARNING" "NetworkOptimization"
                Write-Host "⚠️  Ağ bilgileri alınamadı." -ForegroundColor Yellow
            }
        }
        "5" {
            Write-Host "`n🚀 TAM AĞ OPTİMİZASYONU BAŞLIYOR..." -ForegroundColor Magenta
            Write-Log "Tam ağ optimizasyonu başlatılıyor" "INFO" "NetworkOptimization"
            try {
                Backup-Registry -ModuleName "Network_Full" | Out-Null
                
                Write-Host "   → DNS Flush yapılıyor..." -ForegroundColor Yellow
                ipconfig /flushdns 2>&1 | Out-Null
                
                Write-Host "   → IP yenileniyor..." -ForegroundColor Yellow
                ipconfig /release 2>&1 | Out-Null
                ipconfig /renew 2>&1 | Out-Null
                
                Write-Host "   → Ağ sıfırlanıyor..." -ForegroundColor Yellow
                netsh winsock reset 2>&1 | Out-Null
                
                Write-Log "Tam ağ optimizasyonu uygulandı" "SUCCESS" "NetworkOptimization"
                Write-Host "✅ Tam ağ optimizasyonu tamamlandı!" -ForegroundColor Green
            } catch {
                Write-Log "Tam ağ optimizasyonu hatası: $($_.Exception.Message)" "ERROR" "NetworkOptimization"
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
    if ($netChoice -ne "0") { 
        Read-Host "`nDevam etmek için Enter tuşuna basın..." 
    }
} while ($netChoice -ne "0")
Clear-Host

Write-Log "NetworkOptimization modülü kapatıldı" "SUCCESS" "NetworkOptimization"