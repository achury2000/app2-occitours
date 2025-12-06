import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class ApiService {
  // URL base del backend - detecta automáticamente la plataforma
  static String get baseUrl {
    // En Android usa 10.0.2.2 (IP especial del emulador para localhost del host)
    // En web/iOS/otros usa localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  String? _token;

  // Setter para el token JWT
  void setToken(String? token) {
    _token = token;
  }

  // Headers comunes
  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (requiresAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // ========================================
  // AUTENTICACIÓN
  // ========================================

  /// POST /api/auth/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Login exitoso
        return data;
      } else {
        // Error del servidor
        throw data['message'] ?? data['error'] ?? 'Error al iniciar sesión';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// POST /api/auth/register
  Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellido,
    required String cedula,
    required String email,
    required String password,
    String? telefono,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'nombre': nombre,
          'apellido': apellido,
          'cedula': cedula,
          'email': email,
          'password': password,
          'telefono': telefono,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Registro exitoso
        return data;
      } else {
        // Error del servidor
        throw data['message'] ?? data['error'] ?? 'Error al registrar';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// GET /api/auth/profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _getHeaders(requiresAuth: true),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener perfil';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// POST /api/auth/logout
  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _getHeaders(requiresAuth: true),
      );
    } catch (e) {
      // Ignorar errores en logout, limpiar localmente de todos modos
    }
  }

  // ========================================
  // USUARIOS (ADMIN)
  // ========================================

  /// GET /api/auth/users/public - Listar todos los usuarios (sin autenticación)
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users/public'),
        headers: _getHeaders(requiresAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(data['usuarios'] ?? []);
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener usuarios';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// GET /api/auth/users/:id - Obtener usuario por ID (admin)
  Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users/$id'),
        headers: _getHeaders(requiresAuth: true),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['usuario'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener usuario';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// PUT /api/auth/users/:id - Actualizar usuario (admin o el mismo usuario)
  Future<Map<String, dynamic>> updateUser(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/users/$id'),
        headers: _getHeaders(requiresAuth: true),
        body: jsonEncode(updates),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al actualizar usuario';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// DELETE /api/auth/users/:id - Eliminar usuario (admin)
  Future<void> deleteUser(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/users/$id'),
        headers: _getHeaders(requiresAuth: true),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw data['message'] ?? data['error'] ?? 'Error al eliminar usuario';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }
}
