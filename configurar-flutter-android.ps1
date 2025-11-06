# Script para configurar variables de entorno de Flutter y Android
# Uso: powershell -ExecutionPolicy Bypass -File configurar-flutter-android.ps1

Write-Host "🔧 Configurando variables de entorno para Flutter y Android..." -ForegroundColor Cyan

# Configurar Android SDK
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
Write-Host "✓ ANDROID_HOME configurado: $env:ANDROID_HOME" -ForegroundColor Green

# Añadir Android SDK al PATH
$androidPaths = @(
    "$env:ANDROID_HOME\platform-tools",
    "$env:ANDROID_HOME\emulator",
    "$env:ANDROID_HOME\tools",
    "$env:ANDROID_HOME\tools\bin"
)

foreach ($path in $androidPaths) {
    if (Test-Path $path) {
        $env:PATH += ";$path"
        Write-Host "✓ Añadido al PATH: $path" -ForegroundColor Green
    } else {
        Write-Host "⚠ No encontrado: $path" -ForegroundColor Yellow
    }
}

# Configurar Flutter
$flutterPath = "C:\Users\cclaraso\Downloads\flutter\bin"
if (Test-Path $flutterPath) {
    $env:PATH += ";$flutterPath"
    Write-Host "✓ Flutter añadido al PATH: $flutterPath" -ForegroundColor Green
} else {
    Write-Host "⚠ Flutter no encontrado en: $flutterPath" -ForegroundColor Yellow
}

Write-Host "`n✅ Variables de entorno configuradas (temporalmente para esta sesión)" -ForegroundColor Green
Write-Host "`n📱 Verificando dispositivos disponibles..." -ForegroundColor Cyan

# Verificar dispositivos
& "$env:ANDROID_HOME\platform-tools\adb.exe" devices

Write-Host "`n💡 Para verificar con Flutter, ejecuta: flutter devices" -ForegroundColor Yellow
Write-Host "💡 Para ejecutar la app, ejecuta: flutter run" -ForegroundColor Yellow
Write-Host "`n⚠️ Nota: Estas variables son temporales. Reinicia la terminal después de configurarlas permanentemente." -ForegroundColor Yellow

