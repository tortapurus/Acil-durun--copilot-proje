# Ekranlar (Birebir `html acildurum.txt`’ye göre)

## 1. Ana Sayfa
- Arka plan: `bg-[#121212]`
- Üst başlık: “Ana Sayfa” (beyaz, 2xl, bold)
- Sağ üst: bildirim ikonu (`notifications`)
- **Kritik Uyarılar** kartı:
  - Arka plan: `from-[var(--pastel-red)] to-red-400`
  - İkon: `warning` (beyaz, 3xl)
  - Yazı: beyaz
  - Örnek: “2 ürünün son kullanma tarihi geçti. 1 ürünün stoğu tükendi.”
- **Yaklaşan Son Kullanma Tarihleri** kartı:
  - Arka plan: `from-[var(--pastel-yellow)] to-yellow-400`
  - İkon: `hourglass_top` (siyah, 3xl)
  - Yazı: siyah (`#333`)
- **Genel Bakış** kutuları:
  - “58 Toplam Ürün”, “4 Acil Durum Çantası”
  - Arka plan: `bg-[#1F1F1F]`
- **Hızlı Eylemler**:
  - `add` → “Ürün Ekle”
  - `qr_code_scanner` → “Barkod Tara”
  - `inventory_2` → “Stok Yönetimi”
- Alt menü: Çantalar, Depo, Ürünler, Kategoriler, Ayarlar, **Bilgi Merkezi** (yeşil)

---

## 2. Acil Durum Paneli (Çanta & Depo Özeti)
- Üst başlık: “Acil Durum” (merkezde, beyaz)
- Bildirim butonu: kırmızı noktalı
- **Acil Durum Çantası** bölümü:
  - “Yakında Sona Erecek” → sarı çerçeve (`border-yellow-500/50`)
  - “Eksik” → kırmızı çerçeve (`border-red-500/50`)
- **Depo Paneli** bölümü: aynı yapı
- Her kart:
  - Arka plan: `bg-[#1E1E1E]`
  - Ürün resmi: yuvarlak, sağda
  - Sol: durum etiketi, ürün sayısı, açıklama
- Alt menü: Ana Sayfa (aktif), Çantalar, Depo, Bilgi Merkezi, Kategoriler, Ayarlar

---

## 3. Ürün Listesi
- Üst başlık: “Ürünler” (geri butonu var)
- Arama çubuğu: yeşil odaklı (`focus:ring-[var(--pastel-green)]`)
- Filtre butonları: “Kategori”, “Kalan Gün”, “Ad”
- Ürün kartları:
  - Arka plan: `bg-[#1F1F1F]`
  - Resim: sol üstte, yuvarlak
  - Sağda: Ürün adı (beyaz, bold), Kalan gün (gri), Stok (gri)
  - “Süresi doldu” → yazıyla belirtilir
- Alt menü: Ürünler (yeşil vurgulu)

---

## 4. Yeni Ürün Ekle
- Arka plan: `bg-[#111714]`
- Renk: `--primary-color: #38e07b`
- Giriş alanları:
  - Ürün Adı (metin)
  - **Kategori** (açılır liste):
    - Su
    - Konserve
    - Kuru Yemiş
    - Yiyecek
    - İlk yardım çantası
    - El feneri
    - Pilli radyo
    - Battaniye
    - Uyku tulumu
    - Çok amaçlı çakı
    - İş eldiveni
    - Kibrit
    - Çakmak
    - Toz maskesi
    - Islak mendil
    - Tuvalet kağıdı
    - Hijyenik ped
    - Kimlik, tapu, sigorta, pasaport
    - Nakit para
    - Yedek kıyafet
    - Çöp torbası
    - Sabun
    - Diş fırçası ve macunu
    - Su Arıtma Tabletleri
    - Su arıtma cihazı
    - Pusula ve Harita
    - Tabanca
    - Tabanca Mermisi
    - Tüfek
    - Tüfek Mermisi
    - Slug mermiler
    - Saçma mermiler
    - Kurşunsuz mermiler
    - **“Yeni Kategori Ekle...”**
  - Son Kullanma Tarihi (tarih seçici)
  - Hatırlatma Tarihi (tarih seçici)
  - Notlar (isteğe bağlı)
  - Konum Notu (isteğe bağlı)
  - Resim Yükle (dashed border, `add_a_photo` ikonu)
- “Kaydet” butonu: `bg-[var(--primary-color)]`, beyaz yazı

---

## 5. Ürün Detay
- Arka plan: `bg-[#111714]`
- Üstte: ürün resmi (tam genişlik, yuvarlatılmış)
- Ürün başlığı: beyaz, 3xl, bold
- Kategori: gri (`#9eb7a8`)
- Tarih kutuları:
  - Son Kullanma: “31.12.2024 (250 gün kaldı)”
  - Hatırlatma: “24.12.2024”
- Konum Notu: `location_on` + metin
- Notlar: `sticky_note_2` + metin
- Son Güncelleme: `history` + tarih
- Alt butonlar:
  - “Düzenle”: `bg-[#29382f]`, beyaz
  - “Sil”: `bg-[#4ce68a]`, koyu yazı

---

## 6. Bilgi Merkezi
- Arka plan: `bg-[#121212]`
- Renk değişkenleri:
  - `--pastel-green: #A2E4B8`
  - `--pastel-blue: #A2C4E4`
  - `--pastel-purple: #C4A2E4`
- “Yeni Dosya Yükle” butonu: `bg-[var(--pastel-green)]`, siyah yazı
- Yüklenmiş dosyalar:
  - PDF: mavi arka plan (`--pastel-blue`), `description` ikonu
  - JPG: mor arka plan (`--pastel-purple`), `image` ikonu
  - ZIP: gri arka plan, `folder_zip` ikonu
- Alt menü: Bilgi Merkezi (yeşil vurgulu)

---

## 7. Yeni Çanta Oluştur
- Arka plan: `bg-[#1A181D]`
- Renk: `--primary-purple: #994ce6`
- Giriş alanları:
  - Çanta Adı (placeholder: “Örn: Ev Acil Durum Çantası”)
  - Notlar (isteğe bağlı)
- “Çantayı Oluştur” butonu: `bg-[#994ce6]`, beyaz yazı, gölge efekti