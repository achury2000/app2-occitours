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
  Future<Map<String, dynamic>> getProfile({String? userId}) async {
    try {
      final uri = userId != null
          ? Uri.parse('$baseUrl/auth/profile?id=$userId')
          : Uri.parse('$baseUrl/auth/profile');

      final response = await http.get(
        uri,
        headers: _getHeaders(requiresAuth: false),
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
        headers: _getHeaders(requiresAuth: false),
      );
    } catch (e) {
      // Ignorar errores en logout, limpiar localmente de todos modos
    }
  }

  // ========================================
  // USUARIOS (PÚBLICO)
  // ========================================

  /// GET /api/auth/users - Listar todos los usuarios (público, sin autenticación)
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users'),
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

  /// GET /api/auth/users/:id - Obtener usuario por ID (público)
  Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users/$id'),
        headers: _getHeaders(requiresAuth: false),
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

  /// PUT /api/auth/users/:id - Actualizar usuario (público)
  Future<Map<String, dynamic>> updateUser(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/users/$id'),
        headers: _getHeaders(requiresAuth: false),
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

  /// DELETE /api/auth/users/:id - Eliminar usuario (público)
  Future<void> deleteUser(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/users/$id'),
        headers: _getHeaders(requiresAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw data['message'] ?? data['error'] ?? 'Error al eliminar usuario';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  // ========================================
  // ROLES Y PERMISOS
  // ========================================

  /// GET /api/roles - Listar todos los roles
  Future<List<Map<String, dynamic>>> getRoles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roles'),
        headers: _getHeaders(requiresAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(data['roles'] ?? []);
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener roles';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// GET /api/roles/:id - Obtener rol por ID con permisos
  Future<Map<String, dynamic>> getRolById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roles/$id'),
        headers: _getHeaders(requiresAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['rol'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener rol';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// POST /api/roles - Crear nuevo rol
  Future<Map<String, dynamic>> createRol(String nombre) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/roles'),
        headers: _getHeaders(requiresAuth: false),
        body: jsonEncode({'nombre': nombre}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al crear rol';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// PUT /api/roles/:id - Actualizar rol
  Future<Map<String, dynamic>> updateRol(String id, String nombre) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/roles/$id'),
        headers: _getHeaders(requiresAuth: false),
        body: jsonEncode({'nombre': nombre}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al actualizar rol';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// DELETE /api/roles/:id - Eliminar rol
  Future<void> deleteRol(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/roles/$id'),
        headers: _getHeaders(requiresAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw data['message'] ?? data['error'] ?? 'Error al eliminar rol';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  // ========================================
  // RESERVAS
  // ========================================

  /// GET /api/reservas - Obtener todas las reservas
  Future<List<dynamic>> getReservas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas'),
        headers: _getHeaders(requiresAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['reservas'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener reservas';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// GET /api/reservas/:id - Obtener una reserva por ID
  Future<Map<String, dynamic>> getReservaById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas/$id'),
        headers: _getHeaders(requiresAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['reserva'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener reserva';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// POST /api/reservas - Crear nueva reserva
  Future<Map<String, dynamic>> createReserva({
    required int clienteId,
    required String fecha,
    int? programacionId,
    int? fincaId,
    int? ventaId,
    String estado = 'confirmada',
    int? numeroPersonas,
    double? precioTotal,
    String? qrCode,
    String? comprobantePago,
  }) async {
    try {
      final body = {
        'cliente_id': clienteId,
        'fecha': fecha,
        'estado': estado,
      };

      if (programacionId != null) body['programacion_id'] = programacionId;
      if (fincaId != null) body['finca_id'] = fincaId;
      if (ventaId != null) body['venta_id'] = ventaId;
      if (numeroPersonas != null) body['numero_personas'] = numeroPersonas;
      if (precioTotal != null) body['precio_total'] = precioTotal;
      if (qrCode != null) body['qr_code'] = qrCode;
      if (comprobantePago != null) body['comprobante_pago'] = comprobantePago;

      final response = await http.post(
        Uri.parse('$baseUrl/reservas'),
        headers: _getHeaders(requiresAuth: false),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al crear reserva';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// PUT /api/reservas/:id - Actualizar reserva
  Future<Map<String, dynamic>> updateReserva(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reservas/$id'),
        headers: _getHeaders(requiresAuth: false),
        body: jsonEncode(updates),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al actualizar reserva';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// DELETE /api/reservas/:id - Cancelar reserva
  Future<void> deleteReserva(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reservas/$id'),
        headers: _getHeaders(requiresAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw data['message'] ?? data['error'] ?? 'Error al cancelar reserva';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// GET /api/reservas/cliente/:cliente_id - Obtener reservas de un cliente
  Future<List<dynamic>> getReservasByCliente(int clienteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas/cliente/$clienteId'),
        headers: _getHeaders(requiresAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['reservas'];
      } else {
        throw data['message'] ??
            data['error'] ??
            'Error al obtener reservas del cliente';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }
}
