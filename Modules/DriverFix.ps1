Write-Log "Driver kontrol ve yedekleme modülü başladı" "INFO"

$DriverBackupRoot = "$ScriptRoot\..\Backups\Drivers"
if (-not (Test-Path $DriverBackupRoot)) {
    New-Item -Path $DriverBackupRoot -ItemType Directory -Force | Out-Null
}

function Start-DriverUpdateCheck {
    Write-Host "`n🔍 DRIVER GÜNCELLEME KONTROLÜ" -ForegroundColor Magenta
    Write-Host "══════════════════════════════════════" -ForegroundColor Magenta
    
    # Yedek alma uyarısı
    Write-Host "`n⚠️  ÖNEMLİ UYARI:" -ForegroundColor Yellow
    Write-Host "Güncelleme öncesi driver yedeği alınması şiddetle tavsiye edilir." -ForegroundColor Yellow
    $backupConfirm = Read-Host "Şimdi driver yedeği almak ister misiniz? (E/H)"
    
    if ($backupConfirm -match '^[Ee]$') {
        $date = Get-Date -Format "yyyyMMdd_HHmm"
        $backupPath = "$DriverBackupRoot\DriverBackup_$date"
        New-Item -Path $backupPath -ItemType Directory -Force | Out-Null
        
        Write-Host "📦 Driver yedekleniyor..." -ForegroundColor Yellow
        pnputil /export-driver * "$backupPath" | Out-Null
        Write-Host "✅ Yedek alındı: $backupPath" -ForegroundColor Green
        Write-Log "Driver yedeği alındı (güncelleme öncesi)" "SUCCESS"
    }

    Write-Host "`nWindows Update üzerinden driver aranılıyor..." -ForegroundColor Yellow
    
    try {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Driver'")
        
        if ($searchResult.Updates.Count -gt 0) {
            Write-Host "`n✅ $($searchResult.Updates.Count) adet driver güncellemesi bulundu!" -ForegroundColor Green
            $searchResult.Updates | Select-Object Title | Format-Table -AutoSize
            Write-Log "$($searchResult.Updates.Count) adet driver güncellemesi tespit edildi" "SUCCESS"
            
            Write-Host "`nNot: Bu güncellemeleri Windows Update'ten manuel olarak yükleyebilirsiniz." -ForegroundColor Cyan
        } else {
            Write-Host "`n🎉 Sisteminizdeki driverlar güncel görünüyor." -ForegroundColor Green
            Write-Log "Driver güncellemesi bulunamadı" "SUCCESS"
        }
    }
    catch {
        Write-Host "`n⚠️ Windows Update servisi ile kontrol edilemedi." -ForegroundColor Yellow
        Write-Host "Alternatif liste gösteriliyor..." -ForegroundColor Cyan
        Get-WmiObject Win32_PnPSignedDriver | 
            Where-Object {$_.DriverProviderName -notlike "*Microsoft*"} | 
            Select-Object DeviceName, DriverVersion, DriverProviderName -First 15 | Format-Table -AutoSize
    }
}

function Show-DriverMenu {
    Clear-Host
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              🔧 DRIVER YÖNETİMİ v2.1                         ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "   1. Driver'ları Tara ve Sorunlu Olanları Göster" -ForegroundColor Cyan
    Write-Host "   2. Tüm Driver'ları Yedekle" -ForegroundColor Cyan
    Write-Host "   3. Yedekten Driver Yükle" -ForegroundColor Cyan
    Write-Host "   4. PnP Cihazlarını Yeniden Tara" -ForegroundColor Cyan
    Write-Host "   5. 🔄 Driver Güncelleme Kontrolü (Windows Update)" -ForegroundColor Cyan
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-DriverMenu
    $driverChoice = Read-Host

    switch ($driverChoice) {
        "1" {
            Write-Host "`n🔍 Sorunlu driver'lar aranıyor..." -ForegroundColor Yellow
            $devicesWithError = Get-PnpDevice | Where-Object { $_.Problem -ne $null -and $_.Status -ne "OK" }
            if ($devicesWithError) {
                Write-Host "$($devicesWithError.Count) adet sorunlu cihaz bulundu!" -ForegroundColor Red
                $devicesWithError | Select-Object FriendlyName, InstanceId, Problem | Format-Table -AutoSize
            } else {
                Write-Host "✅ Tüm cihazlar sorunsuz." -ForegroundColor Green
            }
        }
        "2" {
            $date = Get-Date -Format "yyyyMMdd_HHmm"
            $backupPath = "$DriverBackupRoot\DriverBackup_$date"
            New-Item -Path $backupPath -ItemType Directory -Force | Out-Null
            Write-Host "`n📦 Driver'lar yedekleniyor..." -ForegroundColor Yellow
            pnputil /export-driver * "$backupPath" | Out-Null
            Write-Host "✅ Yedekleme tamamlandı: $backupPath" -ForegroundColor Green
        }
        "3" {
            $restorePath = Read-Host "`nYedek klasörünün tam yolunu girin"
            if (Test-Path $restorePath) {
                Write-Host "`n📥 Driver'lar yükleniyor..." -ForegroundColor Yellow
                pnputil /add-driver "$restorePath\*.inf" /subdirs /install | Out-Null
                Write-Host "✅ Yükleme tamamlandı." -ForegroundColor Green
            } else {
                Write-Host "❌ Klasör bulunamadı!" -ForegroundColor Red
            }
        }
        "4" {
            Write-Host "`n🔄 PnP cihazları yeniden taranıyor..." -ForegroundColor Yellow
            pnputil /scan-devices
            Write-Host "✅ Tarama tamamlandı." -ForegroundColor Green
        }
        "5" {
            Start-DriverUpdateCheck
        }
        "0" { Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan; break }
        default { Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red }
    }
    
    if ($driverChoice -ne "0") { 
        Read-Host "`nDevam etmek için Enter tuşuna basın..." 
    }
} while ($driverChoice -ne "0")
Clear-Host