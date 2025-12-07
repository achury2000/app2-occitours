# Fase 8 - Facturación avanzada & Reportes

Objetivo: Añadir facturación formal (facturas/invoices), integrarlas con pagos y permitir exportes/reportes.

Entregables iniciales:
- Modelo `Invoice` y `InvoiceItem` en `lib/models/invoice.dart`.
- `InvoicesProvider` con CRUD, persistencia en `SharedPreferences`, auditoría, CSV import/export y métodos para cambiar estado y vincular pagos.
- UI básica: `InvoicesListScreen`, `InvoiceCreateScreen`, `InvoiceDetailScreen` (acciones emitir, marcar pagada).
- Test unitarios para `InvoicesProvider`.

Consideraciones:
- Integración real con emisores fiscales y PDF necesita pasos posteriores.
- Para conciliación, vincular `PaymentsProvider` y permitir marcar facturas como pagadas cuando se registre un pago.

Próximos pasos:
- Añadir pruebas widget para flujos de UI.
- Añadir export a PDF (placeholder) y reportes en `ReportsProvider`.
- Revisión y ejecución de `flutter analyze` y `flutter test` en entorno local.
