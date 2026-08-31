# =============================================
# BSODAnalyzer.ps1 - BSOD Analizi ve Raporlama
# =============================================

Write-Log "BSOD Analizi modülü başladı" "INFO" "BSODAnalyzer"

function Show-BSODMenu {
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              💥 BSOD ANALİZİ v2.1                            ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Write-Host "   1. Son BSOD Olaylarını Göster" -ForegroundColor Cyan
    Write-Host "   2. Minidump Klasörünü Aç" -ForegroundColor Cyan
    Write-Host "   3. BSOD Dökümanlarını Temizle" -ForegroundColor Cyan
    Write-Host "   4. Detaylı BSOD Raporu" -ForegroundColor Cyan
    Write-Host "   0. Ana Menüye Dön" -ForegroundColor Red
    Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   Seçiminiz → " -ForegroundColor Yellow -NoNewline
}

do {
    Show-BSODMenu
    $bsodChoice = Read-Host

    switch ($bsodChoice) {
        "1" {
            Write-Host "`n💥 Son Mavi Ekran olayları aranıyor..." -ForegroundColor Yellow
            Write-Log "Son BSOD olayları sorgulanıyor" "INFO" "BSODAnalyzer"
            try {
                $events = Get-WinEvent -FilterHashtable @{LogName='System'; ID=41,1001} -MaxEvents 15 -ErrorAction SilentlyContinue
                
                if ($events) {
                    Write-Host ""
                    Write-Host "⚠️  $($events.Count) adet BSOD olayı bulundu:" -ForegroundColor Red
                    Write-Host ""
                    $events | Select-Object `
                        @{Name="Tarih";Expression={$_.TimeCreated}},
                        @{Name="Event ID";Expression={$_.Id}},
                        @{Name="Kaynak";Expression={$_.ProviderName}} | Format-Table -AutoSize
                    
                    Write-Log "$($events.Count) adet BSOD olayı görüntülendi" "WARNING" "BSODAnalyzer"
                } else {
                    Write-Host "✅ Son dönemde BSOD olayı tespit edilmedi." -ForegroundColor Green
                    Write-Log "BSOD olayı bulunamadı" "SUCCESS" "BSODAnalyzer"
                }
            } catch {
                Write-Log "BSOD olayları sorgusu hatası: $($_.Exception.Message)" "WARNING" "BSODAnalyzer"
                Write-Host "⚠️  BSOD olayları alınamadı: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        "2" {
            $dumpPath = "C:\Windows\Minidump"
            Write-Log "Minidump klasörü açılıyor" "INFO" "BSODAnalyzer"
            
            if (Test-Path $dumpPath) {
                try {
                    explorer $dumpPath
                    Write-Host "`n📂 Minidump klasörü açıldı." -ForegroundColor Green
                    Write-Log "Minidump klasörü başarıyla açıldı" "SUCCESS" "BSODAnalyzer"
                } catch {
                    Write-Log "Minidump klasörü açma hatası: $($_.Exception.Message)" "ERROR" "BSODAnalyzer"
                    Write-Host "❌ Klasör açılamadı: $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "❌ Minidump klasörü bulunamadı." -ForegroundColor Red
                Write-Log "Minidump klasörü bulunamadı" "WARNING" "BSODAnalyzer"
            }
        }
        "3" {
            $dumpPath = "C:\Windows\Minidump"
            Write-Log "BSOD dökümanları temizleniyor" "INFO" "BSODAnalyzer"
            
            if (Test-Path $dumpPath) {
                try {
                    $dumpFiles = Get-ChildItem "$dumpPath\*.dmp" -ErrorAction SilentlyContinue
                    $count = @($dumpFiles).Count
                    
                    if ($count -gt 0) {
                        Write-Host "`n⚠️  $count adet minidump dosyası silinecek!" -ForegroundColor Yellow
                        $confirm = Read-Host "Emin misiniz? (E/H)"
                        
                        if ($confirm -match '^[Ee]$') {
                            Remove-Item "$dumpPath\*.dmp" -Force -ErrorAction SilentlyContinue
                            Write-Log "$count adet minidump temizlendi" "SUCCESS" "BSODAnalyzer"
                            Write-Host "✅ $count adet BSOD dökümanı temizlendi." -ForegroundColor Green
                        } else {
                            Write-Log "Minidump temizleme iptal edildi" "INFO" "BSODAnalyzer"
                            Write-Host "⏭️  İptal edildi." -ForegroundColor Cyan
                        }
                    } else {
                        Write-Host "✅ Temizlenecek dosya bulunamadı." -ForegroundColor Green
                        Write-Log "Temizlenecek minidump bulunamadı" "SUCCESS" "BSODAnalyzer"
                    }
                } catch {
                    Write-Log "Minidump temizleme hatası: $($_.Exception.Message)" "ERROR" "BSODAnalyzer"
                    Write-Host "❌ Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "❌ Minidump klasörü bulunamadı." -ForegroundColor Red
                Write-Log "Minidump klasörü bulunamadı" "WARNING" "BSODAnalyzer"
            }
        }
        "4" {
            Write-Host "`n📋 Detaylı BSOD Raporu oluşturuluyor..." -ForegroundColor Yellow
            Write-Log "Detaylı BSOD raporu oluşturuluyor" "INFO" "BSODAnalyzer"
            try {
                $events = Get-WinEvent -FilterHashtable @{LogName='System'; ID=41,1001} -MaxEvents 20 -ErrorAction SilentlyContinue
                
                if ($events) {
                    Write-Host ""
                    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
                    Write-Host "║                   DETAYLI BSOD RAPORU                      ║" -ForegroundColor Magenta
                    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
                    Write-Host ""
                    
                    $events | Select-Object `
                        @{Name="Tarih";Expression={$_.TimeCreated}},
                        @{Name="Event ID";Expression={$_.Id}},
                        @{Name="Kaynak";Expression={$_.ProviderName}} | Format-Table -AutoSize
                    
                    Write-Host ""
                    Write-Host "📌 Ayrıntılar:" -ForegroundColor Cyan
                    $events | Select-Object Message | Format-List
                    
                    Write-Log "Detaylı BSOD raporu oluşturuldu" "SUCCESS" "BSODAnalyzer"
                } else {
                    Write-Host "✅ Son 20 olayda BSOD bulunamadı." -ForegroundColor Green
                    Write-Log "BSOD raporu - olay bulunamadı" "SUCCESS" "BSODAnalyzer"
                }
            } catch {
                Write-Log "BSOD raporu oluşturma hatası: $($_.Exception.Message)" "ERROR" "BSODAnalyzer"
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
    if ($bsodChoice -ne "0") { 
        Read-Host "`nDevam etmek için Enter tuşuna basın..." 
    }
} while ($bsodChoice -ne "0")
Clear-Host

Write-Log "BSODAnalyzer modülü kapatıldı" "SUCCESS" "BSODAnalyzer"