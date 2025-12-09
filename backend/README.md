# 🚀 API Occitours - Express + PostgreSQL

API REST para el sistema de reservas turísticas Occitours.

## 📋 Requisitos

- Node.js 16+
- PostgreSQL 12+
- Base de datos `occitours` creada y con datos iniciales

## ⚙️ Instalación

1. **Instalar dependencias:**
```bash
cd backend
npm install
```

2. **Configurar base de datos:**
Edita el archivo `.env` con tus credenciales de PostgreSQL:
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=tu_password
DB_NAME=occitours
```

3. **Iniciar servidor:**
```bash
# Modo desarrollo (con nodemon)
npm run dev

# Modo producción
npm start
```

El servidor correrá en: `http://localhost:3000`

---

## 📊 Arquitectura del Backend

### 🗂️ Estructura de Carpetas

```
backend/
├── server.js              # Punto de entrada (Express + middleware)
├── config/
│   └── database.js        # Pool de conexiones PostgreSQL
├── middleware/
│   └── auth.js            # Validación de tokens JWT
└── routes/                # Módulos de endpoints (10 archivos)
    ├── auth.js            # Autenticación (login, register, profile)
    ├── fincas.js          # CRUD de fincas turísticas
    ├── rutas.js           # CRUD de rutas naturales
    ├── servicios.js       # CRUD de servicios adicionales
    ├── clientes.js        # Gestión de clientes
    ├── programaciones.js  # Programación de tours
    ├── reservas.js        # CRUD de reservas (auto-crea ventas)
    ├── ventas.js          # CRUD de ventas y abonos
    ├── roles.js           # Roles y permisos
    └── dashboard.js       # Analíticas y estadísticas
```

### 🔄 Flujo de una Petición HTTP

```
1. Cliente (Flutter)
   ↓
   POST /api/reservas
   Headers: { Authorization: Bearer <token> }
   Body: { cliente_id, finca_id, fecha, ... }
   ↓
2. server.js (Express)
   ↓
   CORS → body-parser → route matching
   ↓
3. middleware/auth.js (si endpoint requiere autenticación)
   ↓
   Verificar JWT token → extraer userId y rol
   ↓
4. routes/reservas.js
   ↓
   Validar datos → Consulta SQL (INSERT INTO reservas...)
   ↓
5. config/database.js
   ↓
   Pool de conexiones → PostgreSQL
   ↓
6. Respuesta al cliente
   ↓
   { success: true, reserva: {...}, venta_id: 8 }
```

### 🔧 Tecnologías Utilizadas

- **Express.js** 4.18+ - Framework web minimalista
- **PostgreSQL** 12+ - Base de datos relacional
- **node-postgres (pg)** - Driver de PostgreSQL
- **JWT (jsonwebtoken)** - Tokens de autenticación
- **Bcrypt** - Hash de contraseñas (10 salt rounds)
- **CORS** - Habilitado para Flutter
- **dotenv** - Variables de entorno

---

## 🔐 Endpoints de Autenticación

### 1. Login - POST `/api/auth/login`

Inicia sesión y obtiene un token JWT (válido 5 minutos).

**Request:**
```json
{
  "email": "admin@occitours.com",
  "password": "123456"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login exitoso",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usuario": {
    "id": 1,
    "nombre": "Yeison",
    "apellido": "Uribe",
    "cedula": "1234567890",
    "email": "admin@occitours.com",
    "rol": "admin"
  }
}
```

**Errores:**
- `400` - Campos incompletos
- `401` - Email o contraseña incorrectos
- `403` - Cuenta inactiva

---

### 2. Registro - POST `/api/auth/register`

Registra un nuevo usuario con rol "cliente" automáticamente.

**Request:**
```json
{
  "nombre": "Juan",
  "apellido": "Pérez",
  "cedula": "1234567895",
  "email": "juan@example.com",
  "password": "mipassword123",
  "telefono": "3001234567"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Usuario registrado exitosamente",
  "usuario": {
    "id": 5,
    "nombre": "Juan",
    "apellido": "Pérez",
    "cedula": "1234567895",
    "email": "juan@example.com",
    "rol": "cliente"
  }
}
```

**Errores:**
- `400` - Campos incompletos o contraseña débil
- `409` - Email o cédula ya registrados

---

### 3. Perfil - GET `/api/auth/profile`

Obtiene la información del usuario autenticado.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "success": true,
  "usuario": {
    "id": 1,
    "nombre": "Yeison",
    "apellido": "Uribe",
    "cedula": "1234567890",
    "email": "admin@occitours.com",
    "activo": true,
    "fecha_registro": "2025-12-03T10:00:00.000Z",
    "ultimo_login": "2025-12-03T14:30:00.000Z",
    "rol": "admin"
  }
}
```

**Errores:**
- `403` - Token no proporcionado
- `401` - Token expirado o inválido

---

### 4. Logout - POST `/api/auth/logout`

Cierra la sesión del usuario.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "success": true,
  "message": "Sesión cerrada exitosamente"
}
```

---

## 🔒 Seguridad

- **JWT:** Tokens con expiración de 5 minutos de inactividad
- **Bcrypt:** Contraseñas hasheadas con salt de 10 rondas
- **CORS:** Habilitado para Flutter
- **Validación:** Campos obligatorios y formatos validados

---

## 🧪 Pruebas con usuarios existentes

Estos usuarios ya están en la BD (contraseña: `123456`):

| Email | Rol | Contraseña |
|-------|-----|------------|
| admin@occitours.com | admin | 123456 |
| asesor@occitours.com | asesor | 123456 |
| cliente@demo.com | cliente | 123456 |
| guia@occitours.com | guia | 123456 |

---

## 📚 Documentación de API

### 📋 Lista de Endpoints Disponibles

La API cuenta con los siguientes módulos y endpoints:

#### **Autenticación (`/api/auth`)**
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/register` - Registrar nuevo usuario
- `GET /api/auth/profile` - Obtener perfil del usuario autenticado
- `POST /api/auth/logout` - Cerrar sesión
- `PUT /api/auth/users/:id` - Actualizar datos del usuario

#### **Fincas (`/api/fincas`)**
- `GET /api/fincas` - Listar todas las fincas
- `GET /api/fincas/:id` - Obtener detalles de una finca
- `POST /api/fincas` - Crear nueva finca (requiere auth)
- `PUT /api/fincas/:id` - Actualizar finca (requiere auth)
- `DELETE /api/fincas/:id` - Eliminar finca (requiere auth)

#### **Rutas (`/api/rutas`)**
- `GET /api/rutas` - Listar todas las rutas naturales
- `GET /api/rutas/:id` - Obtener detalles de una ruta
- `POST /api/rutas` - Crear nueva ruta (requiere auth)
- `PUT /api/rutas/:id` - Actualizar ruta (requiere auth)
- `DELETE /api/rutas/:id` - Eliminar ruta (requiere auth)

#### **Servicios Adicionales (`/api/servicios`)**
- `GET /api/servicios` - Listar servicios (alimentación, transporte)
- `GET /api/servicios/:id` - Obtener detalles de un servicio
- `POST /api/servicios` - Crear nuevo servicio (requiere auth)
- `PUT /api/servicios/:id` - Actualizar servicio (requiere auth)
- `DELETE /api/servicios/:id` - Eliminar servicio (requiere auth)

#### **Clientes (`/api/clientes`)**
- `GET /api/clientes` - Listar todos los clientes
- `GET /api/clientes/cedula/:cedula` - Buscar cliente por cédula
- `GET /api/clientes/:id` - Obtener detalles de un cliente
- `POST /api/clientes` - Crear nuevo cliente
- `PUT /api/clientes/:id` - Actualizar cliente
- `DELETE /api/clientes/:id` - Eliminar cliente

#### **Programaciones (`/api/programaciones`)**
- `GET /api/programaciones` - Listar programaciones de tours
- `GET /api/programaciones/:id` - Obtener detalles de una programación
- `POST /api/programaciones` - Crear nueva programación
- `PUT /api/programaciones/:id` - Actualizar programación
- `DELETE /api/programaciones/:id` - Eliminar programación

#### **Reservas (`/api/reservas`)**
- `GET /api/reservas` - Listar todas las reservas
- `GET /api/reservas/:id` - Obtener detalles de una reserva
- `GET /api/reservas/cliente/:clienteId` - Reservas de un cliente específico
- `POST /api/reservas` - Crear nueva reserva (auto-crea venta)
- `PUT /api/reservas/:id` - Actualizar reserva (actualiza venta asociada)
- `DELETE /api/reservas/:id` - Cancelar reserva

#### **Ventas (`/api/ventas`)**
- `GET /api/ventas` - Listar todas las ventas
- `GET /api/ventas/:id` - Obtener detalles de una venta con abonos
- `POST /api/ventas` - Crear nueva venta manual
- `PUT /api/ventas/:id` - Actualizar venta
- `DELETE /api/ventas/:id` - Eliminar venta (y reservas asociadas)
- `POST /api/ventas/:id/abonos` - Registrar abono/pago

#### **Roles y Permisos (`/api/roles`)**
- `GET /api/roles` - Listar roles con permisos
- `GET /api/roles/:id` - Obtener detalles de un rol
- `POST /api/roles` - Crear nuevo rol
- `PUT /api/roles/:id` - Actualizar rol y permisos

#### **Dashboard y Analíticas (`/api/dashboard`)**
- `GET /api/dashboard/stats` - Estadísticas generales (totales)
- `GET /api/dashboard/ingresos-mensuales` - Ingresos por mes (12 meses)
- `GET /api/dashboard/top-fincas` - Top 5 fincas más reservadas
- `GET /api/dashboard/top-rutas` - Top 5 rutas más populares
- `GET /api/dashboard/top-servicios` - Top 5 servicios más vendidos
- `GET /api/dashboard/reservas-recientes` - Últimas 10 reservas

---

### 🔧 Estructura de Requests y Responses

#### **Formato General de Respuestas Exitosas**
```json
{
  "success": true,
  "message": "Operación exitosa",
  "data": { /* objeto o array con datos */ }
}
```

#### **Formato General de Errores**
```json
{
  "success": false,
  "message": "Descripción del error",
  "error": "Detalles técnicos (solo en desarrollo)"
}
```

#### **Ejemplo: Crear Reserva**
**Request:** `POST /api/reservas`
```json
{
  "cliente_id": 3,
  "finca_id": 1,
  "programacion_id": 2,
  "fecha": "2025-12-25",
  "numero_personas": 4,
  "precio_total": 400000,
  "servicios": [
    { "servicio_id": 1, "cantidad": 4, "precio_unitario": 25000 },
    { "servicio_id": 3, "cantidad": 1, "precio_unitario": 80000 }
  ]
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Reserva creada exitosamente",
  "reserva": {
    "id": 15,
    "cliente_id": 3,
    "finca_id": 1,
    "fecha": "2025-12-25T00:00:00.000Z",
    "numero_personas": 4,
    "precio_total": 400000,
    "estado": "pendiente"
  },
  "venta_id": 8
}
```

#### **Ejemplo: Dashboard Stats**
**Request:** `GET /api/dashboard/stats`

**Response (200):**
```json
{
  "success": true,
  "stats": {
    "totalFincas": 5,
    "totalRutas": 4,
    "totalServicios": 6,
    "totalClientes": 12,
    "totalReservas": 45,
    "totalVentas": 38,
    "ingresosTotal": 28500000
  }
}
```

---

### 🔐 Manejo de Autenticación

#### **1. Obtener Token JWT**
Al hacer login exitoso, el servidor retorna un token:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbCI6ImFkbWluIiwiaWF0IjoxNzMzNjQ4NDAwfQ.xxx"
}
```

#### **2. Incluir Token en Requests Protegidos**
Para endpoints que requieren autenticación, incluir el header:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### **3. Endpoints Públicos vs Protegidos**

**Públicos (sin token):**
- `POST /api/auth/login`
- `POST /api/auth/register`
- `GET /api/fincas` (solo lectura)
- `GET /api/rutas` (solo lectura)
- `GET /api/servicios` (solo lectura)

**Protegidos (requieren token):**
- Todos los `POST`, `PUT`, `DELETE` (crear/modificar/eliminar)
- `GET /api/auth/profile`
- `GET /api/dashboard/*` (analíticas)
- `GET /api/ventas` (datos sensibles)

#### **4. Manejo de Errores de Autenticación**

**Token no proporcionado (403):**
```json
{
  "success": false,
  "message": "Token no proporcionado"
}
```

**Token expirado o inválido (401):**
```json
{
  "success": false,
  "message": "Token inválido o expirado"
}
```

**Sin permisos suficientes (403):**
```json
{
  "success": false,
  "message": "No tienes permisos para esta acción"
}
```

#### **5. Configuración de Seguridad**

- **Algoritmo:** HS256 (HMAC SHA-256)
- **Expiración:** 5 minutos de inactividad
- **Secret:** Variable de entorno `JWT_SECRET`
- **Payload:** `{ userId, rol, iat, exp }`
- **Hash de contraseñas:** Bcrypt con 10 salt rounds

#### **6. Flujo de Autenticación en Cliente Flutter**

```dart
// 1. Login y guardar token
final response = await apiService.login(email, password);
final token = response['token'];
await storage.write(key: 'token', value: token);

// 2. Configurar token en requests
apiService.setToken(token);

// 3. Incluir en headers automáticamente
final headers = _getHeaders(requiresAuth: true);
// → { 'Authorization': 'Bearer <token>', 'Content-Type': 'application/json' }

// 4. Renovar token antes de expiración
if (tokenExpired) {
  await login(savedEmail, savedPassword);
}
```

---

## 📦 Tecnologías Utilizadas

- **Express.js** - Framework web
- **PostgreSQL** - Base de datos relacional
- **JWT** - JSON Web Tokens para autenticación
- **Bcrypt** - Hash de contraseñas
- **CORS** - Habilitado para Flutter
- **Body-parser** - Parsing de JSON
