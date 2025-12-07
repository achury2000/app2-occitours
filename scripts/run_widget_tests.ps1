# Runs widget and related tests locally on Windows PowerShell
# Usage: Open PowerShell at repo root and run: .\scripts\run_widget_tests.ps1









Write-Output "Tests finished. Coverage artifact is in coverage/. Use genhtml to view or upload to CI." flutter test test --coverage; if ($LASTEXITCODE -ne 0) { Write-Error "`nUnit/widget tests failed."; exit $LASTEXITCODE }Write-Output "Running unit tests..."flutter analyze; if ($LASTEXITCODE -ne 0) { Write-Error "`nAnalyze failed.`; exit $LASTEXITCODE }Write-Output "Running flutter analyze..."# Ensure flutter is on PATH and running the correct channel/version for CI