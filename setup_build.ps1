# APK Build Kısayolu
# Kullanım: build (tek komut ile APK derle, numara ver, kur ve çalıştır)

function Build-APK {
    & ".\build_apk.ps1"
}

# Alias oluştur
Set-Alias -Name build -Value Build-APK

Write-Host "✅ APK Build sistemi hazır!" -ForegroundColor Green
Write-Host "📱 Kullanım: build" -ForegroundColor Cyan
Write-Host "🚀 Bu komut ile APK derlenip numaralandırılır ve cihaza kurulur!" -ForegroundColor Yellow