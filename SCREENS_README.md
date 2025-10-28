# Acil Durum Takip Uygulaması - Flutter Projesi

Türkçe olarak geliştirilen, acil durum çantaları takip etmek için tasarlanmış Flutter uygulaması.

## 📋 Proje Yapısı

```
lib/
├── main.dart                          # Ana uygulama giriş noktası
├── l10n/
│   └── app_localizations.dart        # 20 dil desteği
├── models/
│   ├── product.dart                  # Ürün modeli
│   ├── bag.dart                      # Çanta modeli
│   └── category.dart                 # Kategori modeli
├── screens/
│   ├── ana_sayfa.dart               # Ana sayfa (ekran 1)
│   ├── acil_durum_paneli.dart       # Acil durum paneli (ekran 2)
│   ├── urun_listesi.dart            # Ürün listesi (ekran 3)
│   ├── yeni_urun_ekle.dart          # Yeni ürün ekleme (ekran 4)
│   ├── urun_detay.dart              # Ürün detayları (ekran 5)
│   ├── bilgi_merkezi.dart           # Bilgi merkezi (ekran 6)
│   └── yeni_canta_olustur.dart      # Yeni çanta oluşturma (ekran 7)
├── services/
│   ├── notification_service.dart    # Bildirim servisi
│   └── data_service.dart            # Veri yönetim servisi
└── theme/
    └── theme_colors.dart            # Tema renkleri
```

## 🎨 Ekranlar

### 1. **Ana Sayfa** (`ana_sayfa.dart`)
- Kritik uyarılar kartı (kırmızı gradyan)
- Yaklaşan son kullanma tarihleri (sarı gradyan)
- Genel bakış kutuları (toplam ürün, çanta sayısı)
- Hızlı eylemler (Ürün Ekle, Barkod Tara, Stok Yönetimi)
- Alt menü: Ana Sayfa, Çantalar, Depo, Kategoriler, Ayarlar

### 2. **Acil Durum Paneli** (`acil_durum_paneli.dart`)
- Acil Durum Çantaları bölümü
- Depo Paneli bölümü
- Durum göstergeleri (Yakında Sona Erecek, Eksik)
- Bildirim göstergesi

### 3. **Ürün Listesi** (`urun_listesi.dart`)
- Arama çubuğu (yeşil odaklanma rengi)
- Filtre butonları
- Ürün kartları (resim, adı, durum, stok)
- "Süresi doldu" yazı göstergesi

### 4. **Yeni Ürün Ekle** (`yeni_urun_ekle.dart`)
- Ürün Adı giriş alanı
- Kategori seçici (34 sabit kategori + "Yeni Kategori Ekle...")
- Tarih seçiciler (Son Kullanma & Hatırlatma)
- Notlar ve Konum alanları
- Resim yükleme
- Yeşil "Kaydet" butonu

### 5. **Ürün Detay** (`urun_detay.dart`)
- Tam genişlik ürün resmi
- Ürün başlığı ve kategori
- Tarih bilgileri
- Konum ve Notlar
- Son güncelleme
- "Düzenle" ve "Sil" butonları

### 6. **Bilgi Merkezi** (`bilgi_merkezi.dart`)
- "Yeni Dosya Yükle" butonu (yeşil)
- PDF dosyaları (mavi arka plan)
- JPG dosyaları (mor arka plan)
- ZIP dosyaları (gri arka plan)
- İndirme/Silme işlemleri

### 7. **Yeni Çanta Oluştur** (`yeni_canta_olustur.dart`)
- Çanta Adı giriş alanı
- Notlar alanı
- İkon göstergesi (mor)
- "Çantayı Oluştur" butonu (mor, gölge efekti)
- "İptal" butonu

## 🎨 Tema

### Renk Şeması
- **Koyu Arka Planlar:**
  - Ana Sayfa: `#121212`
  - Yeni Ürün Ekle: `#111714`
  - Yeni Çanta: `#1A181D`
  - Kartlar: `#1F1F1F` / `#1E1E1E`

- **Pastel Renkler:**
  - Yeşil: `#A2E4B8`
  - Sarı: `#F8E4A0`
  - Kırmızı: `#F4A8A8`
  - Mavi: `#A2C4E4`
  - Mor: `#C4A2E4`

- **Primer Renkler:**
  - Ürün Ekleme: `#38e07b`
  - Çanta Oluşturma: `#994ce6`

- **Metin:**
  - Beyaz: `#FFFFFF`
  - Siyah: `#333333`
  - Gri: `#9eb7a8`

## 📱 Kategoriler

34 sabit kategori mevcuttur:
- Su, Konserve, Kuru Yemiş, Yiyecek
- İlk yardım çantası, El feneri, Pilli radyo
- Battaniye, Uyku tulumu, Çok amaçlı çakı
- İş eldiveni, Kibrit, Çakmak, Toz maskesi
- Islak mendil, Tuvalet kağıdı, Hijyenik ped
- Kimlik/tapu/sigorta/pasaport, Nakit para
- Yedek kıyafet, Çöp torbası, Sabun
- Diş fırçası ve macunu, Su Arıtma Tabletleri
- Su arıtma cihazı, Pusula ve Harita
- Tabanca, Tabanca Mermisi, Tüfek
- Tüfek Mermisi, Slug mermiler, Saçma mermiler
- Kurşunsuz mermiler
- Ayrıca "Yeni Kategori Ekle..." seçeneği

## 🌐 Dil Desteği

20 dil destekleniyor:
- Türkçe (TR), English (EN), العربية (AR)
- Deutsch (DE), Español (ES), فارسی (FA)
- Français (FR), हिन्दी (HI), Italiano (IT)
- 日本語 (JA), 한국어 (KO), Português (PT)
- Русский (RU), Українська (UK), বাংলা (BN)
- اردو (UR), မြန်မာ (MY), አማርኛ (AM)
- الصومالية (SO), 中文 (ZH)

## 📦 Veri Modelleri

### Product
- `id`: Benzersiz tanımlayıcı
- `name`: Ürün adı
- `category`: Kategori
- `expiryDate`: Son kullanma tarihi
- `reminderDate`: Hatırlatma tarihi
- `notes`: Notlar
- `location`: Konum
- `imagePath`: Resim yolu
- `stock`: Stok miktarı
- `isChecked`: Kontrol edildi
- `createdAt`: Oluşturulma tarihi

### Bag
- `id`: Benzersiz tanımlayıcı
- `name`: Çanta adı
- `notes`: Notlar
- `productIds`: İçerdiği ürün IDs
- `createdAt`: Oluşturulma tarihi
- `isEmergencyBag`: Acil durum çantası

### Category
- `id`: Benzersiz tanımlayıcı
- `name`: Kategori adı
- `isCustom`: Özel kategori

## 🔧 Servisler

### NotificationService
- Yerel bildirimler
- Zamanlanmış hatırlatmalar
- Android ve iOS desteği

### DataService
- Ürün yönetimi
- Çanta yönetimi
- Kategori yönetimi
- İstatistikler
- Arama işlevselliği

## 🚀 Çalıştırma

```bash
# Projeyi başlat
flutter pub get
flutter run
```

## 📝 Bağımlılıklar

```yaml
- flutter_localizations: Dil desteği
- provider: Durum yönetimi
- hive: Yerel veritabanı
- intl: Uluslararasılaştırma
- image_picker: Resim seçme
- path_provider: Dosya yolu
- flutter_local_notifications: Bildirimler
- timezone: Saat dilimi yönetimi
```

## ✨ Özellikler

- ✅ Karanlık tema (sadece)
- ✅ 7 tam ekran
- ✅ 20 dil desteği
- ✅ Material Symbols Outlined ikonlar
- ✅ Ürün takip sistemi
- ✅ Çanta yönetimi
- ✅ Son kullanma tarihi uyarıları
- ✅ Kategori yönetimi
- ✅ Arama ve filtreleme
- ✅ Yerel bildirimler
- ✅ Dosya yönetimi (Bilgi Merkezi)

---

**Geliştirici**: GitHub Copilot
**Tarih**: 19 Ekim 2025
**Dil**: Dart + Flutter
