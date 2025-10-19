
#### 📄 `memory-bank/04_notifications.md`
```md
# Bildirim ve Uyarı Sistemi

## Uyarı Türleri
- Süresi dolmuş (kırmızı)
- 7 gün içinde bitecek (sarı)
- Güvenli (yeşil)

## Uyarı Sekmesi
- Sol alt köşede sabit buton
- İçinde kontrol edilmemiş uyarılar listelenir
- Uyarıya tıklanınca ürün detayına gidilir ama **ana ekranda uyarı kalır** (kapatılmadıkça)

## Bildirim Ayarları
- Kullanıcı “3 gün önce” gibi bir değer girer
- Bu değer tüm yeni ürünler için `hatirlatma_tarihi = son_kullanma - X gün` olarak hesaplanır