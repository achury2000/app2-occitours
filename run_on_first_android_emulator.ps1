# Detecta el primer dispositivo Android/emulador y ejecuta flutter run en él.
# Uso: abrir PowerShell en la carpeta del proyecto y ejecutar:
# .\run_on_first_android_emulator.ps1

Write-Host "Buscando dispositivos Flutter..."
$raw = flutter devices --machine 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Error "Error ejecutando 'flutter devices'. Asegúrate de tener Flutter en PATH."
  exit 1
}

try {
  $devices = $raw | Out-String | ConvertFrom-Json
} catch {
  # Si no se pudo parsear JSON, usar fallback a texto simple
  Write-Host "No se pudo parsear JSON de 'flutter devices'. Usando fallback de texto."
  $text = flutter devices
  $match = ($text -split "\r?\n") | ForEach-Object { $_ } | Where-Object { $_ -match "(emulator-|device|Android).*" }
  if ($match) {
    Write-Host "Dispositivo detectado (fallback): `n$match[0]"
    Write-Host "Usa 'flutter run' manualmente o abre el emulador en Android Studio."
    flutter run
    exit 0
  } else {
    flutter run
    exit 0
  }
}

# devices suele ser un array de objetos
if ($devices -is [System.Array]) {
  $android = $devices | Where-Object { $_.platform -match 'android' -or ($_.platform -match 'android') } | Select-Object -First 1
} else {
  # si devuelve un solo objeto
  $android = $null
  if ($devices.platform -match 'android') { $android = $devices }
}

if ($null -ne $android) {
  $id = $android.id
  Write-Host "Dispositivo Android encontrado: $($android.name) (id: $id). Ejecutando app..."
  flutter run -d $id
} else {
  Write-Host "No se detectó dispositivo Android. Ejecutando 'flutter run' (te pedirá seleccionar dispositivo)."
  flutter run
}
