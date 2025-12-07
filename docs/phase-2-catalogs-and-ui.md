# Phase 2 — Catálogos y UI: darle forma a la experiencia

En esta fase dejé de jugar con mocks improvisados y empecé a pensar la experiencia: cómo navega el usuario, qué información necesita y cómo mantener el estado.

Objetivos:
- Organizar catálogos (fincas, rutas, servicios) y crear pantallas de CRUD básicas.
- Mejorar `ProductsProvider` con filtros y paginación para que la UI no se trabe con muchos items.

Pasos realizados:
1. Creé providers adicionales: `FincasProvider`, `RoutesProvider`, `ItinerariesProvider`.
2. Añadí pantallas de lista y detalle para cada catálogo (`services_list`, `finca_detail`, `routes_screen`).
3. Implementé paginación y búsqueda en `ProductsProvider` para simular experiencia real de catálogo.
4. Añadí pequeños componentes reutilizables: tarjetas de producto, chips de filtros y un header común.
5. Empecé a documentar internamente con comentarios en español y docblocks para que el equipo (y el profesor) entienda las responsabilidades de cada provider.

Dificultades y soluciones prácticas:
- En CSV y datos externos encontré formatos inconsistentes; escribí parsers más tolerantes y `parseDateFlexible` para evitar crashes.
- La UI necesitaba mensajes claros: reemplazé errores técnicos por Snackbars y placeholders entendibles.

Resultado:
- Catálogos funcionales, pantallas más consistentes y una base estable para introducir reglas de negocio.

Pequeña nota humana:
- Esta fue la fase donde empecé a aburrirme de rehacer lo mismo y decidí que la estructura debía resistir cambios. Ahí nació la idea de escribir tests.
