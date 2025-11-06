# Script para ejecutar Flutter y ver la salida en tiempo real
# Uso: .\ejecutar-flutter-visible.ps1

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
        Write-Host "Emulador no detectado. Iniciando..." -ForegroundColor Yellow
        $emulatorPath = "$env:ANDROID_HOME\emulator\emulator.exe"
        if (Test-Path $emulatorPath) {
            Start-Process -FilePath $emulatorPath -ArgumentList "-avd", "Pixel_7_API_30_cricla" -WindowStyle Normal
            Write-Host "Esperando 45 segundos..." -ForegroundColor Yellow
            Start-Sleep -Seconds 45
            $devices = & $adbPath devices
            if (-not ($devices -match "emulator-5554")) {
                Write-Host "Error: Emulador no se inicio correctamente" -ForegroundColor Red
                exit 1
            }
        }
    }
}

# Verificar dispositivos Flutter
Write-Host ""
Write-Host "Dispositivos disponibles:" -ForegroundColor Cyan
flutter devices

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "INICIANDO COMPILACION Y EJECUCION" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "La salida aparecera aqui mismo..." -ForegroundColor Yellow
Write-Host ""

# Ejecutar Flutter (esto mostrará la salida en tiempo real)
flutter run -d emulator-5554

