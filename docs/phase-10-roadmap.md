# Phase 10 — Hoja de ruta: qué sigue después de la entrega

Objetivo: dejar una guía clara de mejoras y prioridades para quien tome el proyecto después (o para continuar si decides seguir trabajando en él).

Prioridades a corto plazo (próximas 4–8 semanas):

1. Completar la cobertura de tests en flujos críticos: reservas, autenticación, carrito y parsers CSV.
2. Integrar CI real con builds automáticos y artifacts para QA (APK/IPA).
3. Mejorar la agenda: vista semanal, asignación de empleados y validación de cupos en tiempo real.

Prioridades a mediano plazo (2–4 meses):

1. Añadir autenticación real (OAuth2 / backend) y migrar de mocks a un backend simple (puede ser Firebase o un mock server alojado).
2. Implementar analítica y monitoreo (Sentry + panel de eventos).
3. Internacionalización (`es`, `en`) y accesibilidad básica.

Ideas a largo plazo (visión):

- Integrar pagos reales (con sandboxes) y manejo de facturación.
- Módulo de campañas y clientes: comunicación, segmentación y reportes más avanzados.
- Soporte offline parcial para zonas con conectividad limitada.

Consejo humano final:

Prioriza calidad sobre cantidad: una funcionalidad bien probada es más valiosa que muchas funciones que rompen en escenarios reales. Documenta decisiones y deja tickets claros para la siguiente persona.
