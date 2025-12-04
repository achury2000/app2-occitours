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

## 📦 Próximos endpoints

- `/api/fincas` - Gestión de fincas
- `/api/rutas` - Gestión de rutas
- `/api/reservas` - Gestión de reservas
- `/api/dashboard` - Métricas y reportes
