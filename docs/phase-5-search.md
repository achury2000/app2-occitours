Fase 5 — Búsquedas y Rendimiento

Resumen:
- Objetivo: mejorar latencia y relevancia de búsquedas en proveedores clave (ProductsProvider, ReservationsProvider).
- Enfoque inicial: índice invertido en memoria para `ProductsProvider` (tokens -> ids) y búsqueda por intersección de tokens.

Decisiones de diseño:
- Tokenización: minúsculas, split por caracteres no alfanuméricos. No stemmer ni fuzzy por ahora (puede añadirse en PR siguiente).
- Indice en memoria reconstruido en carga inicial y tras operaciones CRUD.
- Búsqueda UI: debounce en 400ms (ya aplicado en `services_list_screen`).
- Tests: pruebas unitarias de rendimiento (benchmark sencillo con 5k items) y tests de integración leve.

Siguientes pasos recomendados:
- Añadir índice de trigramas o fuzzy search para tolerancia a errores tipográficos.
- Descargar/usar paquetes externos especializados (fuzzywuzzy/dart_fuzzy) si se requiere más precisión.
- Implementar índice persistido si los datasets crecen y la reconstrucción es costosa.
