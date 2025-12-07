# Phase 9 — Internacionalización (i18n): preparar la app para más idiomas

Objetivo: hacer que la app no dependa del español por defecto y que se pueda traducir sin reescribir pantallas.

Qué hice y recomiendo:

- Preparar `arb` o archivos de recursos: extraer cadenas visibles de las pantallas a archivos de recursos (`lib/l10n/`) usando la convención de Flutter (`intl` o `flutter_localizations`).
- Decidir alcance: al principio traducir la interfaz (botones, labels, mensajes) y dejar contenido de usuario (reviews, descripciones largas) en su idioma original.

Checklist práctico:

1. Añadir `flutter_localizations` y configurar `MaterialApp` con `supportedLocales` y `localizationsDelegates`.
2. Extraer textos del UI a `intl`/`arb` y generar los bindings locales.
3. Proveer un selector de idioma en la pantalla de perfil o en settings para cambiar el idioma en tiempo de ejecución.

Notas humanas:

- No traduzcas todo desde el inicio: prioriza mensajes de error y las pantallas más usadas.
- Para la entrega, con soporte básico para `es` y `en` suele ser suficiente; el resto puede etiquetarse como roadmap.
