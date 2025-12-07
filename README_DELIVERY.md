# README_DELIVERY.md — Guía para el profesor

Este archivo está pensado como una guía rápida y directa para que el profesor pueda reproducir la demo, probar los flujos críticos y evaluar la entrega sin perder tiempo buscando información.

---

## Requisitos previos

### 1. Instalar PostgreSQL

1. Descargar PostgreSQL desde: https://www.postgresql.org/download/
2. Durante la instalación:
   - Establecer una contraseña para el usuario `postgres` (anótala, la necesitarás)
   - Puerto por defecto: `5432`
   - Asegúrate de instalar también pgAdmin 4 (herramienta de administración gráfica)

3. Después de la instalación, verifica que PostgreSQL esté corriendo:
   ```powershell
   # En PowerShell
   Get-Service postgresql*
   # Debería mostrar "Running"
   ```

### 2. Crear la base de datos

1. Abrir pgAdmin 4 o usar psql desde la terminal:
   ```powershell
   # Conectar a PostgreSQL
   psql -U postgres
   ```

2. Crear la base de datos:
   ```sql
   CREATE DATABASE occitours_db;
   ```

3. Salir de psql:
   ```sql
   \q
   ```

### 3. Inicializar el esquema y datos

Navegar a la carpeta del proyecto y ejecutar los scripts SQL (ajusta la ruta según donde clonaste):

```powershell
# Desde la raíz del proyecto
cd "ruta\donde\clonaste\app2-occitours\database"
# Ejemplo: cd "C:\Users\TuUsuario\Desktop\app2-occitours\database"

# Ejecutar el script de esquema (crea las tablas)
psql -U postgres -d occitours_db -f 01_schema.sql

# Ejecutar el script de datos de ejemplo (seeds)
psql -U postgres -d occitours_db -f 02_seeds.sql
```

**Nota**: Cuando te pida la contraseña, usa la que estableciste durante la instalación de PostgreSQL.

### 4. Configurar el backend (.env)

1. Navegar a la carpeta backend (ajusta la ruta según donde clonaste el repositorio):
   ```powershell
   cd "ruta\donde\clonaste\app2-occitours\backend"
   # Ejemplo: cd "C:\Users\TuUsuario\Desktop\app2-occitours\backend"
   ```

2. Crear un archivo `.env` (si no existe) con el siguiente contenido:
   ```env
   # Configuración de PostgreSQL
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=tu_contraseña_aqui
   DB_NAME=occitours_db

   # Puerto del servidor
   PORT=3000

   # JWT Secret (para autenticación)
   JWT_SECRET=occitours_secret_key_2024
   ```

   **IMPORTANTE**: Reemplaza `tu_contraseña_aqui` con la contraseña que estableciste para PostgreSQL.

3. Instalar dependencias de Node.js:
   ```powershell
   npm install
   ```

4. Iniciar el servidor backend:
   ```powershell
   node server.js
   ```

   Deberías ver algo como:
   ```
   ✅ Servidor corriendo en puerto 3000
   ✅ Base de datos conectada
   📡 Endpoints disponibles:
      - GET  /api/clientes
      - GET  /api/fincas
      - GET  /api/rutas
      - GET  /api/servicios
      - GET  /api/reservas
      - GET  /api/ventas
      - GET  /api/dashboard/stats
      ...
   ```

**Nota**: Mantén esta terminal abierta mientras usas la aplicación. El backend debe estar corriendo para que la app Flutter funcione correctamente.

---

## Cuentas de prueba

Usa estas cuentas en la pantalla de login:

- Admin:
  - Email: `admin@occitours.com`
  - Password: `admin123`
  - Rol: `admin`

- Cliente:
  - Email: `cliente1@occitours.com`
  - Password: `cliente123`
  - Rol: `cliente`

**Nota**: Estas cuentas están en la base de datos después de ejecutar el script `02_seeds.sql`. Si necesitas crear más usuarios, puedes hacerlo desde el panel de administración o directamente en la base de datos.

---

## Script de demo (paso a paso — PowerShell)

Objetivo: mostrar al profesor los flujos clave en ~3–5 minutos.

**IMPORTANTE**: Antes de ejecutar la app Flutter, asegúrate de que el backend esté corriendo (ver sección anterior).

```powershell
# 1) Abrir una NUEVA terminal PowerShell para el frontend (ajusta la ruta según donde clonaste)
Set-Location 'ruta\donde\clonaste\app2-occitours'
# Ejemplo: Set-Location 'C:\Users\TuUsuario\Desktop\app2-occitours'
flutter pub get

# 2) Verificar que el backend esté corriendo
# Debe haber una terminal activa mostrando "Servidor corriendo en puerto 3000"

# 3) Iniciar en el primer emulador Android disponible (si existe)
.\run_on_first_android_emulator.ps1

# 4) (Alternativa) Ejecutar la app manualmente
# flutter run

# 5) Flujo demo (manual, en la app)
# - Login con admin@occitours.com / admin123
# - Ir a Panel de Administración -> Ver estadísticas en Dashboard
# - Ir a Gestión de Ventas -> Ver ventas existentes
# - Ir a Dashboard Avanzado -> Ver gráficos de ingresos mensuales
# - Como cliente: iniciar sesión con cliente1@occitours.com / cliente123 y explorar catálogo
# - Ver fincas y rutas disponibles
# - Hacer una reserva y verificarla en el panel de admin

# 6) Opcional: ejecutar tests rápidos
flutter test
flutter analyze
```

### Verificación rápida del sistema

Para verificar que todo esté funcionando correctamente:

1. **Backend corriendo**: 
   - Abre http://localhost:3000/api/fincas en el navegador
   - Deberías ver un JSON con la lista de fincas

2. **Base de datos con datos**:
   ```powershell
   psql -U postgres -d occitours_db -c "SELECT COUNT(*) FROM fincas;"
   # Debería mostrar: count > 0
   ```

3. **App Flutter conectada**:
   - En la app, después de login como admin
   - Dashboard debería mostrar estadísticas reales (no ceros)

---
## Problemas conocidos y notas para el corrector

- **Backend requerido**: La aplicación requiere que el backend Node.js esté corriendo en `localhost:3000` para funcionar correctamente.
- **PostgreSQL**: Asegúrate de tener PostgreSQL instalado y la base de datos inicializada con los scripts proporcionados.
- **Datos de ejemplo**: El sistema incluye ~30 reservas de ejemplo distribuidas en los últimos 6 meses para demostrar las funcionalidades de analytics.
- **Agenda**: implementación mínima (vista día-a-día). No es un calendario completo.
- **Pagos**: Los flujos de pago son simulados (no hay integración real con pasarelas de pago).

---

## Estructura del proyecto

```
app2-occitours/
├── backend/              # Servidor Node.js + Express
│   ├── routes/          # Endpoints API (fincas, rutas, servicios, reservas, ventas, dashboard)
│   ├── config/          # Configuración de base de datos
│   ├── middleware/      # Autenticación JWT
│   ├── server.js        # Punto de entrada del servidor
│   └── .env            # Configuración de PostgreSQL (CREAR ESTE ARCHIVO)
├── database/            # Scripts SQL
│   ├── 01_schema.sql   # Estructura de base de datos
│   └── 02_seeds.sql    # Datos de ejemplo
├── lib/                 # Código Flutter
│   ├── screens/        # Pantallas de la app
│   ├── services/       # ApiService para comunicación con backend
│   ├── providers/      # Gestión de estado
│   └── main.dart       # Punto de entrada de Flutter
└── test/               # Tests unitarios y de widgets
```

---

## Endpoints principales del backend

Una vez el backend esté corriendo, puedes probar estos endpoints en el navegador o Postman:

**Gestión básica:**
- `GET http://localhost:3000/api/fincas` - Lista de fincas
- `GET http://localhost:3000/api/rutas` - Lista de rutas
- `GET http://localhost:3000/api/servicios` - Lista de servicios
- `GET http://localhost:3000/api/clientes` - Lista de clientes
- `GET http://localhost:3000/api/reservas` - Lista de reservas

**Ventas:**
- `GET http://localhost:3000/api/ventas` - Lista de ventas
- `POST http://localhost:3000/api/ventas` - Crear venta
- `POST http://localhost:3000/api/ventas/:id/abono` - Agregar pago a venta

**Dashboard y Analytics:**
- `GET http://localhost:3000/api/dashboard/stats` - Estadísticas generales
- `GET http://localhost:3000/api/dashboard/ingresos-mensuales?year=2025` - Ingresos por mes
- `GET http://localhost:3000/api/dashboard/top-fincas` - Top 5 fincas más reservadas
- `GET http://localhost:3000/api/dashboard/top-rutas` - Top 5 rutas más populares
- `GET http://localhost:3000/api/dashboard/top-servicios` - Top 5 servicios más vendidos

---

## Materiales adicionales para la entrega

- `CHANGELOG.md`: resumen de cambios (crear si se desea un resumen formal).
- Tag sugerido: `v1.0-delivery`.
- Si el profesor desea, puedo preparar un video de 2–3 minutos y un APK listo para descargar.

---
