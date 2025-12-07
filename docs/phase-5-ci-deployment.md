# Phase 5 — CI y despliegue: asegurar que se construye fuera del entorno de desarrollo

Objetivo : hacer que la app se construya siempre de la misma manera, con pruebas mínimas en cada cambio, para no llevar sorpresas el día de la entrega.

Qué incluí en esta fase:

- Pipeline básico (ejemplo): configuré mentalmente y dejé notas para un flujo de CI (GitHub Actions / GitLab CI) que realiza:
  1. `flutter pub get`
  2. `flutter analyze` (errores y advertencias críticas)
  3. `flutter test` (unidad y widget tests básicos)
  4. `flutter build apk --release` (o `flutter build ipa` en caso de iOS, con pasos de code signing separados)

- Artefactos: el pipeline debería publicar artefactos (APK/IPA) o subirlos a un sistema de releases para QA.

Notas prácticas y decisiones:

- Para el entorno de CI es recomendable usar imágenes con Flutter ya instaladas o runners self-hosted preparados (por ejemplo: runner Windows para builds Android que requieran herramientas específicas).
- Las claves de firma (keystore, certificados) no se suben al repo; se cargan en secretos del repositorio/CI y se referencia en el pipeline.

Script útil (ejemplo para GitHub Actions - idea):

1. `checkout`
2. `setup-flutter` (versión estable en `pubspec.yaml`) 
3. `flutter pub get`
4. `flutter analyze --no-fatal-infos`
5. `flutter test --coverage`
6. `flutter build apk --release` (subir como artifact)

Recomendaciones concretas antes de desplegar:

- Asegurar que `test/test_helpers.dart` está en buen estado para que los widget tests no fallen por dependencias externas (tiles/HTTP, SharedPreferences).
- Mantener `flutter analyze` limpio o con un mínimo aceptable de advertencias antes de la entrega.
- Crear una etiqueta (git tag) para releases y documentar en el changelog qué se entrega.

Pequeños tips humanos:

- No hay nada peor que un build que sólo funciona en tu máquina. Si algo falla en CI, mira primero las versiones de Flutter y las dependencias.
- Mantén scripts de build simples para la entrega; evita pipelines excesivamente largos que rompan por pasos no esenciales.
