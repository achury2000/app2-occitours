# API REST - Occitours
## Documentación de Endpoints

### URL Base
```
http://localhost:3000/api/v1
```

---

## 🔐 AUTENTICACIÓN

### POST /auth/login
Inicio de sesión con email y contraseña.

**Request Body:**
```json
{
  "email": "admin@occitours.com",
  "password": "123456"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600,
    "user": {
      "id": 1,
      "nombre": "Yeison",
      "apellido": "Uribe",
      "email": "admin@occitours.com",
      "rol": "admin",
      "permisos": ["usuarios.gestionar", "productos.gestionar", ...]
    }
  }
}
```

**Response 401 (credenciales incorrectas):**
```json
{
  "success": false,
  "error": "Credenciales inválidas"
}
```

---

### POST /auth/register
Registro de nuevo cliente.

**Request Body:**
```json
{
  "nombre": "Juan",
  "apellido": "Pérez",
  "cedula": "1234567895",
  "email": "juan@example.com",
  "password": "password123",
  "telefono": "3001234567",
  "fechaNacimiento": "1995-03-20"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": 6,
    "nombre": "Juan",
    "apellido": "Pérez",
    "email": "juan@example.com",
    "rol": "cliente"
  }
}
```

---

### POST /auth/refresh-token
Refrescar token de autenticación.

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

---

### POST /auth/logout
Cerrar sesión (invalida token actual).

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "message": "Sesión cerrada exitosamente"
}
```

---

## 👥 USUARIOS

### GET /usuarios
Obtener lista de usuarios (solo admin).

**Headers:**
```
Authorization: Bearer <token>
```

**Query Params:**
- `rol` (opcional): filtrar por rol (admin, cliente, empleado, etc.)
- `activo` (opcional): true/false
- `page` (opcional): número de página (default: 1)
- `limit` (opcional): resultados por página (default: 20)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nombre": "Yeison",
      "apellido": "Uribe",
      "cedula": "1234567890",
      "email": "admin@occitours.com",
      "telefono": "3100000000",
      "rol": "admin",
      "activo": true,
      "fechaRegistro": "2023-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "totalPages": 1
  }
}
```

---

### GET /usuarios/:id
Obtener usuario por ID.

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "nombre": "Yeison",
    "apellido": "Uribe",
    "cedula": "1234567890",
    "email": "admin@occitours.com",
    "telefono": "3100000000",
    "direccion": "Calle 12B #12-103",
    "rol": {
      "id": 1,
      "nombre": "admin",
      "permisos": ["usuarios.gestionar", "productos.gestionar", ...]
    },
    "activo": true,
    "fechaRegistro": "2023-01-01T00:00:00Z",
    "ultimoLogin": "2025-12-01T10:30:00Z"
  }
}
```

---

### POST /usuarios
Crear nuevo usuario (solo admin).

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "nombre": "Pedro",
  "apellido": "Gomez",
  "cedula": "9876543210",
  "email": "pedro@occitours.com",
  "password": "password123",
  "telefono": "3109876543",
  "direccion": "Carrera 10 #5-25",
  "rolId": 3
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": 7,
    "nombre": "Pedro",
    "apellido": "Gomez",
    "email": "pedro@occitours.com",
    "rol": "empleado"
  }
}
```

---

### PUT /usuarios/:id
Actualizar usuario.

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "nombre": "Pedro José",
  "telefono": "3109876544",
  "direccion": "Nueva dirección"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 7,
    "nombre": "Pedro José",
    "email": "pedro@occitours.com"
  }
}
```

---

### DELETE /usuarios/:id
Eliminar/desactivar usuario (solo admin).

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "message": "Usuario desactivado exitosamente"
}
```

---

## 🎯 SERVICIOS

### GET /servicios
Obtener catálogo de servicios.

**Query Params:**
- `categoria`, `buscar`, `ordenar`, `page`, `limit`

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "codigo": "SRV001",
      "nombre": "Parapente",
      "descripcion": "Vuelo en parapente con instructor certificado",
      "duracionMinutos": 60,
      "capacidadMaxima": 2,
      "precioBase": 150000,
      "imagenUrl": "https://...",
      "categoria": {
        "id": 1,
        "nombre": "Deportes Extremos"
      },
      "destacado": true,
      "popularidad": 95,
      "activo": true
    }
  ],
  "pagination": {...}
}
```

---

### GET /servicios/:id
Obtener detalle de un servicio.

### POST /servicios
Crear nuevo servicio (solo admin).

### PUT /servicios/:id
Actualizar servicio (solo admin).

### DELETE /servicios/:id
Eliminar/desactivar servicio (solo admin).

---

## 🏡 FINCAS

### GET /fincas
Obtener lista de fincas disponibles.

**Query Params:**
- `ciudad`, `disponible`, `fechaInicio`, `fechaFin`

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "codigo": "FNC001",
      "nombre": "Finca La Esperanza",
      "descripcion": "Finca con vista panorámica...",
      "direccion": "Vereda El Poblado km 5",
      "ciudad": "Rionegro",
      "departamento": "Antioquia",
      "capacidadTotal": 50,
      "precioPorPersona": 80000,
      "imagenUrl": "https://...",
      "ubicacion": {
        "latitud": 6.1545,
        "longitud": -75.3747
      },
      "serviciosDisponibles": [
        {
          "id": 2,
          "nombre": "Cabalgata",
          "precio": 75000
        }
      ],
      "activo": true
    }
  ]
}
```

---

### GET /fincas/:id
Obtener detalle completo de una finca.

### POST /fincas
Crear nueva finca (solo admin).

### PUT /fincas/:id
Actualizar finca (solo admin).

### DELETE /fincas/:id
Eliminar/desactivar finca (solo admin).

---

## 🗺️ RUTAS

### GET /rutas
Obtener lista de rutas turísticas.

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "codigo": "RUT001",
      "nombre": "Ruta del Café",
      "descripcion": "Recorrido por fincas cafeteras...",
      "duracionHoras": 6,
      "distanciaKm": 25,
      "dificultad": "facil",
      "precio": 150000,
      "puntos": [
        {
          "id": 1,
          "nombre": "Finca Don Pedro",
          "descripcion": "Visita al cafetal tradicional",
          "orden": 1,
          "ubicacion": {
            "latitud": 6.1545,
            "longitud": -75.3747
          }
        }
      ],
      "activo": true
    }
  ]
}
```

---

### GET /rutas/:id
Obtener detalle de una ruta.

### POST /rutas
Crear nueva ruta (solo admin).

### PUT /rutas/:id
Actualizar ruta (solo admin).

### DELETE /rutas/:id
Eliminar ruta (solo admin).

---

## 📅 PROGRAMACIONES

### GET /programaciones
Obtener programaciones disponibles.

**Query Params:**
- `fechaInicio`, `fechaFin`, `guiaId`, `estado`

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "titulo": "Tour Café Matutino",
      "fecha": "2025-12-10",
      "horaInicio": "08:00:00",
      "horaFin": "11:30:00",
      "guia": {
        "id": 1,
        "nombre": "Carlos Mendez"
      },
      "capacidadDisponible": 15,
      "estado": "programada",
      "servicios": [
        {
          "id": 4,
          "nombre": "Tour Café",
          "horaInicio": "08:30:00"
        }
      ],
      "rutas": [
        {
          "id": 1,
          "nombre": "Ruta del Café",
          "orden": 1
        }
      ]
    }
  ]
}
```

---

### GET /programaciones/:id
Obtener detalle de una programación.

### POST /programaciones
Crear nueva programación (admin/empleado).

**Request Body:**
```json
{
  "titulo": "Aventura Nocturna",
  "fecha": "2025-12-20",
  "horaInicio": "18:00:00",
  "horaFin": "22:00:00",
  "guiaId": 1,
  "capacidadDisponible": 10,
  "serviciosIds": [3, 6],
  "rutasIds": [3]
}
```

### PUT /programaciones/:id
Actualizar programación.

### DELETE /programaciones/:id
Cancelar programación.

---

## 🎫 RESERVAS

### GET /reservas
Obtener reservas del usuario autenticado (cliente ve solo las suyas, admin/empleado ve todas).

**Headers:**
```
Authorization: Bearer <token>
```

**Query Params:**
- `estado`, `fechaInicio`, `fechaFin`, `clienteId` (solo admin)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "numeroReserva": "RSV-2025-001",
      "fecha": "2025-12-10",
      "fechaIngreso": "2025-12-10",
      "fechaSalida": "2025-12-10",
      "numeroPersonas": 4,
      "precioTotal": 200000,
      "estado": "confirmada",
      "cliente": {
        "id": 1,
        "nombre": "Maria Lopez",
        "telefono": "3001112222"
      },
      "finca": {
        "id": 1,
        "nombre": "Finca La Esperanza"
      },
      "programacion": {
        "id": 1,
        "titulo": "Tour Café Matutino"
      },
      "servicios": [
        {
          "id": 4,
          "nombre": "Tour Café",
          "cantidad": 4,
          "precioUnitario": 55000,
          "subtotal": 220000
        }
      ]
    }
  ]
}
```

---

### GET /reservas/:id
Obtener detalle de una reserva específica.

---

### POST /reservas
Crear nueva reserva.

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "programacionId": 2,
  "fincaId": 2,
  "fechaIngreso": "2025-12-14",
  "fechaSalida": "2025-12-14",
  "numeroPersonas": 2,
  "servicios": [
    {
      "servicioId": 1,
      "cantidad": 2
    },
    {
      "servicioId": 5,
      "cantidad": 2
    }
  ],
  "observaciones": "Cliente con movilidad reducida"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": 3,
    "numeroReserva": "RSV-2025-003",
    "precioTotal": 540000,
    "estado": "pendiente",
    "detalles": {
      "programacion": {...},
      "finca": {...},
      "servicios": [...]
    }
  }
}
```

---

### PUT /reservas/:id
Actualizar reserva (cambiar fecha, cantidad de personas, etc.).

---

### PUT /reservas/:id/cancelar
Cancelar una reserva.

**Response 200:**
```json
{
  "success": true,
  "message": "Reserva cancelada exitosamente",
  "data": {
    "id": 3,
    "estado": "cancelada"
  }
}
```

---

## 💰 VENTAS

### GET /ventas
Obtener registro de ventas (admin/asesor).

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "numeroVenta": "VTA-2025-001",
      "fecha": "2025-11-25T10:30:00Z",
      "cliente": {
        "id": 1,
        "nombre": "Maria Lopez"
      },
      "asesor": {
        "id": 2,
        "nombre": "Jose Ramirez"
      },
      "subtotal": 220000,
      "impuestos": 0,
      "descuentos": 0,
      "total": 220000,
      "estado": "pagada",
      "metodoPago": "tarjeta"
    }
  ],
  "pagination": {...}
}
```

---

### GET /ventas/:id
Obtener detalle de una venta con servicios contratados y abonos.

---

### POST /ventas
Crear nueva venta (checkout de reserva).

**Request Body:**
```json
{
  "clienteId": 3,
  "reservaId": 3,
  "descuentos": 0,
  "metodoPago": "tarjeta",
  "notas": "Pago completo de servicios turísticos"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": 3,
    "numeroVenta": "VTA-2025-003",
    "total": 540000,
    "estado": "pendiente"
  }
}
```

---

### POST /ventas/:id/abonar
Registrar un abono/pago para una venta.

**Request Body:**
```json
{
  "monto": 100000,
  "metodoPago": "efectivo",
  "referencia": "EFEC-002"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "abonoId": 3,
    "ventaId": 3,
    "montoAbonado": 100000,
    "saldoPendiente": 270000,
    "estadoVenta": "parcial"
  }
}
```

---

## 📊 DASHBOARD (Solo Admin)

**Nota:** El dashboard almacena métricas precalculadas en la tabla `dashboard_metricas` para visualización rápida. 
Las métricas se actualizan periódicamente desde las reservas mediante procesos automatizados.

### GET /dashboard/resumen
Obtener resumen general del dashboard.

**Headers:**
```
Authorization: Bearer <token>
```

**Query Params:**
- `fechaInicio`, `fechaFin`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "totalReservas": 145,
    "reservasActivas": 28,
    "reservasPendientes": 12,
    "reservasConfirmadas": 85,
    "reservasCompletadas": 20,
    "ingresosTotales": 45000000,
    "ingresosMensuales": 15420000,
    "clientesActivos": 67,
    "serviciosMasReservados": [
      {
        "id": 1,
        "nombre": "Alojamiento Habitación Estándar",
        "cantidad": 52,
        "ingresos": 6240000
      },
      {
        "id": 4,
        "nombre": "Desayuno",
        "cantidad": 145,
        "ingresos": 3625000
      },
      {
        "id": 11,
        "nombre": "Tour Café",
        "cantidad": 45,
        "ingresos": 2700000
      }
    ],
    "ocupacionFincas": [
      {
        "fincaId": 1,
        "nombre": "Finca La Esperanza",
        "reservas": 42,
        "ocupacion": 75,
        "ingresos": 8400000
      },
      {
        "fincaId": 2,
        "nombre": "Villa Naturaleza",
        "reservas": 28,
        "ocupacion": 65,
        "ingresos": 5600000
      }
    ],
    "reservasPorMes": [
      {"mes": "2025-11", "cantidad": 38, "ingresos": 9500000},
      {"mes": "2025-12", "cantidad": 52, "ingresos": 13000000}
    ]
  }
}
```

---

### GET /dashboard/reservas-por-periodo
Obtener estadísticas de reservas agrupadas por período.

**Query Params:**
- `periodo`: dia, semana, mes, año
- `fechaInicio`, `fechaFin`

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "periodo": "2025-11",
      "reservas": 45,
      "ingresos": 11500000,
      "ocupacionPromedio": 68.5
    },
    {
      "periodo": "2025-12",
      "reservas": 52,
      "ingresos": 13000000,
      "ocupacionPromedio": 72.3
    }
  ]
}
```

---

### GET /dashboard/reservas-por-estado
Obtener distribución de reservas por estado.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "pendiente": 12,
    "confirmada": 85,
    "pagada": 28,
    "completada": 20,
    "cancelada": 5
  }
}
```

---

### POST /dashboard/actualizar-metricas
Actualizar métricas del dashboard desde las reservas (proceso automático o manual).

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "fecha": "2025-12-02",
  "forzarRecalculo": true
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Métricas actualizadas exitosamente",
  "data": {
    "metricasActualizadas": 8,
    "fechaProcesada": "2025-12-02"
  }
}
```

---

### GET /dashboard/ingresos-por-servicio
Obtener ingresos desglosados por tipo de servicio.

---

### GET /dashboard/ocupacion-fincas
Obtener porcentaje de ocupación de cada finca por período.

---

## 🔍 BÚSQUEDA GLOBAL

### GET /buscar
Búsqueda global en productos, servicios, fincas y rutas.

**Query Params:**
- `q`: término de búsqueda

**Response 200:**
```json
{
  "success": true,
  "data": {
    "servicios": [...],
    "fincas": [...],
    "rutas": [...]
  }
}
```

---

## ⚙️ CÓDIGOS DE ESTADO HTTP

- **200 OK**: Petición exitosa
- **201 Created**: Recurso creado exitosamente
- **400 Bad Request**: Datos inválidos
- **401 Unauthorized**: No autenticado
- **403 Forbidden**: No autorizado (falta permiso)
- **404 Not Found**: Recurso no encontrado
- **422 Unprocessable Entity**: Validación fallida
- **500 Internal Server Error**: Error del servidor

---

## 🔒 PERMISOS POR ROL

| Endpoint | Admin | Asesor | Cliente |
|----------|-------|--------|---------|
| GET /usuarios | ✅ | ❌ | ❌ |
| POST /usuarios | ✅ | ❌ | ❌ |
| GET /servicios | ✅ | ✅ | ✅ |
| POST /servicios | ✅ | ❌ | ❌ |
| GET /reservas | ✅ (todas) | ✅ (todas) | ✅ (propias) |
| POST /reservas | ✅ | ✅ | ✅ |
| GET /ventas | ✅ | ✅ | ❌ |
| POST /ventas | ✅ | ✅ | ❌ |
| GET /dashboard/* | ✅ | ❌ | ❌ |

---

## 📦 FORMATO DE RESPUESTA ESTÁNDAR

Todas las respuestas siguen este formato:

**Éxito:**
```json
{
  "success": true,
  "data": { ... },
  "message": "Mensaje opcional"
}
```

**Error:**
```json
{
  "success": false,
  "error": "Descripción del error",
  "details": { ... }
}
```

---

## 🚀 PRÓXIMOS PASOS

1. Implementar backend con Node.js/Express o Laravel
2. Configurar JWT para autenticación
3. Implementar middleware de permisos
4. Crear tests de integración
5. Documentar con Swagger/OpenAPI
