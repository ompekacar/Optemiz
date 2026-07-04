# 🚀 Optemiz v2.1.3 - Geliştirilmiş

> **İlk kararlı sürüm!** Production-ready kodla gelen önemli iyileştirmeler.

---

## 📋 Özet

Optemiz v2.1.3, sisteminizin bakım ve optimizasyonunun daha güvenli, daha bilgilendirici ve daha kontrollü hale getirilmesine odaklanır. Error handling, detaylı raporlama ve kullanıcı dostu arayüz ile gelir.

---

## ✨ Yeni Özellikler

### 📊 Before/After Sistem Karşılaştırması
- Bakım öncesi ve sonrası **RAM** durumunu karşılaştırır
- **Disk alanı** kazançlarını gösterir (GB ve yüzde cinsinden)
- Gerçek zamanlı iyileştirmeleri görün

### 🎯 Ultra Otomatik Bakım Progress Bar
- Görevlerin ilerleme durumunu yüzde olarak gösterir
- Kaç görev tamamlandığını takip edin
- Tahmini kalan süre bilgisi

### 🌐 Smart İnternet Kontrolü
- Ağ bağlantısından emin olduktan sonra işlem başlar
- Güncelleme kontrolü sadece internet varsa çalışır
- Hata mesajları daha anlaşılır

### 📋 Enhanced HTML Log Raporu
- İşlem adımlarını detaylı kaydeder
- İşlem özeti (başarılı, başarısız, oranı)
- Renkli ve okunması kolay format
- Tarayıcıda kolayca görüntülenebilir

### 🎛️ Merkezi Menü Sistemi
- Tüm modüller aynı menü tarzı kullanır
- Tutarlı kullanıcı deneyimi
- Kolay seçim ve navigasyon

---

## 🔧 Düzeltmeler & İyileştirmeler

### Error Handling ✅
| Modül | Düzeltme |
|-------|----------|
| **Cleanup** | Try-catch, safe dosya silme, onay istemi |
| **Privacy** | Registry path kontrolü, otomatik oluşturma |
| **SystemScan** | SFC/DISM hata yönetimi, smart DISM |
| **Performance** | Hizmet ayarlama kontrolleri |
| **Network** | Ağ operasyonları try-catch'li |
| **Gaming** | Registry safe yazma |
| **Driver** | Windows Update fallback mekanizması |
| **Disk** | CHKDSK ve volume işlemleri güvenli |
| **RAM** | CIM sorguları error handling'li |
| **BSOD** | Event log parserlama güvenli |

### Admin Kontrolü 🔒
- Script başında admin yetkisi kontrol edilir
- Yetkisi yoksa bilgilendirici hata mesajı
- Script başarısız olması yerine sonlanır

### Registry Güvenliği 🛡️
- Path otomatik olarak oluşturulur
- Hata durumunda uyarı verilir
- Başarı/başarısız durumu her zaman loglanır

### Dosya Silme Güvenliği 🗑️
- Silmeden önce uyarı gösterilir
- Silinecek dosya sayısı belirtilir
- Kullanıcı onayı gereklidir

---

## 📁 Güncellenmiş Modüller

**Core:**
- `Optemiz.ps1` - Main orchestrator (Before/After raporu, progress bar)
- `Modules/Utils.ps1` - Merkezi fonksiyonlar (logging, Registry, menü)

**System Maintenance:**
- `Modules/SystemScan.ps1` - Intelligent DISM kontrol
- `Modules/Cleanup.ps1` - Safe cleanup operations
- `Modules/DiskRepair.ps1` - Güvenli disk işlemleri

**Optimization:**
- `Modules/PerformanceTweaks.ps1` - Registry safe yazma
- `Modules/Privacy.ps1` - Safe telemetri ayarları
- `Modules/NetworkOptimization.ps1` - Network tuning
- `Modules/GamingOptimization.ps1` - Gaming mode

**Diagnostics:**
- `Modules/RAMDiagnostics.ps1` - RAM analysis
- `Modules/BSODAnalyzer.ps1` - Blue Screen analysis
- `Modules/DriverFix.ps1` - Driver management

---

## 🎯 Performans

- **Ultra Otomatik Bakım:** ~7 dakika (sistem bağlı olarak)
- **Klasik Tam Bakım:** ~15-30 dakika
- **Modüler tasarım:** Sadece ihtiyacınız olan özelliği çalıştırın

---

## 📊 Teknik Detaylar

### Sistem Gereksinimleri
- Windows 10 / Windows 11
- PowerShell 5.1+
- Administrator yetkileri **ZORUNLU**

### Yeni Fonksiyonlar
```powershell
Test-AdminRights              # Admin kontrol
Show-ModuleMenu               # Merkezi menü sistemi
Remove-FileSafely             # Güvenli dosya silme
Set-RegistrySafely            # Registry yazma
Test-InternetConnection       # İnternet kontrolü
Get-SystemSnapshot            # Sistem durumu anlık görüntüsü
Start-SystemMonitoring        # Sistem izleme başlatma
Close-HtmlReport              # HTML rapor kapatma
```

---

## 📥 Kurulum & Hızlı Başlangıç

### ⚙️ Sistem Gereksinimleri
- ✅ **Windows 10** veya **Windows 11**
- ✅ **PowerShell 5.1+** (varsayılan olarak yüklü)
- ✅ **Administrator yetkileri** (ZORUNLU)
- ✅ **~50 MB** disk alanı

### 📦 Kurulum Adımları

#### **Adım 1: İndir**
1. [Releases sayfasına](https://github.com/ompekacar/Optemiz/releases/tag/v2.1.3) git
2. **Assets** bölümünden tüm dosyaları indir
3. Bir klasöre (örn: `C:\Optemiz`) kopyala

#### **Adım 2: Çalıştır**
1. İndirilen klasörü aç
2. **`Start-Optemiz.bat`** dosyasına sağ tıkla
3. **"Yönetici olarak çalıştır"** seç

> ⚠️ **Admin hakkı yoksa hata alırsın!** PowerShell'i yönetici modunda açıp manuel çalıştırabilirsin:
> ```powershell
> powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Optemiz\Optemiz.ps1"
> ```

#### **Adım 3: Menüyü Seç**
```
Ana Menü
├─ 12 → 🔥 ULTRA OTOMATİK BAKIM (ÖNERİLİ - 7 dakika)
├─ 11 → Klasik Tam Bakım (15-30 dakika)
├─ 1-10 → Belirli görevler
└─ 0 → Çıkış
```

### 🎯 İlk Çalıştırma Başlıyor

```
✓ Admin kontrolü              : Başarılı
✓ Modüller yüklü             : Tamam
📊 Sistem durumu kaydedildi   : RAM, Disk
→ Bakım başlıyor...
```

### 📊 Sonuç Raporu

Bakım tamamlandığında şunları göreceksin:
- **ÖNCESİ-SONRASI karşılaştırması** (RAM, Disk)
- **CPU Kullanımı**
- **Detaylı HTML raporu** (Tarayıcıda görüntülenebilir)

---

## 🚨 Sorun Giderme (Troubleshooting)

| Sorun | Çözüm |
|-------|-------|
| **"Admin yetkisi yok"** | PowerShell'i admin modunda aç (Başlat → PowerShell → Sağ tıkla → Admin) |
| **"Modül yüklenemiyor"** | Tüm dosyaların `Modules` klasöründe olduğunu kontrol et |
| **"Dosya silme hatasında kalıyor"** | Antivirus'ü geçici devre dışı bırak |
| **"Registry yazma başarısız"** | Registry Editor'da izinleri kontrol et |
| **"DISM uzun sürüyor"** | Normal (15-20 dakika), pencereyi kapatma |
| **"HTML rapor açılmıyor"** | İnternet Explorer güncel olduğundan emin ol |

---

## 💡 Tavsiyeler

### ✅ **Yapılması Gerekenler**
- Bakımdan **önce önemli dosyaların yedeğini al**
- **Ultra Otomatik Bakım** ile başla (12. seçenek)
- İşlem sırasında bilgisayarı **kapatma**
- Bakım sonrası **yeniden başlatma** öner

### ❌ **Yapılmaması Gerekenler**
- Antivirus açıkken çalıştırma (hata verebilir)
- Admin olmadan çalıştırma
- Dosyaları farklı yerlere taşıma
- Script dosyalarını düzenlemeye çalışma

---

## 📞 Yardım & Destek

Sorun yaşıyorsan:
1. **[Issues sayfasını](https://github.com/ompekacar/Optemiz/issues) aç**
2. Hatanın ekran görüntüsünü paylaş
3. İşletim sistemi versiyonunu belirt (Windows 10 / 11)

---

## 🔄 v2.1.2 ile Farklar

| Özellik | v2.1.2 | v2.1.3 |
|---------|--------|--------|
| Error Handling | Minimal | Kapsamlı ✅ |
| Admin Kontrolü | Yok | Otomatik ✅ |
| Before/After | Yok | Detaylı ✅ |
| Progress Bar | Yok | Var ✅ |
| Internet Check | Yok | Var ✅ |
| Safe Operations | Yok | Var ✅ |
| Kurulum Rehberi | Yok | Var ✅ |
| HTML Rapor | Basit | Enhanced ✅ |

---

## 📝 Lisans

Bu proje **MIT License** ile dağıtılmaktadır. Personal ve ticari kullanım için ücretsizdir.

---

## 🙏 Katkıda Bulunanlar

- **Oğuz** (@ompekacar) - Developer
- **Grok** (xAI) - Code & Architecture Support

---

## 🔗 Bağlantılar

- 📥 [İndir](https://github.com/ompekacar/Optemiz/releases/tag/v2.1.3)
- 📖 [README](https://github.com/ompekacar/Optemiz)
- 🐛 [Hata Bildir](https://github.com/ompekacar/Optemiz/issues)
- ⭐ [Yıldız Ver](https://github.com/ompekacar/Optemiz)

---

**Optemiz'i kullandığınız için teşekkürler! 🙏**
