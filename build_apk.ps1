# APK Build ve Numara Verme Scripti

# APK build et
Write-Host "APK derleniyor..." -ForegroundColor Green
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "APK başarıyla derlendi!" -ForegroundColor Green
    
    # Mevcut APK dosya sayısını bul
    $apkDir = "build\app\outputs\flutter-apk"
    $apkFiles = Get-ChildItem -Path $apkDir -Filter "app-release*.apk" | Sort-Object Name
    $nextNumber = $apkFiles.Count + 1
    
    # Yeni dosya ismi oluştur
    $newFileName = "app-release$nextNumber.apk"
    $sourcePath = "$apkDir\app-release.apk"
    $destPath = "$apkDir\$newFileName"
    
    # APK dosyasını yeni isimle kopyala
    if (Test-Path $sourcePath) {
        Copy-Item $sourcePath $destPath
        Write-Host "APK kopyalandı: $newFileName" -ForegroundColor Cyan
        
        # Dosya boyutunu göster
        $fileSize = [math]::Round((Get-Item $destPath).Length / 1MB, 1)
        Write-Host "Dosya boyutu: $fileSize MB" -ForegroundColor Yellow
        
        # APK'yı cihaza kur
        Write-Host "APK cihaza kuruluyor..." -ForegroundColor Green
        adb install -r $destPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "APK başarıyla kuruldu!" -ForegroundColor Green
            
            # Uygulamayı başlat
            Write-Host "Uygulama başlatılıyor..." -ForegroundColor Green
            adb shell am start -n com.example.acil_durum_takip/.MainActivity
            
            Write-Host "===============================================" -ForegroundColor Magenta
            Write-Host "✅ İŞLEM TAMAMLANDI!" -ForegroundColor Green
            Write-Host "📱 APK: $newFileName" -ForegroundColor Cyan
            Write-Host "📏 Boyut: $fileSize MB" -ForegroundColor Yellow
            Write-Host "🚀 Uygulama çalışıyor!" -ForegroundColor Green
            Write-Host "===============================================" -ForegroundColor Magenta
        } else {
            Write-Host "APK kurulumu başarısız!" -ForegroundColor Red
        }
    } else {
        Write-Host "APK dosyası bulunamadı!" -ForegroundColor Red
    }
} else {
    Write-Host "APK derleme başarısız!" -ForegroundColor Red
}