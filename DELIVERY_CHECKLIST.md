# Checklist de entrega

- [ ] Ejecutar `flutter pub get` y verificar que no haya errores.
- [ ] Correr `flutter analyze` y resolver warnings críticos.
- [ ] Ejecutar `flutter test` y confirmar que todos los tests pasen.
- [ ] Ejecutar la app en un emulador Android y verificar rutas principales:
  - Login (usar `cliente@demo.com`)
  - Lista de productos, paginación, filtros
  - Detalle de producto y añadir al carrito
  - Carrito: actualizar cantidades, aplicar cupón `DESC10` o `FREESHIP`, checkout simulado
  - Perfil: editar y persistir
  - Reportes: Generar y revisar los tres gráficos
- [ ] Formatear código con `dart format .`
- [ ] Limpiar imports y warnings
- [ ] Generar un ZIP o commit final y entregar

Notas:
- Los datos son mocks; si deseas integraciones reales, se necesita una API backend.
- Si encuentras errores en tiempo de ejecución, pasar logs para corrección.
