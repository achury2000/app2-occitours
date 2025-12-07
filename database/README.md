# 🗄️ Base de Datos - Occitours

Esta carpeta contiene todo lo necesario para implementar la base de datos y API REST del proyecto Occitours.

---

## 📁 Contenido

```
database/
├── 01_schema.sql          # Esquema completo de la base de datos (tablas, índices, relaciones)
├── 02_seeds.sql           # Datos iniciales de prueba
├── API_ENDPOINTS.md       # Documentación completa de endpoints REST
├── IMPLEMENTACION.md      # Guía paso a paso de implementación
└── README.md              # Este archivo
```

---

## 🚀 Inicio Rápido

### 1. Crear Base de Datos

```bash
# MySQL
mysql -u root -p
CREATE DATABASE occitours CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'occitours_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON occitours.* TO 'occitours_user'@'localhost';
FLUSH PRIVILEGES;
exit;
```

### 2. Ejecutar Scripts

```powershell
# Desde la raíz del proyecto
cd "c:\Users\luis1\Desktop\Quinto trimestre\app2-occitours"

# Esquema
Get-Content .\database\01_schema.sql | mysql -u occitours_user -p occitours

# Datos de prueba
Get-Content .\database\02_seeds.sql | mysql -u occitours_user -p occitours
```

### 3. Verificar

```bash
mysql -u occitours_user -p occitours
SHOW TABLES;
SELECT * FROM usuarios;
```

---

## 📊 Estructura de la Base de Datos

### Módulos Principales

#### 1. **Autenticación y Usuarios**
- `roles` - Roles del sistema (admin, cliente, empleado, etc.)
- `permisos` - Permisos granulares
- `rol_permiso` - Relación roles-permisos
- `usuarios` - Datos básicos de usuarios
- `sesiones` - Tokens JWT y sesiones activas
- `clientes` - Información extendida de clientes
- `empleados` - Información extendida de empleados

#### 2. **Catálogo**
- `categorias` - Categorías de servicios turísticos
- `servicios` - Servicios turísticos ofrecidos
- `fincas` - Fincas disponibles para reservas
- `finca_servicios` - Servicios disponibles por finca
- `rutas` - Rutas turísticas
- `ruta_puntos` - Puntos de interés en cada ruta

#### 3. **Operaciones**
- `programaciones` - Itinerarios programados
- `programacion_rutas` - Rutas asignadas a programaciones
- `programacion_servicios` - Servicios incluidos en programaciones
- `reservas` - Reservas de clientes
- `reserva_servicios` - Servicios incluidos en cada reserva

#### 4. **Ventas y Pagos**
- `ventas` - Cabecera de órdenes de venta
- `abonos` - Pagos parciales o totales
- `pagos_proveedores` - Pagos a proveedores externos

#### 5. **Proveedores**
- `proveedores` - Proveedores de servicios
- `tipos_proveedores` - Tipos de proveedor

#### 6. **Dashboard**
- `dashboard_metricas` - Métricas precalculadas de reservas para visualización

**Nota:** El dashboard almacena métricas agregadas (totales diarios, ocupación, servicios más reservados, etc.) que se calculan periódicamente desde las reservas para optimizar la visualización y análisis de datos.

---

## 🔐 Datos de Prueba (Seeds)

### Usuarios Iniciales

| Email | Password | Rol | Cédula |
|-------|----------|-----|--------|
| admin@occitours.com | 123456 | admin | 1234567890 |
| asesor@occitours.com | 123456 | asesor | 1234567891 |
| cliente@demo.com | 123456 | cliente | 1234567892 |
| guia@occitours.com | 123456 | guia | 1234567893 |
| cliente2@demo.com | 123456 | cliente | 1234567894 |

**Nota:** Las contraseñas están hasheadas con bcrypt. El hash para "123456" es:
```
$2a$10$N9qo8uLOickgx2ZMRZoMye3jJc1W0f.KqRoJt3VUH7T6pYL6zQ9rC
```

### Datos de Ejemplo

- ✅ 5 usuarios (admin, asesor, 2 clientes, guía)
- ✅ 7 categorías de servicios (Alojamiento, Alimentación, etc.)
- ✅ 13 servicios (3 de alojamiento, 4 de alimentación, 6 adicionales)
- ✅ 3 fincas con ubicación GPS
- ✅ 3 rutas turísticas con puntos de interés
- ✅ 3 programaciones futuras con servicios incluidos
- ✅ 2 reservas confirmadas con alojamiento y alimentación
- ✅ 2 ventas pagadas
- ✅ 10 métricas del dashboard (nov-dic 2025)

---

## 🔗 Relaciones Importantes

```
usuarios
  ├─ clientes (1:1)
  ├─ empleados (1:1)
  └─ sesiones (1:N)

reservas
  ├─ cliente (N:1)
  ├─ venta (N:1)
  ├─ programacion (N:1)
  ├─ finca (N:1)
  └─ reserva_servicios (1:N)

ventas
  ├─ cliente (N:1)
  ├─ asesor (N:1)
  └─ abonos (1:N)
```

---

## 📖 Documentación Adicional

### API_ENDPOINTS.md
Documentación completa de todos los endpoints REST necesarios:
- Autenticación (login, register, logout)
- CRUD de Usuarios
- CRUD de Servicios
- Gestión de Reservas
- Ventas y Abonos
- Dashboard con métricas precalculadas

### IMPLEMENTACION.md
Guía detallada paso a paso:
1. Configuración de MySQL/PostgreSQL
2. Implementación de backend (Node.js/Express o Laravel)
3. Conexión desde Flutter
4. Ejemplos de código completos
5. Troubleshooting

---

## 🔧 Comandos Útiles

### MySQL

```bash
# Conectar
mysql -u occitours_user -p occitours

# Ver todas las tablas
SHOW TABLES;

# Verificar usuarios
SELECT id, nombre, email, rol_id FROM usuarios;

# Verificar servicios
SELECT id, codigo, nombre, precio_base FROM servicios;

# Verificar reservas
SELECT r.numero_reserva, c.nombre, f.nombre as finca, r.estado 
FROM reservas r 
JOIN clientes cl ON r.cliente_id = cl.id 
JOIN usuarios c ON cl.usuario_id = c.id 
JOIN fincas f ON r.finca_id = f.id;

# Backup
mysqldump -u occitours_user -p occitours > backup_$(date +%Y%m%d).sql

# Restaurar
mysql -u occitours_user -p occitours < backup_20251202.sql

# Eliminar todo (CUIDADO!)
DROP DATABASE occitours;
```

---

## 🎯 Próximos Pasos

1. ✅ Ejecutar scripts SQL
2. ⬜ Implementar backend (ver IMPLEMENTACION.md)
3. ⬜ Conectar Flutter con API
4. ⬜ Implementar endpoints principales
5. ⬜ Testing de integración
6. ⬜ Deploy a producción

---

## ⚠️ Notas Importantes

### Seguridad

- **NUNCA** subir `.env` con credenciales reales a Git
- Cambiar `JWT_SECRET` en producción
- Usar contraseñas seguras (mínimo 12 caracteres)
- Habilitar SSL/TLS en producción
- Implementar rate limiting en endpoints públicos

### Rendimiento

- Todos los índices importantes están creados
- Considerar paginación para listas grandes
- Usar caché (Redis) para datos frecuentes
- Optimizar queries con `EXPLAIN`

### Escalabilidad

- El diseño soporta múltiples roles y permisos
- Las métricas se pueden precalcular
- JSON fields permiten datos flexibles
- Separación clara entre módulos

---

## 📞 Soporte

Para dudas sobre:
- **Esquema:** revisar comentarios en `01_schema.sql`
- **Endpoints:** consultar `API_ENDPOINTS.md`
- **Implementación:** seguir `IMPLEMENTACION.md`

---

## 📝 Changelog

### v1.0 - 2025-12-02
- ✅ Esquema completo con 30+ tablas
- ✅ Seeds con datos de prueba realistas
- ✅ Documentación de API REST
- ✅ Guía de implementación completa
- ✅ Compatible con MySQL y PostgreSQL

---

**Proyecto:** Occitours  
**Autor:** Luis Achury  
**Fecha:** Diciembre 2025
