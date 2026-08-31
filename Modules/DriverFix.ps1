# =============================================
# DriverFix.ps1 - Driver Yönetimi ve Yedekleme
# =============================================

Write-Log "Driver kontrol ve yedekleme modülü başladı" "INFO" "DriverFix"

# DriverFix için özel konfigürasyon
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$DriverBackupRoot = "$ScriptRoot\..\Backups\Drivers"
if (-not (Test-Path $DriverBackupRoot)) {
    New-Item -Path $DriverBackupRoot -ItemType Directory -Force | Out-Null
    Write-Log "Driver Backup klasörü oluşturuldu" "INFO" "DriverFix" $DriverBackupRoot
}

function Start-DriverUpdateCheck {
    Write-Host "`n🔍 DRIVER GÜNCELLEME KONTROLÜ" -ForegroundColor Magenta
    Write-Host "══════════════════════════════════════" -ForegroundColor Magenta
    
    # Yedek alma uyarısı
    Write-Host "`n⚠️  ÖNEMLİ UYARI:" -ForegroundColor Yellow
    Write-Host "Güncelleme öncesi driver yedeği alınması şiddetle tavsiye edilir." -ForegroundColor Yellow
    $backupConfirm = Read-Host "Şimdi driver yedeği almak ister misiniz? (E/H)"
    
    if ($backupConfirm -match '^[Ee]$') {
        try {
            $date = Get-Date -Format "yyyyMMdd_HHmm"
            $backupPath = "$DriverBackupRoot\DriverBackup_$date"
            New-Item -Path $backupPath -ItemType Directory -Force | Out-Null
            
            Write-Host "📦 Driver yedekleniyor..." -ForegroundColor Yellow
            pnputil /export-driver * "$backupPath" 2>&1 | Out-Null
            
            Write-Log "Driver yedeği alındı (güncelleme öncesi)" "SUCCESS" "DriverFix" $backupPath
            Write-Host "✅ Yedek alındı: $backupPath" -ForegroundColor Green
        } catch {
            Write-Log "Driver yedek alma hatası: $($_.Exception.Message)" "WARNING" "DriverFix"
            Write-Host "⚠️  Yedek alınamadı, devam ediliyor..." -ForegroundColor Yellow
        }
    }

    Write-Host "`nWindows Update üzerinden driver aranılıyor..." -ForegroundColor Yellow
    
    try {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Driver'")
        
        if ($searchResult.Updates.Count -gt 0) {
            Write-Host "`n✅ $($searchResult.Updates.Count) adet driver güncellemesi bulundu!" -ForegroundColor Green
            $searchResult.Updates | Select-Object Title | Format-Table -AutoSize
            Write-Log "$($searchResult.Updates.Count) adet driver güncellemesi tespit edildi" "SUCCESS" "DriverFix"
            
            Write-Host "`nNot: Bu güncellemeleri Windows Update'ten manuel olarak yükleyebilirsiniz." -ForegroundColor Cyan
        } else {
            Write-Host "`n🎉 Sisteminizdeki driverlar güncel görünüyor." -ForegroundColor Green
            Write-Log "Driver güncellemesi bulunamadı" "SUCCESS" "DriverFix"
        }
    }
    catch {
        Write-Host "`n⚠️  Windows Update servisi ile kontrol edilemedi." -ForegroundColor Yellow
        Write-Host "Alternatif liste gösteriliyor..." -ForegroundColor Cyan
        Write-Log "Windows Update sorgusu hatası: $($_.Exception.Message)" "WARNING" "DriverFix"
        
        try {
            Get-WmiObject Win32_PnPSignedDriver -ErrorAction Stop | 
                Where-Object {$_.DriverProviderName -notlike "*Microsoft*"} | 
                Select-Object DeviceName, DriverVersion, DriverProviderName -First 15 | Format-Table -AutoSize
        } catch {
            Write-Host "⚠️  Driver bilgileri alınamadı." -ForegroundColor Yellow
        }
    }
}

function Show-DriverMenu {
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              🔧 DRIVER YÖNETİMİ v2.1                         ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Write-Host "   1. Driver'ları Tara ve Sorunlu Olanları Göster" -ForegroundColor Cyan
    Write-Host "   2. Tüm Driver'ları Yedekle" -ForegroundColor Cyan
    Write-Host "   3. Yedekten Driver Yükle" -ForegroundColor Cyan
    Write-Host "   4. PnP Cihazlarını Yeniden Tara" -ForegroundColor Cyan
    Write-Host "   5. 🔄 Driver Güncelleme Kontrolü (Windows Update)" -ForegroundColor Cyan
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-DriverMenu
    $driverChoice = Read-Host

    switch ($driverChoice) {
        "1" {
            Write-Host "`n🔍 Sorunlu driver'lar aranıyor..." -ForegroundColor Yellow
            Write-Log "Driver taraması başlatılıyor" "INFO" "DriverFix"
            try {
                $devicesWithError = Get-PnpDevice -ErrorAction Stop | Where-Object { $_.Problem -ne $null -and $_.Status -ne "OK" }
                
                if ($devicesWithError) {
                    Write-Host "`n⚠️  $($devicesWithError.Count) adet sorunlu cihaz bulundu!" -ForegroundColor Red
                    $devicesWithError | Select-Object FriendlyName, InstanceId, Problem | Format-Table -AutoSize
                    Write-Log "$($devicesWithError.Count) sorunlu cihaz tespit edildi" "WARNING" "DriverFix"
                } else {
                    Write-Host "✅ Tüm cihazlar sorunsuz." -ForegroundColor Green
                    Write-Log "Tüm cihazlar taranıldı - sorun yok" "SUCCESS" "DriverFix"
                }
            } catch {
                Write-Log "Driver taraması hatası: $($_.Exception.Message)" "ERROR" "DriverFix"
                Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "2" {
            Write-Host "`n📦 Driver'lar yedekleniyor..." -ForegroundColor Yellow
            Write-Log "Tüm driver'lar yedekleniyor" "INFO" "DriverFix"
            try {
                $date = Get-Date -Format "yyyyMMdd_HHmm"
                $backupPath = "$DriverBackupRoot\DriverBackup_$date"
                New-Item -Path $backupPath -ItemType Directory -Force | Out-Null
                
                pnputil /export-driver * "$backupPath" 2>&1 | Out-Null
                
                $backupCount = (Get-ChildItem "$backupPath\*.inf" -ErrorAction SilentlyContinue).Count
                Write-Log "Driver yedekleme tamamlandı ($backupCount driver)" "SUCCESS" "DriverFix" $backupPath
                Write-Host "✅ Yedekleme tamamlandı: $backupPath" -ForegroundColor Green
                Write-Host "   ($backupCount driver yedeklendi)" -ForegroundColor Cyan
            } catch {
                Write-Log "Driver yedekleme hatası: $($_.Exception.Message)" "ERROR" "DriverFix"
                Write-Host "❌ Yedekleme başarısız: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "3" {
            Write-Host "`n📁 Yedek klasörünün tam yolunu girin (örn: C:\Backups\Drivers\DriverBackup_20240101_1000)"
            $restorePath = Read-Host "Yol"
            
            Write-Log "Driver yüklemesi başlatılıyor" "INFO" "DriverFix" $restorePath
            
            if (Test-Path $restorePath) {
                Write-Host "`n📥 Driver'lar yükleniyor..." -ForegroundColor Yellow
                try {
                    pnputil /add-driver "$restorePath\*.inf" /subdirs /install 2>&1 | Out-Null
                    Write-Log "Driver yükleme tamamlandı" "SUCCESS" "DriverFix"
                    Write-Host "✅ Yükleme tamamlandı." -ForegroundColor Green
                    Write-Host "⚠️  Yeniden başlatma önerilir." -ForegroundColor Yellow
                } catch {
                    Write-Log "Driver yükleme hatası: $($_.Exception.Message)" "ERROR" "DriverFix"
                    Write-Host "❌ Yükleme başarısız: $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "❌ Klasör bulunamadı!" -ForegroundColor Red
                Write-Log "Driver yükleme klasörü bulunamadı" "WARNING" "DriverFix" $restorePath
            }
        }
        "4" {
            Write-Host "`n🔄 PnP cihazları yeniden taranıyor..." -ForegroundColor Yellow
            Write-Log "PnP taraması başlatılıyor" "INFO" "DriverFix"
            try {
                pnputil /scan-devices 2>&1 | Out-Null
                Write-Log "PnP taraması tamamlandı" "SUCCESS" "DriverFix"
                Write-Host "✅ Tarama tamamlandı." -ForegroundColor Green
            } catch {
                Write-Log "PnP taraması hatası: $($_.Exception.Message)" "WARNING" "DriverFix"
                Write-Host "⚠️  Tarama başarısız oldu." -ForegroundColor Yellow
            }
        }
        "5" {
            Start-DriverUpdateCheck
            Write-Log "Driver güncelleme kontrolü tamamlandı" "SUCCESS" "DriverFix"
        }
        "0" { 
            Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan
            break 
        }
        default { 
            Write-Host "❌ Geçersiz seçim! Lütfen 0-5 arasında seçim yapın." -ForegroundColor Red 
        }
    }
    
    if ($driverChoice -ne "0") { 
        Read-Host "`nDevam etmek için Enter tuşuna basın..." 
    }
} while ($driverChoice -ne "0")
Clear-Host

Write-Log "DriverFix modülü kapatıldı" "SUCCESS" "DriverFix"