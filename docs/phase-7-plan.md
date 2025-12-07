# Fase 7 - Itinerarios y facturación avanzada

Objetivo: Permitir crear itinerarios (secuencia de rutas/fincas), gestionarlos, convertir un itinerario en reservas programadas, y preparar datos para facturación avanzada.

Entregables:
- Modelo `Itinerary` con serialización (`lib/models/itinerary.dart`).
- `ItinerariesProvider` con CRUD, persistencia en `SharedPreferences`, auditoría, export/import CSV y método `createReservationsFromItinerary` que crea reservas para cada paso del itinerario.
- UI: `ItinerariesListScreen`, `ItineraryCreateScreen`, `ItineraryDetailScreen` con acción para convertir en reservas.
- Tests unitarios para provider y tests de widget básicos.
- Documentación de la fase y notas para integración con facturación.

Notas técnicas y consideraciones:
- `createReservationsFromItinerary` usa `ReservationsProvider.addReservation` para crear reservas; las validaciones (cupos, solapamientos) quedan a cargo de `ReservationsProvider`.
- Para facturación avanzada: implementar en próximas iteraciones conciliación, generación de facturas PDF y reportes en `ReportsProvider`.

Próximos pasos:
1. Ejecutar `flutter analyze` y `flutter test` localmente.
2. Añadir pruebas de UI si es necesario.
3. Integrar conversión de itinerario en generación de factura/orden de cobro.
