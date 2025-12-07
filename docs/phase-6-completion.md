// parte linsaith
// parte juanjo

# Fase 6 - Pagos y facturación

Resumen de entregables:

- Modelo `Payment` (`lib/models/payment.dart`) con serialización JSON.
- `PaymentsProvider` (`lib/providers/payments_provider.dart`) con:
  - Persistencia en `SharedPreferences`.
  - Auditoría de operaciones (create/update/delete/import).
  - Export/Import CSV simple.
  - Validaciones básicas (monto > 0).
- UI:
  - `PaymentsListScreen` (`lib/screens/payments_list_screen.dart`) - listado, búsqueda, navegación a detalle/crear.
  - `PaymentCreateScreen` (`lib/screens/payment_create_screen.dart`) - formulario de creación.
  - `PaymentDetailScreen` (`lib/screens/payment_detail_screen.dart`) - vista de detalle.
- Integración:
  - Al crear un `Payment` vinculado a una `reservationId`, se marca la reserva como `Pagada` mediante `ReservationsProvider.setReservationStatus`.
- Tests:
  - `test/unit/payments_provider_test.dart` con cobertura básica: crear, buscar, exportar/importar CSV y eliminar.

Notas de implementación y recomendaciones:

- Los endpoints/servicios de pago reales (pasarelas) no están integrados; la creación de pagos aquí es local y marca la reserva como pagada para efectos de flujo.
- Para producción sería necesario:
  - Integrar una pasarela (Stripe, PayU, etc.) y validar estados via webhooks.
  - Añadir historial de transacciones y conciliación contable.
  - Encriptar/asegurar la información sensible (nunca almacenar números completos de tarjeta en texto claro).

Próximos pasos sugeridos antes de Fase 7:
- Añadir tests de widget para flujo UI (crear pago → ver detalle).
- Implementar conciliación y reportes de facturación en `ReportsProvider`.
- Revisar UX para estados de pago y reintentos.

