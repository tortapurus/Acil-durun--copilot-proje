
#### 📄 `memory-bank/99_warp-guide.md`
```md
# Warp için Geliştirme Rehberi

## Nasıl Kullanılır?
Warp, bu `memory-bank/` klasöründeki dosyaları proje bağlamı olarak kullanır.

### Örnek Prompt’lar:
> “`memory-bank/02_ui-structure.md` içindeki ‘Yeni Ürün Ekle’ ekranını Flutter’da oluştur. Kategori listesi senin `03_data-models.md` dosyasındaki gibi olsun. Renk şeması `06_system-patterns.md`’ye göre uygulansın.”

> “`memory-bank/03_data-models.md`’ye göre Hive veri modeli yaz.”

> “`memory-bank/04_notifications.md`’ye göre yerel bildirim sistemi kur.”

## En İyi Pratikler
1. Her prompt’ta ilgili dosyaya atıf yap.
2. Tüm metinler `tr.json` dosyasından gelsin.
3. Renk kodlarını `06_system-patterns.md`’ye göre uygula.
4. Kullanıcı tanımlı kategorileri destekle.
5. Tema desteği için `ThemeData` kullan.