# Prueba de Integración Flutter + Backend

## ✅ Configuración Completada

### Backend (Node.js + Express + PostgreSQL)
- **URL:** http://localhost:3000
- **Base de datos:** PostgreSQL (Occi's)
- **JWT expira en:** 5 minutos

### Flutter
- **Servicio API:** lib/services/api_service.dart
- **Provider:** lib/providers/auth_provider.dart
- **Pantalla Login:** lib/screens/login_screen.dart

---

## 🧪 Cuentas de Prueba

| Rol | Email | Contraseña |
|-----|-------|-----------|
| Admin | admin@occitours.com | 123456 |
| Asesor | asesor@occitours.com | 123456 |
| Cliente | cliente@demo.com | 123456 |
| Guía | guia@occitours.com | 123456 |

---

## 📝 Cómo Probar

### 1. Verificar que el backend esté corriendo
```bash
curl http://localhost:3000
```
Debe responder: `{"message":"🚀 API Occitours funcionando"}`

### 2. Probar login desde Flutter
1. Abrir la app en Chrome
2. Click en cualquier chip de cuenta demo
3. Click en "Iniciar Sesión"
4. Debe redirigir según el rol:
   - Admin → `/admin`
   - Asesor → `/advisor`
   - Cliente → página principal `/`

### 3. Verificar token JWT
- El token se guarda en `SharedPreferences`
- Expira en 5 minutos de inactividad
- Al expirar, se debe mostrar error y pedir nuevo login

---

## 🔍 Debugging

### Backend logs
Revisa la terminal del servidor Node.js para ver:
- Conexiones a PostgreSQL
- Peticiones HTTP recibidas
- Errores de autenticación

### Flutter logs
En la terminal de Flutter verás:
- Errores de conexión
- Respuestas del API
- Estados del provider

---

## ⚠️ Importante

**Para emulador Android:** Cambia en `api_service.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

**Para dispositivo físico:** Usa la IP de tu computadora:
```dart
static const String baseUrl = 'http://192.168.x.x:3000/api';
```

---

## ✅ Siguiente Paso

Una vez validado el login, continuar con:
1. Endpoints de Fincas (GET listar, GET detalle)
2. Endpoints de Rutas (GET listar, GET detalle)
3. Endpoints de Reservas (POST crear, GET mis reservas)
4. Endpoints de Dashboard (GET métricas)
