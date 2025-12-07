Write-Host "Running Flutter analyze and tests (PowerShell)"
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host "Flutter not found in PATH. Please install Flutter and ensure 'flutter' is available."; exit 1
}
flutter pub get
flutter analyze
flutter test
if ($LASTEXITCODE -ne 0) { Write-Host "Tests failed"; exit $LASTEXITCODE }
Write-Host "All tests passed"
