**Fase 8 — QA, Mocks y Documentación**

Objetivo
- Completar la etapa de aseguramiento de calidad: estabilizar tests widget/integración, añadir mocks y guías para QA, y dejar la base lista para despliegue y revisión.

Checklist mínima
- **Tests**: ejecutar `flutter test` (unit + widget) y documentar fallos.
- **Mocks**: cualquier test que haga llamadas HTTP o cargue imágenes debe usar los helpers en `test/test_helpers.dart` o mocks locales.
- **Integración**: añadir ejemplos/instrucciones para `integration_test` y dejar un test básico.
- **Assets**: asegurar que los assets usados por los tests estén en `test/assets/` o sean sustituidos por stubs.
- **CI**: comprobar el workflow `.github/workflows/flutter-ci.yml` y añadir pasos de integración si hace falta.

Tareas recomendadas
- Añadir scripts para ejecutar solo tests widget y solo integración.
- Añadir guía rápida para ejecutar tests en Windows PowerShell (bash/cmd equiv. opcional).
- Marcar tests flakey con `@Skip` y crear un issue para su investigación si no se puede arreglar inmediatamente.
- Automatizar la generación de datos de prueba (fixtures) cuando sea necesario.

Notas operativas
- Mantener el catálogo de mocks en `test/test_helpers.dart`.
- Evitar dependencias externas en los tests; preferir `HttpOverrides` y `FakeImageHttpClient`.
- Crear PR para revisión de QA y pedir a reviewers ejecutar el script `scripts/run_widget_tests.ps1`.

Resultado esperado
- Suite de tests estable en CI (pasar `flutter analyze` y `flutter test`).
- Documentación clara para que cualquier desarrollador ejecute QA localmente.
