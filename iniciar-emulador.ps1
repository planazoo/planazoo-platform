# Script para iniciar el emulador Android
# Uso: powershell -ExecutionPolicy Bypass -File iniciar-emulador.ps1

Write-Host "📱 Iniciando emulador Android..." -ForegroundColor Cyan

$androidHome = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
$emulatorPath = "$androidHome\emulator\emulator.exe"

if (-not (Test-Path $emulatorPath)) {
    Write-Host "❌ Error: Emulador no encontrado en: $emulatorPath" -ForegroundColor Red
    exit 1
}

# Listar dispositivos disponibles
Write-Host "`n📋 Dispositivos AVD disponibles:" -ForegroundColor Cyan
& $emulatorPath -list-avds

Write-Host "`n🚀 Iniciando Pixel_7_API_30_cricla..." -ForegroundColor Cyan

# Iniciar emulador
Start-Process -FilePath $emulatorPath -ArgumentList "-avd", "Pixel_7_API_30_cricla" -WindowStyle Normal

Write-Host "⏳ Esperando 30 segundos a que el emulador inicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Verificar que está corriendo
Write-Host "`n✅ Verificando dispositivos conectados..." -ForegroundColor Cyan
& "$androidHome\platform-tools\adb.exe" devices

Write-Host "`n✅ Emulador iniciado. Puedes ejecutar 'flutter run' ahora." -ForegroundColor Green

