Write-Log "BSOD Analizi modülü başladı" "INFO"

function Show-BSODMenu {
    Clear-Host
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              💥 BSOD ANALİZİ v2.1                            ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "   1. Son BSOD Olaylarını Göster" -ForegroundColor Cyan
    Write-Host "   2. Minidump Klasörünü Aç" -ForegroundColor Cyan
    Write-Host "   3. BSOD Dökümanlarını Temizle" -ForegroundColor Cyan
    Write-Host "   4. Detaylı BSOD Raporu" -ForegroundColor Cyan
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-BSODMenu
    $bsodChoice = Read-Host

    switch ($bsodChoice) {
        "1" {
            Write-Host "`n💥 Son Mavi Ekran olayları aranıyor..." -ForegroundColor Yellow
            $events = Get-WinEvent -FilterHashtable @{LogName='System'; ID=41,1001} -MaxEvents 15 -ErrorAction SilentlyContinue
            
            if ($events) {
                $events | Select-Object TimeCreated, Id, Message | Format-List
                Write-Log "$($events.Count) adet BSOD olayı görüntülendi" "WARNING"
            } else {
                Write-Host "✅ Son dönemde BSOD olayı tespit edilmedi." -ForegroundColor Green
            }
        }
        "2" {
            $dumpPath = "C:\Windows\Minidump"
            if (Test-Path $dumpPath) {
                explorer $dumpPath
                Write-Host "`n📂 Minidump klasörü açıldı." -ForegroundColor Green
            } else {
                Write-Host "❌ Minidump klasörü bulunamadı." -ForegroundColor Red
            }
        }
        "3" {
            $dumpPath = "C:\Windows\Minidump"
            if (Test-Path $dumpPath) {
                $count = (Get-ChildItem $dumpPath *.dmp -ErrorAction SilentlyContinue).Count
                Remove-Item "$dumpPath\*" -Force -ErrorAction SilentlyContinue
                Write-Host "✅ $count adet BSOD dökümanı temizlendi." -ForegroundColor Green
                Write-Log "$count adet minidump temizlendi" "SUCCESS"
            } else {
                Write-Host "❌ Temizlenecek dosya bulunamadı." -ForegroundColor Red
            }
        }
        "4" {
            Write-Host "`n📋 Detaylı BSOD Raporu oluşturuluyor..." -ForegroundColor Yellow
            $events = Get-WinEvent -FilterHashtable @{LogName='System'; ID=41,1001} -MaxEvents 20 -ErrorAction SilentlyContinue
            
            if ($events) {
                $events | Select-Object @{Name="Tarih";Expression={$_.TimeCreated}}, 
                                       @{Name="Olay ID";Expression={$_.Id}}, 
                                       Message | Format-List
            } else {
                Write-Host "✅ Son 20 olayda BSOD bulunamadı." -ForegroundColor Green
            }
            Write-Log "Detaylı BSOD raporu görüntülendi" "INFO"
        }
        "0" { Write-Host "`nAna menüye dönülüyor..." -ForegroundColor Cyan; break }
        default { Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red }
    }
    if ($bsodChoice -ne "0") { Read-Host "`nDevam etmek için Enter tuşuna basın..." }
} while ($bsodChoice -ne "0")
Clear-Host