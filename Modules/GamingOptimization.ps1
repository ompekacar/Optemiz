Write-Log "Oyun Optimizasyonu modülü başladı" "INFO"

function Show-GameMenu {
    Clear-Host
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              🎮 OYUN OPTİMİZASYONU v2.1                      ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "   1. Game Mode'u Aç" -ForegroundColor Cyan
    Write-Host "   2. Yüksek Performans + Game Mode" -ForegroundColor Cyan
    Write-Host "   3. Arka Plan Uygulamalarını Kısıtla" -ForegroundColor Cyan
    Write-Host "   4. ⚡ Full Gaming Optimization (Tümünü Yap)" -ForegroundColor Magenta
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-GameMenu
    $gameChoice = Read-Host

    switch ($gameChoice) {
        "1" {
            Write-Host "`n🎮 Game Mode aktif ediliyor..." -ForegroundColor Yellow
            reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f | Out-Null
            Write-Log "Game Mode aktif edildi" "SUCCESS"
            Write-Host "✅ Game Mode aktif edildi." -ForegroundColor Green
        }
        "2" {
            Write-Host "`n⚡ Yüksek Performans + Game Mode aktif ediliyor..." -ForegroundColor Yellow
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f | Out-Null
            Write-Log "Yüksek Performans + Game Mode aktif edildi" "SUCCESS"
            Write-Host "✅ Yüksek Performans + Game Mode aktif edildi." -ForegroundColor Green
        }
        "3" {
            Write-Host "`n🔇 Arka plan uygulamaları kısıtlanıyor..." -ForegroundColor Yellow
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f | Out-Null
            Write-Log "Arka plan uygulamaları kısıtlandı" "SUCCESS"
            Write-Host "✅ Arka plan uygulamaları kısıtlandı." -ForegroundColor Green
        }
        "4" {
            Write-Host "`n🚀 FULL GAMING OPTIMIZATION BAŞLIYOR..." -ForegroundColor Magenta
            Backup-Registry -ModuleName "Gaming"
            
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f | Out-Null
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f | Out-Null
            
            Write-Log "Full Gaming Optimization tamamlandı" "SUCCESS"
            Write-Host "✅ Tam oyun optimizasyonu uygulandı!" -ForegroundColor Green
        }
        "0" { Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan; break }
        default { Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red }
    }
    if ($gameChoice -ne "0") { Read-Host "`nDevam etmek için Enter tuşuna basın..." }
} while ($gameChoice -ne "0")
Clear-Host