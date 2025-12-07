# Fase 4 — Servicios y Agenda (cómo lo implementé en la práctica)

Esta fase fue una mezcla de diseño funcional y de pedirle paciencia al equipo: la idea era tener servicios gestionables y una agenda que permita ver ocupación por día.

Resumen humano de lo que implementé:

- Modelé `Service` (`lib/models/service.dart`) con los campos esenciales: `id`, `name`, `description`, `durationMinutes`, `capacity`, `price` y `active`.
- Implementé `ServicesProvider` (`lib/providers/services_provider.dart`) con un CRUD sencillo, persistencia en `SharedPreferences` (`services_v1`) y una lista de auditoría en memoria para revisar cambios durante la sesión.
- En la UI creé tres piezas:
  - `ServicesListScreen`: lista con búsqueda y un FAB para crear/editar (visible solo para admins).
  - `ServiceDetailScreen`: formulario con validaciones básicas (duración > 0, capacidad positiva, precio >= 0).
  - `ServicesAgendaScreen`: vista diaria que muestra cuántas reservas hay para cada horario; actualmente es una implementación mínima que sirve para pruebas y demos.

Tests que agregué:

- `test/unit/services_provider_test.dart`: pruebas unitarias para el flujo CRUD e import/export CSV.
- `test/widget/services_flow_test.dart`: prueba widget que cubre crear un servicio y ver la agenda (usa mocks para SharedPreferences).

Decisiones prácticas y por qué las tomé:

- Guardé auditoría en memoria para evitar complicar la persistencia al principio; es suficiente para la entrega y facilita debugging en desarrollo.
- No integré un calendario completo (por tiempo). Preferí una vista diaria funcional y dejar la integración con `table_calendar` como recomendación futura.

Recomendaciones inmediatas:

- Añadir asignación de empleados por servicio y validación de cupos antes de confirmar una reserva.
- Mejorar la agenda con vista semanal y creación directa desde calendario (drag & drop o diálogo rápido).
- Añadir tests que cubran casos límite en CSV (campos faltantes, horas solapadas, formatos de fecha raros).

Estado actual: funcionalidad entregada en forma mínima y testeable; lista para iterar y enriquecer.
