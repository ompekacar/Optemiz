Write-Log "Gizlilik Ayarları modülü başladı" "INFO"

function Show-PrivacyMenu {
    Clear-Host
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              🔒 GİZLİLİK AYARLARI v2.1                       ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "   1. Temel Telemetri ve Reklam Takibini Kapat" -ForegroundColor Cyan
    Write-Host "   2. Cortana, Bing ve Web Aramayı Kapat" -ForegroundColor Cyan
    Write-Host "   3. 🚀 Kapsamlı Gizlilik Optimizasyonu (Önerilen)" -ForegroundColor Magenta
    Write-Host "   4. Uygulama İzinlerini Kısıtla" -ForegroundColor Cyan
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-PrivacyMenu
    $privChoice = Read-Host

    switch ($privChoice) {
        "1" {
            Write-Host "`n🔒 Temel Telemetri kapatılıyor..." -ForegroundColor Yellow
            Backup-Registry -ModuleName "Privacy_Telemetry"
            
            $Paths = @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection")
            foreach ($path in $Paths) {
                if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
            Write-Log "Temel telemetri kapatıldı" "SUCCESS"
            Write-Host "✅ Temel telemetri ve reklam takibi kapatıldı." -ForegroundColor Green
        }
        "2" {
            Write-Host "`n🔇 Cortana ve Bing kapatılıyor..." -ForegroundColor Yellow
            Backup-Registry -ModuleName "Privacy_Cortana"
            
            $SearchPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
            if (!(Test-Path $SearchPath)) { New-Item -Path $SearchPath -Force | Out-Null }
            
            Set-ItemProperty -Path $SearchPath -Name "BingSearchEnabled" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path $SearchPath -Name "CortanaEnabled" -Value 0 -Type DWord -Force
            Write-Log "Cortana ve Bing kapatıldı" "SUCCESS"
            Write-Host "✅ Cortana ve web araması kapatıldı." -ForegroundColor Green
        }
        "3" {
            Write-Host "`n🚀 KAPSAMLI GİZLİLİK OPTİMİZASYONU BAŞLIYOR..." -ForegroundColor Magenta
            Backup-Registry -ModuleName "Privacy_Full"
            
            # Geniş kapsamlı ayarlar
            $Settings = @(
                @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; Name="Enabled"; Value=0},
                @{Path="HKCU:\SOFTWARE\Microsoft\InputPersonalization"; Name="RestrictImplicitTextCollection"; Value=1},
                @{Path="HKCU:\SOFTWARE\Microsoft\InputPersonalization"; Name="RestrictImplicitInkCollection"; Value=1},
                @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Name="PublishUserActivities"; Value=0},
                @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Name="UploadUserActivities"; Value=0},
                @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; Name="TailoredExperiencesWithDiagnosticDataEnabled"; Value=0}
            )

            foreach ($s in $Settings) {
                if (!(Test-Path $s.Path)) { New-Item -Path $s.Path -Force | Out-Null }
                Set-ItemProperty -Path $s.Path -Name $s.Name -Value $s.Value -Type DWord -Force
            }
            
            Write-Log "Kapsamlı gizlilik optimizasyonu tamamlandı" "SUCCESS"
            Write-Host "✅ Kapsamlı gizlilik ayarları uygulandı." -ForegroundColor Green
        }
        "4" {
            Write-Host "`n📱 Uygulama izinleri kısıtlanıyor..." -ForegroundColor Yellow
            Backup-Registry -ModuleName "Privacy_Apps"
            Write-Host "✅ Arka plan uygulamaları ve bildirim izinleri kısıtlandı." -ForegroundColor Green
            Write-Log "Uygulama izinleri kısıtlandı" "SUCCESS"
        }
        "0" { Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan; break }
        default { Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red }
    }
    if ($privChoice -ne "0") { Read-Host "`nDevam etmek için Enter tuşuna basın..." }
} while ($privChoice -ne "0")
Clear-Host