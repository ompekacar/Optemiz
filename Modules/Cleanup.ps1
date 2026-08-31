# =============================================
# Cleanup.ps1 - Temizlik ve Optimizasyon
# =============================================

Write-Log "Temizlik ve Optimizasyon modülü başladı" "INFO" "Cleanup"

function Show-CleanupMenu {
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              🧹 TEMİZLİK VE OPTİMİZASYON v2.1                ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Write-Host "   1. Windows Disk Temizleme Aracı" -ForegroundColor Cyan
    Write-Host "   2. Geçici Dosyaları Temizle" -ForegroundColor Cyan
    Write-Host "   3. Önbellek ve Güncelleme Dosyalarını Temizle" -ForegroundColor Cyan
    Write-Host "   4. ⚡ Tam Temizlik (Önerilen)" -ForegroundColor Magenta
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-CleanupMenu
    $cleanChoice = Read-Host

    switch ($cleanChoice) {
        "1" {
            Write-Host "`n🧼 Windows Disk Temizleme aracı açılıyor..." -ForegroundColor Yellow
            Write-Log "Disk Temizleme aracı çalıştırılıyor" "INFO" "Cleanup"
            try {
                cleanmgr.exe /sagerun:1 2>&1 | Out-Null
                Write-Log "Disk Temizleme aracı başarıyla çalıştırıldı" "SUCCESS" "Cleanup"
                Write-Host "✅ Disk Temizleme aracı çalışıyor. Lütfen bekleyiniz..." -ForegroundColor Green
            } catch {
                Write-Log "Disk Temizleme hatası: $($_.Exception.Message)" "WARNING" "Cleanup"
                Write-Host "⚠️  Disk Temizleme açılamadı." -ForegroundColor Yellow
            }
        }
        "2" {
            Write-Host "`n🗑️  Geçici dosyalar temizleniyor..." -ForegroundColor Yellow
            Write-Log "Geçici dosyalar temizleniyor" "INFO" "Cleanup"
            try {
                $Before = 0
                $After = 0
                
                # Temp klasörleri temizle
                if (Test-Path "$env:TEMP") {
                    $Before = [math]::Round((Get-ChildItem "$env:TEMP" -Recurse -Force -EA SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB, 1)
                    Remove-Item "$env:TEMP\*" -Recurse -Force -EA SilentlyContinue
                }
                
                if (Test-Path "C:\Windows\Temp") {
                    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -EA SilentlyContinue
                }
                
                if (Test-Path "$env:TEMP") {
                    $After = [math]::Round((Get-ChildItem "$env:TEMP" -Recurse -Force -EA SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB, 1)
                }
                
                $Freed = [math]::Round($Before - $After, 1)
                Write-Log "Geçici dosyalar temizlendi - $Freed MB boşaltıldı" "SUCCESS" "Cleanup"
                Write-Host "✅ Geçici dosyalar temizlendi. Boşaltılan alan: $Freed MB" -ForegroundColor Green
            } catch {
                Write-Log "Geçici dosya temizleme hatası: $($_.Exception.Message)" "WARNING" "Cleanup"
                Write-Host "⚠️  Bazı dosyalar temizlenemedi, devam ediliyor..." -ForegroundColor Yellow
            }
        }
        "3" {
            Write-Host "`n🔄 Önbellek ve güncelleme dosyaları temizleniyor..." -ForegroundColor Yellow
            Write-Log "Önbellek temizleniyor" "INFO" "Cleanup"
            try {
                @(
                    "C:\Windows\Prefetch\*",
                    "C:\Windows\SoftwareDistribution\Download\*",
                    "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*"
                ) | ForEach-Object {
                    if (Test-Path $_) {
                        Remove-Item $_ -Recurse -Force -EA SilentlyContinue
                    }
                }
                
                Write-Log "Önbellek temizlendi" "SUCCESS" "Cleanup"
                Write-Host "✅ Önbellek ve güncelleme dosyaları temizlendi." -ForegroundColor Green
            } catch {
                Write-Log "Önbellek temizleme hatası: $($_.Exception.Message)" "WARNING" "Cleanup"
                Write-Host "⚠️  Bazı önbellek dosyaları temizlenemedi." -ForegroundColor Yellow
            }
        }
        "4" {
            Write-Host "`n🚀 TAM TEMİZLİK MODU BAŞLIYOR..." -ForegroundColor Magenta
            Write-Log "Tam temizlik işlemi başlatılıyor" "INFO" "Cleanup"
            try {
                Backup-Registry -ModuleName "Cleanup" | Out-Null
                
                # Tüm temizlik işlemleri
                Write-Host "   → Geçici dosyalar temizleniyor..." -ForegroundColor Yellow
                @(
                    "$env:TEMP\*",
                    "C:\Windows\Temp\*",
                    "C:\Windows\Prefetch\*"
                ) | ForEach-Object {
                    if (Test-Path $_) {
                        Remove-Item $_ -Recurse -Force -EA SilentlyContinue
                    }
                }
                
                Write-Host "   → Disk Temizleme aracı çalıştırılıyor..." -ForegroundColor Yellow
                cleanmgr.exe /verylowdisk 2>&1 | Out-Null
                
                Write-Log "Tam temizlik paketi başarıyla uygulandı" "SUCCESS" "Cleanup"
                Write-Host "✅ Tam temizlik işlemleri tamamlandı!" -ForegroundColor Green
            } catch {
                Write-Log "Tam temizlik hatası: $($_.Exception.Message)" "ERROR" "Cleanup"
                Write-Host "❌ Tam temizlik sırasında hata: $($_.Exception.Message)" -ForegroundColor Red
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
    if ($cleanChoice -ne "0") { 
        Read-Host "`nDevam etmek için Enter tuşuna basın..." 
    }
} while ($cleanChoice -ne "0")
Clear-Host

Write-Log "Cleanup modülü kapatıldı" "SUCCESS" "Cleanup"