# Documentación de Estados

Este documento resume los "states" (providers) implementados en la aplicación, sus responsabilidades, funciones públicas y datos mock. Sirve para la entrega y evaluación según la rúbrica.

## Resumen
Los providers están en `lib/providers/` y gestionan los siguientes estados:

- `AuthProvider` — autenticación y sesiones.
- `ProductsProvider` — lista de productos, filtros, ordenamiento y paginación.
- `Product` detail — información del producto individual (modelo `Product`).
- `ProfileProvider` — perfil de usuario y edición simulada.
- `CartProvider` — carrito de compras con CRUD, cupones y persistencia mock.
- `ReservationsProvider` — programación/agenda de rutas/paquetes/fincas.
- `ReportsProvider` — generación de métricas y datos para gráficos.
- `ItinerariesProvider`, `FincasProvider`, `ServicesProvider`, `RoutesProvider` — catálogos y CRUD.

Cada proveedor simula llamadas asíncronas con `Future.delayed` y persiste datos en `SharedPreferences` (mock en tests).

---

## `AuthProvider` (lib/providers/auth_provider.dart)
Responsabilidad:
- Gestiona estado de autenticación: `login`, `logout`, `verifySession`.
- Persiste token y userId en `SharedPreferences`.
- Mock: usuarios definidos en `lib/data/mock_users.dart`.

API pública principal:
- `Future<void> login(String email, String password)` — simula llamada, guarda token.
- `Future<void> logout()` — elimina token y usuario.
- `Future<void> verifySession()` — verifica token almacenado.
- `bool hasAnyRole(List<String> roles)` — valida roles.

Datos almacenados:
- `User? user` — información del usuario.
- `String? token` — token simulado.

Notas de evaluación: cumple criterios de autenticación y manejo de errores.

---

## `ProductsProvider` (lib/providers/products_provider.dart)
Responsabilidad:
- Mantener catálogo de productos.
- Búsqueda optimizada (índice invertido), filtros por categoría, ordenamiento y paginación.
- Import/Export CSV básico.

API pública principal:
- `Future<void> loadInitial({String? category, String? query, ProductSort? sort})`
- `Future<void> loadMore()`
- `Future<void> addProduct(Product p)`
- `Future<void> updateProduct(Product p)`
- `Future<void> deleteProduct(String id)`
- `String exportCsv()` / `Future<void> importFromCsv(String csv, {bool updateExisting = true})`

Datos mock: `lib/data/mock_products.dart` contiene 28 productos realistas.

---

## `Product Detail` (model `lib/models/product.dart` + UI `product_detail_screen.dart`)
Responsabilidad:
- Mostrar información completa del producto: id, código, nombre, descripción, precio, imágenes, variantes y stock.
- Indicar reviews simuladas (cuando existen) y productos relacionados por categoría.

---

## `ProfileProvider` (lib/providers/profile_provider.dart)
Responsabilidad:
- Cargar perfil desde mock y permitir edición simulada.
- Persistir cambios locales en `SharedPreferences`.

API pública:
- `Future<void> loadProfile(String userId)`
- `Future<void> updateProfile(User updated)`

---

## `CartProvider` (lib/providers/cart_provider.dart)
Responsabilidad:
- CRUD de items en carrito, cantidades, variantes.
- Aplicar cupones simulados (ej.: `DESC10`, `FREESHIP`).
- Calcular subtotal, envío y total; persistencia local.

API pública:
- `void addProduct(Product p, {int qty = 1, String? variant})`
- `void removeProduct(String productId, {String? variant})`
- `void updateQuantity(String productId, int qty, {String? variant})`
- `bool applyCoupon(String code)`
- `void clear()`

---

## `ReservationsProvider` (lib/providers/reservations_provider.dart)
Responsabilidad:
- Gestionar la programación/agenda: crear, editar, eliminar (con reglas), buscar y export/import CSV.
- Validación clave: no duplicidad de programación (mismo servicio/ruta/finca + fecha + hora).
- Registro de auditoría en `_audit` y persistencia.

API pública relevante:
- `Future<String> addReservation(Map<String,dynamic> data)` — valida campos y duplicidad.
- `Future<void> updateReservation(String id, Map<String,dynamic> data)` — valida duplicidad al actualizar.
- `Future<void> deleteReservation(String id)` — impide borrar si actividad en curso.
- `bool existsSameSchedule({String? service, String? date, String? time, String? excludeId})` — helper para reglas de duplicidad.
- `List<Map<String,dynamic>> search({String? query, String? service, String? status, DateTime? from, DateTime? to, String? clientId})`.

Notas:
- Se agregó `existsSameSchedule` para centralizar validación.
- Importa `lib/utils/date_utils.dart` para parseo flexible.

---

## `ReportsProvider` (lib/providers/reports_provider.dart)
Responsabilidad:
- Generar datos para gráficos a partir de reservas (ventas, top products, ingresos, satisfacción).
- Simula latencia y devuelve estructuras adecuadas para charts.

Notas:
- Usa parseDateFlexible para robustecer parseo de fechas en datos importados.

---

## Tests y entorno
- `test/test_helpers.dart` contiene utilidades para tests: fake HttpClient y `initTestEnvironment()` que inicializa `TestWidgetsFlutterBinding` y `SharedPreferences.setMockInitialValues({})`.
- Muchos tests usan `initTestEnvironment` o inicializan binding en `setUpAll`.

---

## Cómo extender y pruebas
- Para añadir validaciones adicionales (por ejemplo: bloqueo de eliminación de ruta si está en programación activa), ampliar los providers relevantes (`RoutesProvider`, `ReservationsProvider`) y añadir tests unitarios en `test/unit/`.
