# Script completo para iniciar emulador y ejecutar Flutter
# Uso: powershell -ExecutionPolicy Bypass -File iniciar-y-ejecutar.ps1

Write-Host "Iniciando emulador y ejecutando Flutter..." -ForegroundColor Cyan

# Configurar variables de entorno
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

Write-Host "Variables de entorno configuradas" -ForegroundColor Green

# Verificar si el emulador ya está corriendo
$adbPath = "$env:ANDROID_HOME\platform-tools\adb.exe"
if (Test-Path $adbPath) {
    $adbDevices = & $adbPath devices
    $emulatorRunning = $adbDevices -match "emulator"
    
    if (-not $emulatorRunning) {
        Write-Host ""
        Write-Host "Emulador no detectado. Iniciando..." -ForegroundColor Yellow
        
        # Iniciar emulador
        $emulatorPath = "$env:ANDROID_HOME\emulator\emulator.exe"
        if (Test-Path $emulatorPath) {
            Start-Process -FilePath $emulatorPath -ArgumentList "-avd", "Pixel_7_API_30_cricla" -WindowStyle Normal
            
            Write-Host "Esperando 45 segundos a que el emulador inicie..." -ForegroundColor Yellow
            Start-Sleep -Seconds 45
            
            # Verificar que está corriendo
            $adbDevices = & $adbPath devices
            if ($adbDevices -match "emulator") {
                Write-Host "Emulador iniciado correctamente" -ForegroundColor Green
            } else {
                Write-Host "Error: El emulador no se inicio correctamente" -ForegroundColor Red
                Write-Host "Verifica que el emulador este visible en tu pantalla" -ForegroundColor Yellow
                exit 1
            }
        } else {
            Write-Host "Error: Emulador no encontrado en: $emulatorPath" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Emulador ya esta corriendo" -ForegroundColor Green
    }
} else {
    Write-Host "Error: ADB no encontrado en: $adbPath" -ForegroundColor Red
    exit 1
}

# Verificar dispositivos Flutter
Write-Host ""
Write-Host "Dispositivos disponibles:" -ForegroundColor Cyan
flutter devices

# Ejecutar Flutter
Write-Host ""
Write-Host "Ejecutando Flutter en el emulador..." -ForegroundColor Cyan
Write-Host "Esto puede tardar 2-5 minutos la primera vez" -ForegroundColor Yellow
Write-Host ""

flutter run -d emulator-5554
