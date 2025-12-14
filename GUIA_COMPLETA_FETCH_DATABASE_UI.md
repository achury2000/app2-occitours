# 🔄 GUÍA COMPLETA: FETCH DE BASE DE DATOS → UI CON DISEÑO

## Sistema Occitours - Flujo Completo Backend → Frontend

---

## 📚 ÍNDICE

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Casos de Uso del Proyecto](#casos-de-uso-del-proyecto)
3. [Flujo Detallado por Módulo](#flujo-detallado-por-módulo)
   - [Usuarios](#1-usuarios)
   - [Fincas](#2-fincas)
   - [Reservas](#3-reservas)
   - [Ventas](#4-ventas)
   - [Servicios](#5-servicios)
4. [Patrones de Diseño Comunes](#patrones-de-diseño-comunes)
5. [Componentes Visuales](#componentes-visuales)

---

## RESUMEN EJECUTIVO

El proyecto Occitours sigue un patrón arquitectónico de **4 capas** para mostrar datos de la base de datos en la UI:

```
┌─────────────────────────────────────────────────────────┐
│ 1. BASE DE DATOS (PostgreSQL)                          │
│    - Tablas: usuarios, fincas, reservas, etc.          │
│    - Relaciones con FOREIGN KEYS                        │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ↓ SQL Query
┌─────────────────────────────────────────────────────────┐
│ 2. BACKEND (Node.js + Express)                         │
│    - Routes: GET /usuarios, /fincas, /reservas         │
│    - JSON Response con datos                            │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ↓ HTTP GET (fetch)
┌─────────────────────────────────────────────────────────┐
│ 3. API SERVICE (Flutter)                                │
│    - Métodos: getUsuarios(), getFincas()                │
│    - Parseo JSON → List<dynamic>                        │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ↓ setState() / Provider
┌─────────────────────────────────────────────────────────┐
│ 4. SCREEN (Flutter UI)                                  │
│    - ListView.builder con Cards                         │
│    - Diseño Material Design                             │
│    - Filtros, búsqueda, acciones                        │
└─────────────────────────────────────────────────────────┘
```

---

## CASOS DE USO DEL PROYECTO

### ✅ **Casos Implementados con Fetch Completo:**

| Módulo | Backend Route | ApiService | Screen | Diseño UI |
|--------|---------------|------------|--------|-----------|
| **Usuarios** | `GET /usuarios` | `getUsuarios()` | `users_list_screen.dart` | ✅ Cards con avatar |
| **Fincas** | `GET /fincas` | `getFincas()` | `fincas_screen.dart` | ✅ Cards con imagen |
| **Reservas** | `GET /reservas` | `getReservas()` | `reservations_list_screen.dart` | ✅ Cards detallados |
| **Ventas** | `GET /ventas` | `getVentas()` | `ventas_list_screen.dart` | ✅ Cards con total |
| **Servicios** | `GET /servicios` | `getServicios()` | `services_list_screen.dart` | ✅ ListTiles |
| **Clientes** | `GET /clientes` | `getClientes()` | `clients_list_screen.dart` | ✅ Cards con info |
| **Rutas** | `GET /rutas` | `getRutas()` | `routes_screen.dart` | ✅ Cards con mapa |
| **Proveedores** | `GET /proveedores` | `getProveedores()` | `suppliers_list_screen.dart` | ✅ Cards simples |

---

---

## FLUJO DETALLADO POR MÓDULO

---

## 1. USUARIOS

### 📦 PASO 1: BASE DE DATOS

**Archivo**: `database/01_schema.sql`  
**Líneas**: 50-65

```sql
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  rol VARCHAR(20) DEFAULT 'cliente',
  telefono VARCHAR(20),
  cedula VARCHAR(20),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Datos de ejemplo
INSERT INTO usuarios (nombre, apellido, email, password_hash, rol) VALUES
('Luis', 'Pérez', 'luis@email.com', '$2b$10$...', 'admin'),
('Ana', 'García', 'ana@email.com', '$2b$10$...', 'cliente');
```

---

### 💾 PASO 2: BACKEND - ENDPOINT

**Archivo**: `backend/routes/users.js`  
**Líneas**: 20-50

```javascript
const express = require('express');
const router = express.Router();
const db = require('../config/database');

/**
 * GET /api/usuarios - Obtener todos los usuarios
 * 
 * RESPONSE:
 * {
 *   usuarios: [
 *     {
 *       id: 1,
 *       nombre: "Luis",
 *       apellido: "Pérez",
 *       email: "luis@email.com",
 *       rol: "admin",
 *       telefono: "3001234567",
 *       cedula: "1234567890",
 *       created_at: "2025-12-09T10:00:00Z"
 *     }
 *   ],
 *   total: 15
 * }
 */
router.get('/', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        id, 
        nombre, 
        apellido, 
        email, 
        rol, 
        telefono, 
        cedula,
        created_at,
        updated_at
      FROM usuarios
      ORDER BY created_at DESC
    `);

    res.json({
      usuarios: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error al obtener usuarios:', error);
    res.status(500).json({ 
      error: 'Error del servidor',
      message: error.message 
    });
  }
});

module.exports = router;
```

**Respuesta JSON Ejemplo:**
```json
{
  "usuarios": [
    {
      "id": 1,
      "nombre": "Luis",
      "apellido": "Pérez",
      "email": "luis@email.com",
      "rol": "admin",
      "telefono": "3001234567",
      "cedula": "1234567890",
      "created_at": "2025-12-09T10:00:00.000Z",
      "updated_at": "2025-12-09T10:00:00.000Z"
    },
    {
      "id": 2,
      "nombre": "Ana",
      "apellido": "García",
      "email": "ana@email.com",
      "rol": "cliente",
      "telefono": "3009876543",
      "cedula": "0987654321",
      "created_at": "2025-12-08T15:30:00.000Z",
      "updated_at": "2025-12-08T15:30:00.000Z"
    }
  ],
  "total": 2
}
```

---

### 🌐 PASO 3: API SERVICE - FETCH

**Archivo**: `lib/services/api_service.dart`  
**Líneas**: 150-175

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL base del backend (Android emulador usa 10.0.2.2 para localhost)
  static const String baseUrl = 'http://10.0.2.2:3000';
  
  /// GET /api/usuarios - Obtener todos los usuarios
  /// 
  /// RETURNS: List<dynamic> con datos de usuarios
  /// THROWS: Exception si falla la petición
  Future<List<dynamic>> getUsuarios() async {
    try {
      // 1. Construir URL completa
      final url = Uri.parse('$baseUrl/usuarios');
      
      // 2. Hacer petición HTTP GET
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Si requiere autenticación:
          // 'Authorization': 'Bearer $token',
        },
      );

      // 3. Verificar código de estado
      if (response.statusCode == 200) {
        // 4. Parsear JSON response
        final data = jsonDecode(response.body);
        
        // 5. Retornar array de usuarios
        return data['usuarios'] as List<dynamic>;
        
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Token inválido');
        
      } else if (response.statusCode == 500) {
        throw Exception('Error del servidor');
        
      } else {
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
      
    } catch (e) {
      // 6. Manejo de errores de conexión
      print('❌ Error en getUsuarios(): $e');
      throw Exception('Error de conexión: $e');
    }
  }
  
  /// DELETE /api/usuarios/:id - Eliminar usuario
  Future<void> deleteUsuario(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/usuarios/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar usuario');
    }
  }
}
```

---

### 📱 PASO 4: SCREEN - UI CON DISEÑO

**Archivo**: `lib/screens/users_list_screen.dart`  
**Líneas**: 1-300 (completo)

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UsersListScreen extends StatefulWidget {
  static const routeName = '/users';
  
  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  // ============================================
  // VARIABLES DE ESTADO
  // ============================================
  
  List<dynamic> _usuarios = [];        // Lista de usuarios desde BD
  List<dynamic> _usuariosFiltrados = []; // Lista filtrada para búsqueda
  bool _isLoading = true;              // Estado de carga
  String _searchQuery = '';             // Texto de búsqueda
  String _filterRol = 'Todos';         // Filtro por rol
  
  final ApiService _apiService = ApiService();

  // ============================================
  // CICLO DE VIDA
  // ============================================
  
  @override
  void initState() {
    super.initState();
    _cargarUsuarios(); // Cargar datos al iniciar
  }

  // ============================================
  // PASO 4A: FETCH DE DATOS
  // ============================================
  
  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    
    try {
      // 1. Llamar al API Service (que hace el fetch al backend)
      final data = await _apiService.getUsuarios();
      
      // 2. Actualizar estado con los datos recibidos
      setState(() {
        _usuarios = data;
        _usuariosFiltrados = data;
        _isLoading = false;
      });
      
      print('✅ Usuarios cargados: ${_usuarios.length}');
      
    } catch (e) {
      // 3. Manejo de errores
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar usuarios: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: _cargarUsuarios,
          ),
        ),
      );
    }
  }

  // ============================================
  // PASO 4B: FILTRADO LOCAL
  // ============================================
  
  void _filtrarUsuarios() {
    setState(() {
      _usuariosFiltrados = _usuarios.where((usuario) {
        // Filtro por texto de búsqueda
        final matchesSearch = _searchQuery.isEmpty ||
            usuario['nombre'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            usuario['apellido'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            usuario['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Filtro por rol
        final matchesRol = _filterRol == 'Todos' ||
            usuario['rol'].toString().toLowerCase() == _filterRol.toLowerCase();
        
        return matchesSearch && matchesRol;
      }).toList();
    });
  }

  // ============================================
  // PASO 4C: ACCIÓN ELIMINAR
  // ============================================
  
  Future<void> _eliminarUsuario(int id, String nombre) async {
    // Confirmar con el usuario
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar al usuario "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _apiService.deleteUsuario(id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario eliminado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      _cargarUsuarios(); // Recargar lista
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================
  // PASO 4D: UI CON DISEÑO MATERIAL
  // ============================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========== APP BAR ==========
      appBar: AppBar(
        title: Text('Usuarios'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          // Botón refrescar
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarUsuarios,
            tooltip: 'Refrescar',
          ),
          // Botón agregar usuario
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/users/create').then((_) {
                _cargarUsuarios(); // Recargar después de crear
              });
            },
            tooltip: 'Agregar usuario',
          ),
        ],
      ),
      
      body: Column(
        children: [
          // ========== BARRA DE FILTROS ==========
          Container(
            color: Colors.deepPurple,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Campo de búsqueda
                TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, apellido o email...',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filtrarUsuarios();
                  },
                ),
                
                SizedBox(height: 8),
                
                // Filtro por rol
                Row(
                  children: [
                    Text(
                      'Filtrar por rol:',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _filterRol,
                        isExpanded: true,
                        dropdownColor: Colors.deepPurple.shade700,
                        style: TextStyle(color: Colors.white),
                        items: ['Todos', 'Admin', 'Cliente', 'Asesor']
                            .map((rol) => DropdownMenuItem(
                                  value: rol,
                                  child: Text(rol),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _filterRol = value!);
                          _filtrarUsuarios();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // ========== LISTA DE USUARIOS ==========
          Expanded(
            child: _isLoading
                // Loading indicator
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando usuarios...'),
                      ],
                    ),
                  )
                // Lista vacía
                : _usuariosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No se encontraron usuarios',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    // Lista con datos (DISEÑO CARD)
                    : RefreshIndicator(
                        onRefresh: _cargarUsuarios,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _usuariosFiltrados.length,
                          itemBuilder: (context, index) {
                            // ⬇️⬇️⬇️ DATOS DE LA BASE DE DATOS ⬇️⬇️⬇️
                            final usuario = _usuariosFiltrados[index];
                            final id = usuario['id'];
                            final nombre = usuario['nombre'] ?? '';
                            final apellido = usuario['apellido'] ?? '';
                            final email = usuario['email'] ?? '';
                            final rol = usuario['rol'] ?? 'cliente';
                            final telefono = usuario['telefono'] ?? 'Sin teléfono';
                            final cedula = usuario['cedula'] ?? 'Sin cédula';

                            // 🎨🎨🎨 DISEÑO DEL CARD 🎨🎨🎨
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  // Navegar a detalle
                                  Navigator.of(context).pushNamed(
                                    '/users/detail',
                                    arguments: usuario,
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Avatar circular
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: _getRolColor(rol),
                                        child: Text(
                                          nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      
                                      SizedBox(width: 16),
                                      
                                      // Información del usuario
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Nombre completo
                                            Text(
                                              '$nombre $apellido',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            
                                            SizedBox(height: 4),
                                            
                                            // Email
                                            Row(
                                              children: [
                                                Icon(Icons.email, size: 16, color: Colors.grey),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    email,
                                                    style: TextStyle(color: Colors.grey[700]),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            
                                            SizedBox(height: 4),
                                            
                                            // Teléfono
                                            Row(
                                              children: [
                                                Icon(Icons.phone, size: 16, color: Colors.grey),
                                                SizedBox(width: 4),
                                                Text(
                                                  telefono,
                                                  style: TextStyle(color: Colors.grey[700]),
                                                ),
                                              ],
                                            ),
                                            
                                            SizedBox(height: 8),
                                            
                                            // Chip de rol
                                            Chip(
                                              label: Text(
                                                rol.toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              backgroundColor: _getRolColor(rol),
                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Botones de acción
                                      Column(
                                        children: [
                                          // Botón editar
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                '/users/edit',
                                                arguments: usuario,
                                              ).then((_) => _cargarUsuarios());
                                            },
                                            tooltip: 'Editar',
                                          ),
                                          
                                          // Botón eliminar
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _eliminarUsuario(
                                              id,
                                              '$nombre $apellido',
                                            ),
                                            tooltip: 'Eliminar',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
          
          // ========== FOOTER CON CONTADOR ==========
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  '${_usuariosFiltrados.length} usuarios encontrados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================
  
  /// Retorna color según el rol del usuario
  Color _getRolColor(String rol) {
    switch (rol.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'asesor':
      case 'advisor':
        return Colors.blue;
      case 'cliente':
      case 'client':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
```

---

### 📊 RESULTADO VISUAL

```
┌──────────────────────────────────────────────────┐
│  Usuarios                           🔄  ➕       │
├──────────────────────────────────────────────────┤
│  [🔍 Buscar por nombre, apellido o email...]    │
│  Filtrar por rol: [Todos ▼]                     │
├──────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────┐ │
│  │  (L)  Luis Pérez                       ✏️ │ │
│  │       ✉️ luis@email.com                🗑️  │ │
│  │       📱 3001234567                         │ │
│  │       [ADMIN 🔴]                            │ │
│  └────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────┐ │
│  │  (A)  Ana García                       ✏️ │ │
│  │       ✉️ ana@email.com                 🗑️  │ │
│  │       📱 3009876543                         │ │
│  │       [CLIENTE 🟢]                          │ │
│  └────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────┤
│  👥 2 usuarios encontrados                       │
└──────────────────────────────────────────────────┘
```

---

---

## 2. FINCAS

### 📦 PASO 1: BASE DE DATOS

**Archivo**: `database/01_schema.sql`

```sql
CREATE TABLE fincas (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(200) NOT NULL,
  descripcion TEXT,
  direccion VARCHAR(255),
  precio_por_noche DECIMAL(10,2),
  capacidad INT,
  imagen_url TEXT,
  latitud DECIMAL(10, 8),
  longitud DECIMAL(11, 8),
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO fincas (nombre, descripcion, direccion, precio_por_noche, capacidad, imagen_url) VALUES
('Finca El Paraíso', 'Hermosa finca con vista al valle', 'Vereda La Esperanza, km 5', 250000.00, 8, 'https://example.com/finca1.jpg'),
('Finca Los Pinos', 'Ambiente familiar rodeado de naturaleza', 'Vereda El Bosque, km 10', 180000.00, 6, 'https://example.com/finca2.jpg');
```

---

### 💾 PASO 2: BACKEND

**Archivo**: `backend/routes/fincas.js`

```javascript
router.get('/', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        id, 
        nombre, 
        descripcion, 
        direccion,
        precio_por_noche,
        capacidad,
        imagen_url,
        latitud,
        longitud,
        created_at
      FROM fincas
      ORDER BY nombre ASC
    `);

    res.json({
      fincas: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

---

### 🌐 PASO 3: API SERVICE

**Archivo**: `lib/services/api_service.dart`

```dart
Future<List<dynamic>> getFincas() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/fincas'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['fincas'] as List<dynamic>;
    } else {
      throw Exception('Error al cargar fincas');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}
```

---

### 📱 PASO 4: SCREEN CON DISEÑO

**Archivo**: `lib/screens/fincas_screen.dart`

```dart
class FincasScreen extends StatefulWidget {
  static const routeName = '/fincas';
  
  @override
  _FincasScreenState createState() => _FincasScreenState();
}

class _FincasScreenState extends State<FincasScreen> {
  List<dynamic> _fincas = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _cargarFincas();
  }

  Future<void> _cargarFincas() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await _apiService.getFincas();
      setState(() {
        _fincas = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fincas'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _fincas.length,
              itemBuilder: (context, index) {
                final finca = _fincas[index];
                
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/fincas/detail',
                        arguments: finca,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            finca['imagen_url'] ?? 'https://via.placeholder.com/300',
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported, size: 50),
                              );
                            },
                          ),
                        ),
                        
                        // Información
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nombre
                              Text(
                                finca['nombre'] ?? 'Sin nombre',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              SizedBox(height: 4),
                              
                              // Ubicación
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      finca['direccion'] ?? 'Sin dirección',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 4),
                              
                              // Capacidad
                              Row(
                                children: [
                                  Icon(Icons.people, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    '${finca['capacidad'] ?? 0} personas',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 8),
                              
                              // Precio
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '\$${finca['precio_por_noche']}/noche',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
```

---

### 📊 RESULTADO VISUAL

```
┌──────────────────────────────────────┐
│  Fincas                              │
├──────────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐           │
│  │ [IMG]   │  │ [IMG]   │           │
│  │ Finca   │  │ Finca   │           │
│  │ El      │  │ Los     │           │
│  │ Paraíso │  │ Pinos   │           │
│  │📍km 5   │  │📍km 10  │           │
│  │👥 8 pers│  │👥 6 pers│           │
│  │$250k/n  │  │$180k/n  │           │
│  └─────────┘  └─────────┘           │
└──────────────────────────────────────┘
```

---

---

## 3. RESERVAS (ADMIN)

### 📦 PASO 1: BASE DE DATOS

**Archivo**: `database/01_schema.sql`

```sql
CREATE TABLE reservas (
  id SERIAL PRIMARY KEY,
  cliente_id INT REFERENCES clientes(id),
  finca_id INT REFERENCES fincas(id),
  estado VARCHAR(20),
  fecha DATE,
  numero_personas INT,
  precio_total DECIMAL(10,2),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Datos de ejemplo
INSERT INTO reservas (cliente_id, finca_id, estado, fecha, numero_personas, precio_total) VALUES
(1, 1, 'confirmada', '2025-12-15', 4, 1000000.00),
(2, 2, 'pendiente', '2025-12-20', 6, 1080000.00);
```

---

### 💾 PASO 2: BACKEND

**Archivo**: `backend/routes/reservas.js`  
**Líneas**: 48-85

```javascript
/**
 * GET /api/reservas - Obtener todas las reservas con JOIN
 */
router.get('/', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        r.id, 
        r.cliente_id,
        c.nombre as cliente_nombre,
        r.finca_id,
        f.nombre as finca_nombre,
        r.estado,
        r.fecha,
        r.numero_personas,
        r.precio_total,
        r.created_at
      FROM reservas r
      LEFT JOIN clientes c ON r.cliente_id = c.id
      LEFT JOIN fincas f ON r.finca_id = f.id
      ORDER BY r.fecha DESC
    `);

    res.json({ 
      reservas: result.rows, 
      total: result.rows.length 
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

**Respuesta JSON:**
```json
{
  "reservas": [
    {
      "id": 1,
      "cliente_id": 1,
      "cliente_nombre": "Luis Pérez",
      "finca_id": 1,
      "finca_nombre": "Finca El Paraíso",
      "estado": "confirmada",
      "fecha": "2025-12-15",
      "numero_personas": 4,
      "precio_total": 1000000.00
    }
  ],
  "total": 1
}
```

---

### 🌐 PASO 3: API SERVICE - FETCH HTTP

**Archivo**: `lib/services/api_service.dart`  
**Líneas**: 378-395

```dart
/// GET /api/reservas - Obtener todas las reservas
/// 
/// ESTE ES EL FETCH: http.get() hace la petición HTTP
Future<List<dynamic>> getReservas() async {
  try {
    // 🔥 AQUÍ SUCEDE EL FETCH 🔥
    final response = await http.get(
      Uri.parse('$baseUrl/reservas'),  // URL completa: http://10.0.2.2:3000/api/reservas
      headers: _getHeaders(requiresAuth: false),
    );

    // Parsear respuesta JSON
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['reservas'];  // Retorna array de reservas
    } else {
      throw data['message'] ?? 'Error al obtener reservas';
    }
  } catch (e) {
    throw 'Error de conexión: $e';
  }
}
```

**¿QUÉ HACE `http.get()`?**
1. Envía petición HTTP GET a `http://10.0.2.2:3000/api/reservas`
2. Espera respuesta del servidor (backend Node.js)
3. Recibe JSON con las reservas
4. Parsea el JSON a objeto Dart
5. Retorna la lista de reservas

---

### 📱 PASO 4: SCREEN - LLAMAR AL FETCH

**Archivo**: `lib/screens/reservations_list_screen.dart`  
**Líneas**: 34-48

```dart
class _ReservationsListScreenState extends State<ReservationsListScreen> {
  List<dynamic> _reservas = [];  // Lista que se llenará con datos del backend
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReservas();  // Cargar al iniciar la pantalla
  }

  /// MÉTODO QUE LLAMA AL FETCH
  Future<void> _loadReservas() async {
    setState(() => _loading = true);
    
    try {
      final apiService = ApiService();
      
      // 🔥 AQUÍ SE LLAMA AL FETCH 🔥
      // Este método internamente hace http.get()
      final data = await apiService.getReservas();
      
      // Actualizar estado con los datos recibidos
      setState(() {
        _reservas = data;  // Ahora _reservas tiene los datos de la BD
        _loading = false;
      });
      
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar reservas: $e')),
      );
    }
  }
}
```

---

### 🎨 PASO 5: CONSTRUIR LOS CARDS

**Archivo**: `lib/screens/reservations_list_screen.dart`  
**Líneas**: 155-187

```dart
@override
Widget build(BuildContext context) {
  final filtered = _filteredReservas();  // Lista filtrada de reservas

  return Scaffold(
    appBar: AppBar(
      title: Text('Reservas'),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _loadReservas,  // Refetch cuando se presiona
        ),
      ],
    ),
    body: Column(
      children: [
        // ... filtros y búsqueda ...
        
        Expanded(
          child: _loading
              ? Center(child: CircularProgressIndicator())  // Loading state
              : filtered.isEmpty
                  ? Center(child: Text('No hay reservas'))   // Empty state
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        // 🔥 DATOS DE LA BASE DE DATOS 🔥
                        final r = filtered[i];
                        final fecha = r['fecha']?.toString().split('T')[0] ?? '';
                        final clienteNombre = r['cliente_nombre'] ?? 'Sin cliente';
                        final fincaNombre = r['finca_nombre'] ?? 'Sin finca';
                        final estado = r['estado'] ?? '';
                        final personas = r['numero_personas'] ?? 0;

                        // 🎨🎨🎨 AQUÍ SE CONSTRUYE EL CARD 🎨🎨🎨
                        return Card(
                          child: ListTile(
                            title: Text('Reserva #${r['id']} - $clienteNombre'),
                            subtitle: Text(
                              '$fecha • $fincaNombre • $personas persona(s) • Estado: $estado',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editarReserva(r),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _cancelarReserva(r['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    ),
  );
}
```

---

### 📊 FLUJO COMPLETO RESERVAS:

```
1. Usuario abre pantalla
   ↓
2. initState() llama _loadReservas()
   ↓
3. _loadReservas() llama apiService.getReservas()
   ↓
4. getReservas() ejecuta http.get() ← FETCH AQUÍ
   ↓
5. Backend responde con JSON
   ↓
6. jsonDecode() parsea el JSON
   ↓
7. setState() actualiza _reservas
   ↓
8. build() reconstruye UI
   ↓
9. ListView.builder() crea Cards ← CARDS AQUÍ
   ↓
10. Usuario ve las reservas en pantalla
```

---

---

## PATRONES DE DISEÑO COMUNES

### 🎨 CARD CON AVATAR

```dart
Card(
  child: ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.blue,
      child: Icon(Icons.person, color: Colors.white),
    ),
    title: Text('Título'),
    subtitle: Text('Subtítulo'),
    trailing: IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ),
)
```

---

### 🎨 CARD CON IMAGEN

```dart
Card(
  child: Column(
    children: [
      Image.network(
        imageUrl,
        height: 150,
        fit: BoxFit.cover,
      ),
      Padding(
        padding: EdgeInsets.all(8),
        child: Text('Contenido'),
      ),
    ],
  ),
)
```

---

### 🎨 LOADING STATE

```dart
_isLoading
  ? Center(child: CircularProgressIndicator())
  : ListView.builder(...)
```

---

### 🎨 EMPTY STATE

```dart
_items.isEmpty
  ? Center(
      child: Column(
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey),
          Text('No hay elementos'),
        ],
      ),
    )
  : ListView.builder(...)
```

---

### 🎨 PULL TO REFRESH

```dart
RefreshIndicator(
  onRefresh: _cargarDatos,
  child: ListView.builder(...),
)
```

---

## COMPONENTES VISUALES

### 🎨 COLORES POR ROL/ESTADO

```dart
Color _getRolColor(String rol) {
  switch (rol.toLowerCase()) {
    case 'admin': return Colors.red;
    case 'asesor': return Colors.blue;
    case 'cliente': return Colors.green;
    default: return Colors.grey;
  }
}

Color _getEstadoColor(String estado) {
  switch (estado.toLowerCase()) {
    case 'confirmada': return Colors.green;
    case 'pendiente': return Colors.orange;
    case 'cancelada': return Colors.red;
    default: return Colors.grey;
  }
}
```

---

### 🎨 CHIPS DE ESTADO

```dart
Chip(
  label: Text(
    estado.toUpperCase(),
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  backgroundColor: _getEstadoColor(estado),
)
```

---

## 📝 RESUMEN FINAL

**TODOS LOS MÓDULOS DEL PROYECTO SIGUEN ESTE PATRÓN:**

```
1. BASE DE DATOS (PostgreSQL)
   ↓ SELECT con JOIN
2. BACKEND (Node.js + Express)
   ↓ router.get('/')
3. API SERVICE (Flutter)
   ↓ http.get() + jsonDecode()
4. SCREEN (Flutter)
   ↓ setState() + ListView.builder + Card
```

**DISEÑO CONSISTENTE:**
- Cards con elevación
- Colores por categoría (roles, estados)
- Iconos descriptivos
- Loading states
- Empty states
- Pull to refresh
- Filtros y búsqueda

---

**Documento generado**: 9 de diciembre de 2025  
**Proyecto**: Occitours  
**Patrón**: Backend → API Service → Screen → UI
