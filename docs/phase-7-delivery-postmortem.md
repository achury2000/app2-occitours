# Phase 7 — Entrega y post-mortem: cerrar el ciclo

Objetivo : preparar todo para la entrega final, dejar documentación clara y aprender para la próxima versión.

Checklist de entrega:

- Archivos y documentación incluidos:
  - `README.md` con pasos para ejecutar la app localmente y comandos de análisis/tests.
  - `docs/` con fases del proyecto (este conjunto de archivos) y notas de decisiones técnicas.
  - `CHANGELOG.md` con los cambios y la versión entregada (ej.: `v1.0-delivery`).

- Código y versiones:
  - Etiqueta git con la versión entregada.
  - `pubspec.yaml` con versiones fijas lo más posible.

- Entrega al profesor / cliente:
  - Video corto (2–3 min) mostrando flujos principales (login, reservar, ver carrito).
  - Instrucciones para ejecutar en emulador y en un dispositivo físico (APK).

Post-mortem (qué salió bien y qué mejorar):

- Lo bueno:
  - Prototipo iterativo que llegó a una versión funcional y testeable.
  - Parsers resilientes (fecha/CSV) evitaron errores por datos sucios.

- Para mejorar:
  - Integrar CI real antes de la entrega final para evitar builds locales que no reproducen el pipeline.
  - Mayor cobertura de tests en flujos críticos (pagos simulados, edge cases de reservas).
  - Mejor separación de responsabilidades en algunos providers (refactor futuro).

Próximos pasos sugeridos:

- Preparar un branch `release` y un tag `v1.0-delivery`, generar APK/IPA en CI y adjuntar al release.
- Hacer una sesión de demo con el profesor/cliente y pedir feedback concreto (bugs y mejoras UX).

Mensaje final (humano):

Si llegaste hasta aquí, bien jugado. Este proyecto fue armándose con pequeñas decisiones prácticas; no es perfecto, pero está pensado para ser entendible y ampliable. Si quieres, te ayudo a preparar el README final y el video corto para la entrega.
