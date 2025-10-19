# Dil Stratejisi

## Desteklenen Diller (Toplam: 20)
- Türkçe (`tr`)
- İngilizce (`en`)
- Hintçe (`hi`)
- İspanyolca (`es`)
- Arapça (`ar`)
- Portekizce (`pt`)
- İtalyanca (`it`)
- Fransızca (`fr`)
- Almanca (`de`)
- Japonca (`ja`)
- Korece (`ko`)
- Farsça (`fa`)
- Ukraynaca (`uk`)
- Bengalce (`bn`)
- Urduca (`ur`)
- Myanmarca (`my`)
- Amharca (`am`)
- Somali (`so`)
- Çince (`zh`)
- Rusça (`ru`)

## Afet Odaklı Dil Seçimi
- Tüm diller, **acil durum iletişimini kolaylaştırmak** amacıyla seçilmiştir.
- Özellikle **savaş, deprem, sel, kuraklık** riski taşıyan bölgeler öncelikli.

## Çalışma Mantığı
- Cihaz dili otomatik algılanır
- Manuel dil seçimi: Ayarlar → Dil
- Tüm UI metinleri: `assets/lang/{code}.json`
- Uygulama her zaman **koyu tema ile başlar**, ancak kullanıcı **açık temaya geçebilir** → ❌ **Hayır, sadece koyu tema**

## Dosya Yolu
`assets/lang/{code}.json`