Write-Log "Ağ Optimizasyonu modülü başladı" "INFO"

function Show-NetMenu {
    Clear-Host
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              🌐 AĞ OPTİMİZASYONU v2.1                        ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "   1. IP Yenile ve DNS Flush" -ForegroundColor Cyan
    Write-Host "   2. Ağ Adaptörlerini Sıfırla" -ForegroundColor Cyan
    Write-Host "   3. DNS Sunucularını Google Yap" -ForegroundColor Cyan
    Write-Host "   4. Ağ Durumunu Göster" -ForegroundColor Cyan
    Write-Host "   5. ⚡ Tam Ağ Optimizasyonu (Önerilen)" -ForegroundColor Magenta
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-NetMenu
    $netChoice = Read-Host

    switch ($netChoice) {
        "1" { 
            Write-Host "`n🔄 IP yenileniyor ve DNS temizleniyor..." -ForegroundColor Yellow
            ipconfig /flushdns | Out-Null
            ipconfig /release | Out-Null
            ipconfig /renew | Out-Null
            Write-Host "✅ IP ve DNS yenilendi." -ForegroundColor Green
            Write-Log "IP yenileme ve DNS flush yapıldı" "SUCCESS"
        }
        "2" {
            Write-Host "`n⚠️ Ağ adaptörleri sıfırlanıyor..." -ForegroundColor Yellow
            Backup-Registry -ModuleName "Network"
            netsh winsock reset | Out-Null
            netsh int ip reset | Out-Null
            Write-Host "✅ Ağ sıfırlama tamamlandı. Yeniden başlatmanızı öneririm." -ForegroundColor Green
            Write-Log "Ağ adaptörleri sıfırlandı" "WARNING"
        }
        "3" {
            Write-Host "`n🌍 DNS Google olarak ayarlanıyor..." -ForegroundColor Yellow
            netsh interface ip set dns "Wi-Fi" static 8.8.8.8 | Out-Null
            netsh interface ip add dns "Wi-Fi" 8.8.4.4 index=2 | Out-Null
            netsh interface ip set dns "Ethernet" static 8.8.8.8 | Out-Null
            Write-Host "✅ DNS Google olarak değiştirildi." -ForegroundColor Green
            Write-Log "DNS Google olarak ayarlandı" "SUCCESS"
        }
        "4" {
            Write-Host "`n📡 Mevcut Ağ Durumu:" -ForegroundColor Cyan
            Get-NetAdapter | Select Name, Status, LinkSpeed, MacAddress | Format-Table -AutoSize
        }
        "5" {
            Write-Host "`n🚀 TAM AĞ OPTİMİZASYONU BAŞLIYOR..." -ForegroundColor Magenta
            Backup-Registry -ModuleName "Network_Full"
            ipconfig /flushdns | Out-Null
            ipconfig /renew | Out-Null
            netsh winsock reset | Out-Null
            Write-Host "✅ Tam ağ optimizasyonu tamamlandı!" -ForegroundColor Green
            Write-Log "Tam ağ optimizasyonu uygulandı" "SUCCESS"
        }
        "0" { Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan; break }
        default { Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red }
    }
    if ($netChoice -ne "0") { Read-Host "`nDevam etmek için Enter tuşuna basın..." }
} while ($netChoice -ne "0")
Clear-Host