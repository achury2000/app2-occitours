# Phase 3 — Reglas de negocio y pruebas: poner normas y seguridad

Esta fase fue más metódica: ya había pantallas y catálogos, pero hacía falta que la app no solo mostrara datos, sino que aplicara reglas coherentes y fuera confiable.

Metas:
- Evitar reservas duplicadas y validar cupos.
- Añadir pruebas automáticas para proteger refactors futuros.

Acciones concretas:
1. Centralicé validaciones importantes en `ReservationsProvider` (helper `existsSameSchedule`) para no repetir lógica en la UI.
2. Implementé persistencia simulada con `SharedPreferences` y añadí el helper `test/test_helpers.dart` para inicializar el entorno de tests (mocks de SharedPreferences y HttpClient para tiles).
3. Convertí pruebas manuales en tests unitarios y widget tests: cobertura para CRUD de servicios, creación de reservas y parsers de CSV/fecha.
4. Ajusté los imports/exports CSV para ser tolerantes y añadí logs amigables cuando encuentro datos sucios.

Decisiones de diseño:
- Preferí centralizar validaciones en providers para que cualquier UI nueva reutilice las mismas reglas.
- Los tests son prácticos: más focus en flujo crítico (reservas, autenticación, carrito) que en tests superficiales.

Resultado:
- Un conjunto de reglas de negocio aplicadas en providers, tests básicos que evitan regresiones y utilidades para correr los tests en cualquier máquina.

Nota personal:
- Esta fase es donde el trabajo deja de ser mágico y pasa a ser ingeniería: escribir tests no es divertido al principio, pero luego ahorra tiempo.
