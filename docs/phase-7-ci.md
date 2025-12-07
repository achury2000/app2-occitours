Fase 7 — Tests y CI

Objetivos:
- Tener CI que ejecute `flutter analyze` y `flutter test` en cada push/PR.
- Proveer scripts útiles para ejecutar tests localmente en Windows (PowerShell) y en Linux.
- Asegurar que los tests de unidad y widget estén aislados (mocks para HTTP/images ya añadidos en fases previas).

Qué incluye esta rama:
- `.github/workflows/flutter-ci.yml`: workflow de GitHub Actions que instala Flutter, corre `pub get`, `flutter analyze` y `flutter test --coverage`.
- `scripts/run_tests.ps1`: script PowerShell para ejecutar análisis y tests localmente en Windows.
- Documentación de pasos rápidos.

Recomendaciones:
- Habilitar GitHub Actions en el repo y revisar artefactos de cobertura cuando la CI corra.
- Añadir paso opcional para publicar cobertura en servicios como Codecov o Coveralls.
