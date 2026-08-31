# =============================================
# GamingOptimization.ps1 - Oyun Optimizasyonu
# =============================================

Write-Log "Oyun Optimizasyonu modülü başladı" "INFO" "GamingOptimization"

function Show-GameMenu {
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              🎮 OYUN OPTİMİZASYONU v2.1                      ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Write-Host "   1. Game Mode'u Aç" -ForegroundColor Cyan
    Write-Host "   2. Yüksek Performans + Game Mode" -ForegroundColor Cyan
    Write-Host "   3. Arka Plan Uygulamalarını Kısıtla" -ForegroundColor Cyan
    Write-Host "   4. ⚡ Full Gaming Optimization (Tümünü Yap)" -ForegroundColor Magenta
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-GameMenu
    $gameChoice = Read-Host

    switch ($gameChoice) {
        "1" {
            Write-Host "`n🎮 Game Mode aktif ediliyor..." -ForegroundColor Yellow
            Write-Log "Game Mode aktif ediliyor" "INFO" "GamingOptimization"
            try {
                $gamePath = "HKCU:\Software\Microsoft\GameBar"
                if (-not (Test-Path $gamePath)) {
                    New-Item -Path $gamePath -Force | Out-Null
                }
                Set-ItemProperty -Path $gamePath -Name "AllowAutoGameMode" -Value 1 -Type DWord -Force -EA SilentlyContinue
                
                Write-Log "Game Mode aktif edildi" "SUCCESS" "GamingOptimization"
                Write-Host "✅ Game Mode aktif edildi." -ForegroundColor Green
            } catch {
                Write-Log "Game Mode hatası: $($_.Exception.Message)" "WARNING" "GamingOptimization"
                Write-Host "⚠️  Game Mode aktif edilemedi." -ForegroundColor Yellow
            }
        }
        "2" {
            Write-Host "`n⚡ Yüksek Performans + Game Mode aktif ediliyor..." -ForegroundColor Yellow
            Write-Log "Yüksek Performans + Game Mode aktif ediliyor" "INFO" "GamingOptimization"
            try {
                Write-Host "   → Yüksek Performans planı aktif ediliyor..." -ForegroundColor Yellow
                powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>&1 | Out-Null
                
                Write-Host "   → Game Mode aktif ediliyor..." -ForegroundColor Yellow
                $gamePath = "HKCU:\Software\Microsoft\GameBar"
                if (-not (Test-Path $gamePath)) {
                    New-Item -Path $gamePath -Force | Out-Null
                }
                Set-ItemProperty -Path $gamePath -Name "AllowAutoGameMode" -Value 1 -Type DWord -Force -EA SilentlyContinue
                
                Write-Log "Yüksek Performans + Game Mode aktif edildi" "SUCCESS" "GamingOptimization"
                Write-Host "✅ Yüksek Performans + Game Mode aktif edildi." -ForegroundColor Green
            } catch {
                Write-Log "Performans + Game Mode hatası: $($_.Exception.Message)" "ERROR" "GamingOptimization"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "3" {
            Write-Host "`n🔇 Arka plan uygulamaları kısıtlanıyor..." -ForegroundColor Yellow
            Write-Log "Arka plan uygulamaları kısıtlanıyor" "INFO" "GamingOptimization"
            try {
                $appPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
                if (-not (Test-Path $appPath)) {
                    New-Item -Path $appPath -Force | Out-Null
                }
                Set-ItemProperty -Path $appPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force -EA SilentlyContinue
                
                Write-Log "Arka plan uygulamaları kısıtlandı" "SUCCESS" "GamingOptimization"
                Write-Host "✅ Arka plan uygulamaları kısıtlandı." -ForegroundColor Green
            } catch {
                Write-Log "Arka plan uygulamaları hatası: $($_.Exception.Message)" "WARNING" "GamingOptimization"
                Write-Host "⚠️  Arka plan uygulamaları kısmen kısıtlandı." -ForegroundColor Yellow
            }
        }
        "4" {
            Write-Host "`n🚀 FULL GAMING OPTIMIZATION BAŞLIYOR..." -ForegroundColor Magenta
            Write-Log "Full gaming optimization başlatılıyor" "INFO" "GamingOptimization"
            try {
                Backup-Registry -ModuleName "Gaming" | Out-Null
                
                Write-Host "   → Yüksek Performans planı aktif ediliyor..." -ForegroundColor Yellow
                powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>&1 | Out-Null
                
                Write-Host "   → Game Mode aktif ediliyor..." -ForegroundColor Yellow
                $gamePath = "HKCU:\Software\Microsoft\GameBar"
                if (-not (Test-Path $gamePath)) {
                    New-Item -Path $gamePath -Force | Out-Null
                }
                Set-ItemProperty -Path $gamePath -Name "AllowAutoGameMode" -Value 1 -Type DWord -Force -EA SilentlyContinue
                
                Write-Host "   → Arka plan uygulamaları kısıtlanıyor..." -ForegroundColor Yellow
                $appPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
                if (-not (Test-Path $appPath)) {
                    New-Item -Path $appPath -Force | Out-Null
                }
                Set-ItemProperty -Path $appPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force -EA SilentlyContinue
                
                Write-Log "Full Gaming Optimization tamamlandı" "SUCCESS" "GamingOptimization"
                Write-Host "✅ Tam oyun optimizasyonu uygulandı!" -ForegroundColor Green
            } catch {
                Write-Log "Full gaming optimization hatası: $($_.Exception.Message)" "ERROR" "GamingOptimization"
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
    if ($gameChoice -ne "0") { 
        Read-Host "`nDevam etmek için Enter tuşuna basın..." 
    }
} while ($gameChoice -ne "0")
Clear-Host

Write-Log "GamingOptimization modülü kapatıldı" "SUCCESS" "GamingOptimization"