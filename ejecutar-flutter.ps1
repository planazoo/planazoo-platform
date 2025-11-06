# Script rapido para configurar y ejecutar Flutter
# Uso: .\ejecutar-flutter.ps1

Write-Host "Configurando Flutter y Android..." -ForegroundColor Cyan

# Configurar Android SDK
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"

# Añadir rutas de Android al PATH
$androidPaths = @(
    "$env:ANDROID_HOME\platform-tools",
    "$env:ANDROID_HOME\emulator",
    "$env:ANDROID_HOME\tools",
    "$env:ANDROID_HOME\tools\bin"
)

foreach ($path in $androidPaths) {
    if (Test-Path $path) {
        $env:PATH += ";$path"
    }
}

# Configurar Flutter
$flutterPath = "C:\Users\cclaraso\Downloads\flutter\bin"
if (Test-Path $flutterPath) {
    $env:PATH += ";$flutterPath"
}

Write-Host "Variables configuradas" -ForegroundColor Green

# Verificar emulador
Write-Host ""
Write-Host "Verificando emulador..." -ForegroundColor Cyan
$adbPath = "$env:ANDROID_HOME\platform-tools\adb.exe"
if (Test-Path $adbPath) {
    $devices = & $adbPath devices
    if ($devices -match "emulator-5554") {
        Write-Host "Emulador detectado: emulator-5554" -ForegroundColor Green
    } else {
        Write-Host "Emulador no detectado. Verifica que este corriendo." -ForegroundColor Yellow
        Write-Host "Ejecuta: .\iniciar-emulador.ps1" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "ADB no encontrado en: $adbPath" -ForegroundColor Red
    exit 1
}

# Verificar dispositivos Flutter
Write-Host ""
Write-Host "Dispositivos disponibles:" -ForegroundColor Cyan
flutter devices

Write-Host ""
Write-Host "Para ejecutar la app, usa:" -ForegroundColor Yellow
Write-Host "   flutter run -d emulator-5554" -ForegroundColor White
Write-Host "   o simplemente: flutter run" -ForegroundColor White
