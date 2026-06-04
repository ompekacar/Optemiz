Write-Log "Performans Optimizasyonu modülü başladı" "INFO"

function Show-PerfMenu {
    Clear-Host
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              ⚡ PERFORMANS OPTİMİZASYONU v2.1                ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "   1. Yüksek Performans Güç Planı" -ForegroundColor Cyan
    Write-Host "   2. Görsel Efektleri Azalt" -ForegroundColor Cyan
    Write-Host "   3. Hizmetleri Optimize Et" -ForegroundColor Cyan
    Write-Host "   4. Başlangıç Programlarını Göster" -ForegroundColor Cyan
    Write-Host "   5. ⚡ Full Performance Optimization" -ForegroundColor Magenta
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-PerfMenu
    $perfChoice = Read-Host

    switch ($perfChoice) {
        "1" {
            Write-Host "`n⚡ Yüksek Performans planı aktif ediliyor..." -ForegroundColor Yellow
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            Write-Log "Yüksek Performans planı aktif edildi" "SUCCESS"
            Write-Host "✅ Yüksek Performans planı aktif edildi." -ForegroundColor Green
        }
        "2" {
            Write-Host "`n🎨 Görsel efektler azaltılıyor..." -ForegroundColor Yellow
            Backup-Registry -ModuleName "VisualEffects"
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Type DWord -Force
            Write-Host "✅ Görsel efektler performans için azaltıldı." -ForegroundColor Green
        }
        "3" {
            Write-Host "`n🔧 Hizmetler optimize ediliyor..." -ForegroundColor Yellow
            Backup-Registry -ModuleName "Services"
            $Services = @("SysMain","WSearch","DiagTrack","dps","XblAuthManager","XblGameSave")
            foreach ($svc in $Services) {
                if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
                    Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
                }
            }
            Write-Host "✅ Hizmet optimizasyonu uygulandı." -ForegroundColor Green
            Write-Log "Hizmet optimizasyonu tamamlandı" "SUCCESS"
        }
        "4" {
            Write-Host "`n🚀 Başlangıç Programları:" -ForegroundColor Cyan
            Get-CimInstance Win32_StartupCommand | Select Name, Command | Format-Table -AutoSize
        }
        "5" {
            Write-Host "`n🚀 FULL PERFORMANS OPTİMİZASYONU BAŞLIYOR..." -ForegroundColor Magenta
            Backup-Registry -ModuleName "Performance_Full"
            
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Type DWord -Force
            
            Write-Host "✅ Tam performans optimizasyonu tamamlandı!" -ForegroundColor Green
            Write-Log "Full Performance Optimization tamamlandı" "SUCCESS"
        }
        "0" { Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan; break }
        default { Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red }
    }
    if ($perfChoice -ne "0") { Read-Host "`nDevam etmek için Enter tuşuna basın..." }
} while ($perfChoice -ne "0")
Clear-Host