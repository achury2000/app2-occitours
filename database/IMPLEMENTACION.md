# Guía de Implementación - Occitours API + Base de Datos

Esta guía te ayudará a configurar la base de datos y conectar tu app Flutter con un backend REST.

---

## 📋 Índice

1. [Configurar Base de Datos](#1-configurar-base-de-datos)
2. [Opciones de Backend](#2-opciones-de-backend)
3. [Conectar Flutter con API](#3-conectar-flutter-con-api)
4. [Modificar Providers](#4-modificar-providers)
5. [Testing](#5-testing)

---

## 1. Configurar Base de Datos

### Opción A: MySQL

#### 1.1 Instalar MySQL

**Windows:**
```powershell
# Descargar desde https://dev.mysql.com/downloads/installer/
# O con Chocolatey:
choco install mysql
```

**Linux/Mac:**
```bash
# Ubuntu/Debian
sudo apt-get install mysql-server

# macOS
brew install mysql
```

#### 1.2 Crear Base de Datos

```bash
# Conectar a MySQL
mysql -u root -p

# Crear base de datos
CREATE DATABASE occitours CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Crear usuario
CREATE USER 'occitours_user'@'localhost' IDENTIFIED BY 'tu_password_seguro';
GRANT ALL PRIVILEGES ON occitours.* TO 'occitours_user'@'localhost';
FLUSH PRIVILEGES;

# Salir
exit;
```

#### 1.3 Ejecutar Scripts SQL

```powershell
# Desde el directorio del proyecto
cd "c:\Users\luis1\Desktop\Quinto trimestre\app2-occitours"

# Ejecutar esquema
Get-Content .\database\01_schema.sql | mysql -u occitours_user -p occitours

# Ejecutar datos de prueba
Get-Content .\database\02_seeds.sql | mysql -u occitours_user -p occitours
```

### Opción B: PostgreSQL

#### 1.1 Instalar PostgreSQL

```powershell
# Windows con Chocolatey
choco install postgresql

# O descargar desde https://www.postgresql.org/download/
```

#### 1.2 Crear Base de Datos

```bash
# Conectar
psql -U postgres

# Crear base de datos
CREATE DATABASE occitours ENCODING 'UTF8';

# Crear usuario
CREATE USER occitours_user WITH PASSWORD 'tu_password_seguro';
GRANT ALL PRIVILEGES ON DATABASE occitours TO occitours_user;

# Salir
\q
```

#### 1.3 Ajustar Scripts SQL para PostgreSQL

**Cambios necesarios en `01_schema.sql`:**

```sql
-- Cambiar AUTO_INCREMENT por SERIAL
-- De:
id INT AUTO_INCREMENT PRIMARY KEY

-- A:
id SERIAL PRIMARY KEY

-- Cambiar ENUM por VARCHAR con CHECK
-- De:
estado ENUM('pendiente', 'confirmada') DEFAULT 'pendiente'

-- A:
estado VARCHAR(20) DEFAULT 'pendiente' 
CHECK (estado IN ('pendiente', 'confirmada', 'pagada', 'cancelada'))
```

---

## 2. Opciones de Backend

### Opción A: Node.js + Express (Recomendado para principiantes)

#### 2.1 Estructura del Proyecto

```
backend/
├── src/
│   ├── config/
│   │   └── database.js
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── usuariosController.js
│   │   ├── productosController.js
│   │   ├── serviciosController.js
│   │   └── reservasController.js
│   ├── middleware/
│   │   ├── auth.js
│   │   └── permissions.js
│   ├── models/
│   │   ├── Usuario.js
│   │   ├── Producto.js
│   │   └── ...
│   ├── routes/
│   │   ├── auth.js
│   │   ├── usuarios.js
│   │   ├── productos.js
│   │   └── ...
│   └── app.js
├── .env
├── package.json
└── server.js
```

#### 2.2 Inicializar Proyecto

```bash
mkdir backend
cd backend
npm init -y

# Instalar dependencias
npm install express mysql2 jsonwebtoken bcryptjs dotenv cors helmet express-validator
npm install nodemon --save-dev
```

#### 2.3 Archivo `.env`

```env
# Servidor
PORT=3000
NODE_ENV=development

# Base de datos
DB_HOST=localhost
DB_PORT=3306
DB_NAME=occitours
DB_USER=occitours_user
DB_PASSWORD=tu_password_seguro

# JWT
JWT_SECRET=tu_secreto_super_seguro_cambiar_en_produccion
JWT_EXPIRES_IN=1h
JWT_REFRESH_SECRET=otro_secreto_para_refresh_token
JWT_REFRESH_EXPIRES_IN=7d
```

#### 2.4 Configuración de Base de Datos (`src/config/database.js`)

```javascript
const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool;
```

#### 2.5 Middleware de Autenticación (`src/middleware/auth.js`)

```javascript
const jwt = require('jsonwebtoken');

const auth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ 
        success: false, 
        error: 'Acceso denegado. Token no proporcionado.' 
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = decoded;
    next();
  } catch (error) {
    res.status(401).json({ 
      success: false, 
      error: 'Token inválido o expirado' 
    });
  }
};

module.exports = auth;
```

#### 2.6 Controlador de Autenticación (`src/controllers/authController.js`)

```javascript
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Buscar usuario
    const [usuarios] = await db.query(
      `SELECT u.*, r.nombre as rol_nombre 
       FROM usuarios u 
       JOIN roles r ON u.rol_id = r.id 
       WHERE u.email = ? AND u.activo = TRUE`,
      [email]
    );

    if (usuarios.length === 0) {
      return res.status(401).json({ 
        success: false, 
        error: 'Credenciales inválidas' 
      });
    }

    const usuario = usuarios[0];

    // Verificar contraseña
    const validPassword = await bcrypt.compare(password, usuario.password_hash);
    if (!validPassword) {
      return res.status(401).json({ 
        success: false, 
        error: 'Credenciales inválidas' 
      });
    }

    // Obtener permisos
    const [permisos] = await db.query(
      `SELECT p.codigo 
       FROM permisos p 
       JOIN rol_permiso rp ON p.id = rp.permiso_id 
       WHERE rp.rol_id = ?`,
      [usuario.rol_id]
    );

    // Generar tokens
    const token = jwt.sign(
      { id: usuario.id, rol: usuario.rol_nombre },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    const refreshToken = jwt.sign(
      { id: usuario.id },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN }
    );

    // Guardar sesión
    await db.query(
      'INSERT INTO sesiones (usuario_id, token, refresh_token, expires_at) VALUES (?, ?, ?, DATE_ADD(NOW(), INTERVAL 1 HOUR))',
      [usuario.id, token, refreshToken]
    );

    // Actualizar último login
    await db.query(
      'UPDATE usuarios SET ultimo_login = NOW() WHERE id = ?',
      [usuario.id]
    );

    res.json({
      success: true,
      data: {
        token,
        refreshToken,
        expiresIn: 3600,
        user: {
          id: usuario.id,
          nombre: usuario.nombre,
          apellido: usuario.apellido,
          email: usuario.email,
          rol: usuario.rol_nombre,
          permisos: permisos.map(p => p.codigo)
        }
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ 
      success: false, 
      error: 'Error en el servidor' 
    });
  }
};

exports.register = async (req, res) => {
  try {
    const { nombre, apellido, cedula, email, password, telefono, fechaNacimiento } = req.body;

    // Verificar si ya existe
    const [existentes] = await db.query(
      'SELECT id FROM usuarios WHERE email = ? OR cedula = ?',
      [email, cedula]
    );

    if (existentes.length > 0) {
      return res.status(400).json({ 
        success: false, 
        error: 'El email o cédula ya están registrados' 
      });
    }

    // Hash de contraseña
    const passwordHash = await bcrypt.hash(password, 10);

    // Obtener rol de cliente
    const [roles] = await db.query('SELECT id FROM roles WHERE nombre = ?', ['cliente']);
    const rolId = roles[0].id;

    // Insertar usuario
    const [resultado] = await db.query(
      `INSERT INTO usuarios (nombre, apellido, cedula, email, password_hash, telefono, rol_id) 
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [nombre, apellido, cedula, email, passwordHash, telefono, rolId]
    );

    // Crear registro de cliente
    await db.query(
      'INSERT INTO clientes (usuario_id, fecha_nacimiento) VALUES (?, ?)',
      [resultado.insertId, fechaNacimiento || null]
    );

    res.status(201).json({
      success: true,
      data: {
        id: resultado.insertId,
        nombre,
        apellido,
        email,
        rol: 'cliente'
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ 
      success: false, 
      error: 'Error en el servidor' 
    });
  }
};
```

#### 2.7 Rutas (`src/routes/auth.js`)

```javascript
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/login', authController.login);
router.post('/register', authController.register);

module.exports = router;
```

#### 2.8 App Principal (`src/app.js`)

```javascript
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const authRoutes = require('./routes/auth');

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rutas
app.use('/api/v1/auth', authRoutes);

// Ruta de prueba
app.get('/api/v1/health', (req, res) => {
  res.json({ success: true, message: 'API funcionando correctamente' });
});

// Manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    success: false, 
    error: 'Algo salió mal en el servidor' 
  });
});

module.exports = app;
```

#### 2.9 Servidor (`server.js`)

```javascript
const app = require('./src/app');
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
  console.log(`Documentación: http://localhost:${PORT}/api/v1/health`);
});
```

#### 2.10 Scripts en `package.json`

```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "jest"
  }
}
```

#### 2.11 Ejecutar Backend

```bash
npm run dev
```

### Opción B: Laravel (PHP)

```bash
# Instalar Laravel
composer create-project laravel/laravel occitours-api

cd occitours-api

# Instalar dependencias adicionales
composer require laravel/sanctum

# Configurar .env
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=occitours
# DB_USERNAME=occitours_user
# DB_PASSWORD=tu_password_seguro

# Ejecutar migraciones (usar tus scripts SQL personalizados)
# php artisan migrate

# Iniciar servidor
php artisan serve
```

---

## 3. Conectar Flutter con API

### 3.1 Agregar Dependencias

En `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
```

Ejecutar:
```bash
flutter pub get
```

### 3.2 Configurar Base URL

Crear `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Cambiar según tu entorno
  static const String baseUrl = 'http://localhost:3000/api/v1';
  
  // Para Android Emulator usar: http://10.0.2.2:3000/api/v1
  // Para dispositivo físico: http://TU_IP_LOCAL:3000/api/v1
  
  static const Duration timeoutDuration = Duration(seconds: 30);
}
```

### 3.3 Crear Servicio de API (`lib/services/api_service.dart`)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<Map<String, dynamic>> get(String endpoint, {bool includeAuth = true}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await http.get(url, headers: headers).timeout(ApiConfig.timeoutDuration);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body, {bool includeAuth = true}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      ).timeout(ApiConfig.timeoutDuration);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      ).timeout(ApiConfig.timeoutDuration);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.delete(url, headers: headers).timeout(ApiConfig.timeoutDuration);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['error'] ?? 'Error desconocido');
    }
  }
}
```

---

## 4. Modificar Providers

### 4.1 Actualizar AuthProvider (`lib/providers/auth_provider.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/auth/login',
        {'email': email, 'password': password},
        includeAuth: false,
      );

      if (response['success'] == true) {
        final data = response['data'];
        _token = data['token'];
        
        // Guardar token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('refresh_token', data['refreshToken']);
        
        // Crear usuario
        final userData = data['user'];
        _currentUser = User(
          id: userData['id'].toString(),
          name: '${userData['nombre']} ${userData['apellido']}',
          email: userData['email'],
          role: userData['rol'],
        );
        
        await prefs.setString('user_role', _currentUser!.role);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register({
    required String nombre,
    required String apellido,
    required String cedula,
    required String email,
    required String password,
    String? telefono,
    String? fechaNacimiento,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.post(
        '/auth/register',
        {
          'nombre': nombre,
          'apellido': apellido,
          'cedula': cedula,
          'email': email,
          'password': password,
          'telefono': telefono,
          'fechaNacimiento': fechaNacimiento,
        },
        includeAuth: false,
      );
      
      // Después de registrarse, hacer login automáticamente
      await login(email, password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', {});
    } catch (e) {
      // Ignorar errores en logout
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_role');
    
    _currentUser = null;
    _token = null;
    notifyListeners();
  }

  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      _token = token;
      // Obtener datos del usuario desde el backend
      try {
        final response = await ApiService.get('/usuarios/me');
        if (response['success'] == true) {
          final userData = response['data'];
          _currentUser = User(
            id: userData['id'].toString(),
            name: '${userData['nombre']} ${userData['apellido']}',
            email: userData['email'],
            role: userData['rol']['nombre'],
          );
          notifyListeners();
        }
      } catch (e) {
        // Token inválido, limpiar
        await logout();
      }
    }
  }
}
```

### 4.2 Actualizar ProductsProvider

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/productos');
      
      if (response['success'] == true) {
        _products = (response['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error al cargar productos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await ApiService.post('/productos', product.toJson());
      
      if (response['success'] == true) {
        await fetchProducts(); // Recargar lista
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

---

## 5. Testing

### 5.1 Probar Backend

```bash
# Probar health check
curl http://localhost:3000/api/v1/health

# Probar login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@occitours.com","password":"123456"}'

# Probar endpoint protegido
curl http://localhost:3000/api/v1/productos \
  -H "Authorization: Bearer TU_TOKEN_AQUI"
```

### 5.2 Probar desde Flutter

Ejecutar la app y verificar que:
- El login funciona correctamente
- Los productos se cargan desde la API
- Las reservas se crean en la base de datos

---

## 🚀 Próximos Pasos

1. ✅ Base de datos configurada
2. ✅ Backend funcionando
3. ✅ Flutter conectado a API
4. ⬜ Implementar todos los endpoints
5. ⬜ Agregar validaciones y manejo de errores
6. ⬜ Deploy (considerar Heroku, DigitalOcean, AWS, etc.)

---

## 🔧 Troubleshooting

### Error: Cannot connect to MySQL
- Verificar que MySQL esté corriendo: `mysql -u root -p`
- Verificar credenciales en `.env`

### Error: CORS en Flutter Web
- Agregar configuración CORS en backend
- En Express: `app.use(cors())`

### Error: Connection refused desde Android Emulator
- Usar `http://10.0.2.2:3000` en lugar de `localhost`

### Error: Network unreachable desde dispositivo físico
- Usar IP local de tu máquina (ej: `http://192.168.1.100:3000`)
- Asegurarte que el firewall permita conexiones en el puerto 3000
