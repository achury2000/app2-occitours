# Phase 8 — Monitoreo y analítica: saber qué pasa en producción

Objetivo : ya que la app funciona localmente y tenemos un pipeline, quería empezar a medir cómo se usa y detectar problemas reales en el uso, no sólo en pruebas.

Qué implementé/planeé en esta fase:

- Métricas mínimas a recoger:
  - Eventos: `login`, `create_reservation`, `cancel_reservation`, `checkout`.
  - Tasa de errores del lado cliente (excepciones no manejadas capturadas con try/catch y reportadas).
  - Uso por pantallas: número de vistas de `product_detail`, servicios más consultados.

- Herramientas sugeridas:
  - Un proveedor de analítica ligera (Mixpanel/Amplitude/Google Analytics) para eventos.
  - Sentry para capturar errores en tiempo real y stack traces (útil en mobile/web).

Checklist de acciones prácticas:

1. Instrumentar eventos críticos en el código: invocar una función `Analytics.track('create_reservation', {...})` al crear una reserva.
2. Configurar Sentry/otra herramienta con DSN en secretos del CI para no exponer claves en el repo.
3. Crear un panel simple (por ejemplo en Grafana) o usar el dashboard del proveedor para revisar eventos clave semanalmente.

Notas humanas y límites:

- Para la entrega educativa basta con un plan y la instrumentación mínima en puntos críticos; no es obligatorio tener dashboards complejos.
- Respecto a privacidad: evita enviar datos personales sin anonimizar. En vez de `user.email` envía `user.id` o un hash.

Recomendación final:

- Empezar por instrumentar 5–8 eventos importantes y Sentry; si el proyecto crece, ampliar métricas y visualizaciones.
