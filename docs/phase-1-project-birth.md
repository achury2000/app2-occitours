# Phase 1 — Nacimiento del proyecto: poner la idea en marcha

Este documento cuenta, de forma informal y honesta, cómo arrancó el proyecto desde cero. No es un diario minuto a minuto, sino la versión humana de las decisiones importantes y los primeros pasos técnicos.

Qué quería lograr en esta fase:
- Validar la idea: una app para mostrar recorridos/tours/productos y permitir reservas simples.
- Tener algo que pueda demostrarse en 5 minutos: lista de productos, detalle y un login simulado.

Lo que hice (paso a paso):
1. Empecé por abrir un proyecto Flutter nuevo y decidir la estructura básica: `lib/`, `lib/models/`, `lib/providers/`, `lib/screens/`, `lib/data/`.
2. Escribí los modelos mínimos: `Product`, `User`, `Finca` — con solo los campos imprescindibles (id, nombre, precio, imágenes, role para usuarios).
3. Implementé un `ProductsProvider` con datos mock en `lib/data/mock_products.dart`. Esto permitió probar la UI sin backend.
4. Hice la pantalla `Home` y la navegación hacia `ProductDetail` para cerrar el flujo principal: ver catálogo → ver detalle.
5. Añadí un `AuthProvider` muy simple con users en `mock_users.dart` para simular login/logout y probar rutas protegidas.

Decisiones rápidas y atajos (lo que ahora explico con humildad):
- Usé datos mock en vez de una API para acelerar el feedback visual.
- Implementé `SharedPreferences` solo después; al principio todo era memoria para no perder tiempo en persistencia.

Lo que aprendí:
- Probar la interacción entre pantallas antes de optimizar modelos evita cambios estructurales grandes.
- Tener un `ProductsProvider` desde el inicio facilitó añadir filtros y paginación más adelante.

Resultado al finalizar la fase:
- Un MVP funcional: navegación, listado de productos, detalle y un login simulado. Listo para iterar.

Notas personales:
- Esta fase fue de prototipado rápido: pocos tests, muchas pruebas manuales con hot reload y comentarios de compañeros.
