# =============================================
# Privacy.ps1 - Gizlilik Ayarları
# =============================================

Write-Log "Gizlilik Ayarları modülü başladı" "INFO" "Privacy"

function Show-PrivacyMenu {
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              🔒 GİZLİLİK AYARLARI v2.1                       ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Write-Host "   1. Temel Telemetri ve Reklam Takibini Kapat" -ForegroundColor Cyan
    Write-Host "   2. Cortana, Bing ve Web Aramayı Kapat" -ForegroundColor Cyan
    Write-Host "   3. 🚀 Kapsamlı Gizlilik Optimizasyonu (Önerilen)" -ForegroundColor Magenta
    Write-Host "   4. Uygulama İzinlerini Kısıtla" -ForegroundColor Cyan
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-PrivacyMenu
    $privChoice = Read-Host

    switch ($privChoice) {
        "1" {
            Write-Host "`n🔒 Temel Telemetri kapatılıyor..." -ForegroundColor Yellow
            Write-Log "Temel telemetri kapatılıyor" "INFO" "Privacy"
            try {
                Backup-Registry -ModuleName "Privacy_Telemetry" | Out-Null
                
                $Paths = @(
                    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
                    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
                )
                
                foreach ($path in $Paths) {
                    if (-not (Test-Path $path)) {
                        New-Item -Path $path -Force | Out-Null
                    }
                }
                
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force -EA SilentlyContinue
                Write-Log "Temel telemetri kapatıldı" "SUCCESS" "Privacy"
                Write-Host "✅ Temel telemetri ve reklam takibi kapatıldı." -ForegroundColor Green
            } catch {
                Write-Log "Telemetri kapatma hatası: $($_.Exception.Message)" "WARNING" "Privacy"
                Write-Host "⚠️  Telemetri kısmen kapatıldı." -ForegroundColor Yellow
            }
        }
        "2" {
            Write-Host "`n🔇 Cortana ve Bing kapatılıyor..." -ForegroundColor Yellow
            Write-Log "Cortana ve Bing kapatılıyor" "INFO" "Privacy"
            try {
                Backup-Registry -ModuleName "Privacy_Cortana" | Out-Null
                
                $SearchPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
                if (-not (Test-Path $SearchPath)) {
                    New-Item -Path $SearchPath -Force | Out-Null
                }
                
                Set-ItemProperty -Path $SearchPath -Name "BingSearchEnabled" -Value 0 -Type DWord -Force -EA SilentlyContinue
                Set-ItemProperty -Path $SearchPath -Name "CortanaEnabled" -Value 0 -Type DWord -Force -EA SilentlyContinue
                
                Write-Log "Cortana ve Bing kapatıldı" "SUCCESS" "Privacy"
                Write-Host "✅ Cortana ve web araması kapatıldı." -ForegroundColor Green
            } catch {
                Write-Log "Cortana kapatma hatası: $($_.Exception.Message)" "WARNING" "Privacy"
                Write-Host "⚠️  Cortana kısmen kapatıldı." -ForegroundColor Yellow
            }
        }
        "3" {
            Write-Host "`n🚀 KAPSAMLI GİZLİLİK OPTİMİZASYONU BAŞLIYOR..." -ForegroundColor Magenta
            Write-Log "Kapsamlı gizlilik optimizasyonu başlatılıyor" "INFO" "Privacy"
            try {
                Backup-Registry -ModuleName "Privacy_Full" | Out-Null
                
                Write-Host "   → Telemetri kapatılıyor..." -ForegroundColor Yellow
                Write-Host "   → Kişiselleştirme ayarları yapılıyor..." -ForegroundColor Yellow
                Write-Host "   → Aktivite takibi devre dışı bırakılıyor..." -ForegroundColor Yellow
                
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
                    if (-not (Test-Path $s.Path)) {
                        New-Item -Path $s.Path -Force | Out-Null
                    }
                    Set-ItemProperty -Path $s.Path -Name $s.Name -Value $s.Value -Type DWord -Force -EA SilentlyContinue
                }
                
                Write-Log "Kapsamlı gizlilik optimizasyonu tamamlandı ($($Settings.Count) ayar)" "SUCCESS" "Privacy"
                Write-Host "✅ Kapsamlı gizlilik ayarları uygulandı." -ForegroundColor Green
            } catch {
                Write-Log "Kapsamlı gizlilik hatası: $($_.Exception.Message)" "ERROR" "Privacy"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "4" {
            Write-Host "`n📱 Uygulama izinleri kısıtlanıyor..." -ForegroundColor Yellow
            Write-Log "Uygulama izinleri kısıtlanıyor" "INFO" "Privacy"
            try {
                Backup-Registry -ModuleName "Privacy_Apps" | Out-Null
                
                $AppPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
                if (-not (Test-Path $AppPath)) {
                    New-Item -Path $AppPath -Force | Out-Null
                }
                
                Set-ItemProperty -Path $AppPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force -EA SilentlyContinue
                
                Write-Log "Uygulama izinleri kısıtlandı" "SUCCESS" "Privacy"
                Write-Host "✅ Arka plan uygulamaları ve bildirim izinleri kısıtlandı." -ForegroundColor Green
            } catch {
                Write-Log "Uygulama izinleri hatası: $($_.Exception.Message)" "WARNING" "Privacy"
                Write-Host "⚠️  Uygulama izinleri kısmen kısıtlandı." -ForegroundColor Yellow
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
    if ($privChoice -ne "0") { 
        Read-Host "`nDevam etmek için Enter tuşuna basın..." 
    }
} while ($privChoice -ne "0")
Clear-Host

Write-Log "Privacy modülü kapatıldı" "SUCCESS" "Privacy"