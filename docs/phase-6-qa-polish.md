# Phase 6 — QA y pulido: dejar la app presentable y confiable

Objetivo: hacer que la app no sólo funcione, sino que también se sienta cuidada. Que un profesor o cliente pueda usarla sin tropezar con UX malas o errores evitables.

Actividades realizadas y checklist:

- Revisiones manuales:
  - Recorrido completo del flujo principal: login -> catálogo -> detalle -> reserva -> carrito -> pago simulado.
  - Verificación de mensajes: errores técnicos reemplazados por Snackbars/Dialogs comprensibles.

- Accesibilidad y texto:
  - Texto claro en botones y formularios.
  - Etiquetas en formularios y placeholders revisados (evitar textos en inglés sueltos).

- Performance básica:
  - Optimizar imágenes de galería usando URLs de tamaño razonable en vez de cargas enormes.
  - Evitar renders excesivos en listas largas (uso de `ListView.builder` donde aplica).

- Pruebas y casos límite:
  - Casos de CSV mal formateado: validar y mostrar un resumen de líneas rechazadas en el import.
  - Validaciones de reserva: horarios solapados, cupos excedidos, campos obligatorios.

- Documentación para QA:
  - Checklist rápido para quien pruebe la app:
    1. Iniciar sesión con usuario admin y cliente.
    2. Crear/editar un servicio y confirmar que aparece en la lista.
    3. Importar CSV con datos parcialmente mal formateados y revisar manejo de errores.
    4. Crear reservas simultáneas para el mismo horario y confirmar que la app bloquea duplicados.

Notas prácticas:

- No intenté automatizar todo: prioricé automatizar lo que protege refactors (reservas, autenticación, carrito).
- Para QA manual rápido, tener una pequeña lista de usuarios (admin/cliente) y pasos repetibles ayuda mucho.
