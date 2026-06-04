Write-Log "Temizlik ve Optimizasyon modülü başladı" "INFO"

function Show-CleanupMenu {
    Clear-Host
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              🧹 TEMİZLİK VE OPTİMİZASYON v2.1                ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "   1. Windows Disk Temizleme Aracı" -ForegroundColor Cyan
    Write-Host "   2. Geçici Dosyaları Temizle" -ForegroundColor Cyan
    Write-Host "   3. Önbellek ve Güncelleme Dosyalarını Temizle" -ForegroundColor Cyan
    Write-Host "   4. ⚡ Tam Temizlik (Önerilen)" -ForegroundColor Magenta
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-CleanupMenu
    $cleanChoice = Read-Host

    switch ($cleanChoice) {
        "1" {
            Write-Host "`n🧼 Windows Disk Temizleme aracı açılıyor..." -ForegroundColor Yellow
            cleanmgr.exe /sagerun:1
            Write-Log "Disk Temizleme aracı çalıştırıldı" "INFO"
        }
        "2" {
            Write-Host "`n🗑️ Geçici dosyalar temizleniyor..." -ForegroundColor Yellow
            $Before = [math]::Round((Get-ChildItem "$env:TEMP","C:\Windows\Temp" -Recurse -Force -EA SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB, 1)
            
            Remove-Item "$env:TEMP\*", "C:\Windows\Temp\*" -Recurse -Force -EA SilentlyContinue
            
            $After = [math]::Round((Get-ChildItem "$env:TEMP","C:\Windows\Temp" -Recurse -Force -EA SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB, 1)
            $Freed = [math]::Round($Before - $After, 1)
            
            Write-Host "✅ Geçici dosyalar temizlendi. Yaklaşık $Freed MB alan kazanıldı." -ForegroundColor Green
            Write-Log "Geçici dosyalar temizlendi - $Freed MB" "SUCCESS"
        }
        "3" {
            Write-Host "`n🔄 Önbellek dosyaları temizleniyor..." -ForegroundColor Yellow
            Remove-Item "C:\Windows\Prefetch\*", "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -EA SilentlyContinue
            Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Recurse -Force -EA SilentlyContinue
            Write-Host "✅ Önbellek temizlendi." -ForegroundColor Green
            Write-Log "Önbellek temizlendi" "SUCCESS"
        }
        "4" {
            Write-Host "`n🚀 TAM TEMİZLİK MODU BAŞLIYOR..." -ForegroundColor Magenta
            Backup-Registry -ModuleName "Cleanup"
            
            # Tüm temizlik işlemleri
            Remove-Item "$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*" -Recurse -Force -EA SilentlyContinue
            cleanmgr.exe /verylowdisk | Out-Null
            
            Write-Host "✅ Tam temizlik işlemleri tamamlandı!" -ForegroundColor Green
            Write-Log "Tam temizlik paketi uygulandı" "SUCCESS"
        }
        "0" { Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan; break }
        default { Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red }
    }
    if ($cleanChoice -ne "0") { Read-Host "`nDevam etmek için Enter tuşuna basın..." }
} while ($cleanChoice -ne "0")
Clear-Host