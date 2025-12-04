import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL base del backend (localhost para emulador Android usa 10.0.2.2)
  static const String baseUrl = 'http://localhost:3000/api';

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
}
