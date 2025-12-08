/**
 * =============================================
 * API_SERVICE.DART - CLIENTE HTTP PARA BACKEND
 * =============================================
 * 
 * Servicio singleton que maneja todas las peticiones HTTP
 * al backend de Occitours. Proporciona métodos para interactuar
 * con todos los endpoints de la API REST.
 * 
 * CARACTERÍSTICAS:
 * - Detección automática de plataforma (Android usa 10.0.2.2)
 * - Gestión de autenticación JWT
 * - Manejo centralizado de errores
 * - Métodos para todos los recursos (fincas, rutas, reservas, ventas, etc.)
 * 
 * ARQUITECTURA:
 * Cada método corresponde a un endpoint del backend y retorna
 * un Map<String, dynamic> con la respuesta JSON parseada.
 * 
 * ERRORES:
 * Los métodos lanzan excepciones (throw) cuando hay errores,
 * que deben ser capturadas con try-catch en las pantallas.
 * 
 * USO:
 * ```dart
 * final apiService = ApiService();
 * final fincas = await apiService.getFincas();
 * ```
 */

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class ApiService {
  // =============================================
  // CONFIGURACIÓN DE URL BASE
  // =============================================
  /// URL base del backend - detecta automáticamente la plataforma
  /// - Android Emulator: usa 10.0.2.2 (mapea a localhost del host)
  /// - iOS/Web/Otros: usa localhost directamente
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  // Token JWT para autenticación
  String? _token;

  // =============================================
  // GESTIÓN DE AUTENTICACIÓN
  // =============================================
  /// Establece el token JWT para peticiones autenticadas
  void setToken(String? token) {
    _token = token;
  }

  /// Genera headers HTTP con Content-Type y opcionalmente Authorization
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
  /// Inicia sesión con email y contraseña
  ///
  /// Returns: { success: true, token: '...', user: {...} }
  /// Throws: String con mensaje de error
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
        // Login exitoso - retorna token y datos del usuario
        return data;
      } else {
        // Error del servidor (401, 403, etc.)
        throw data['message'] ?? data['error'] ?? 'Error al iniciar sesión';
      }
    } catch (e) {
      // Error de red o parsing
      throw 'Error de conexión: $e';
    }
  }

  /// POST /api/auth/register
  /// Registra un nuevo usuario en el sistema
  ///
  /// Returns: { success: true, user: {...} }
  /// Throws: String con mensaje de error
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
        // Error del servidor (400, 409, etc.)
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
    List<int>? serviciosIds, // Lista simple de IDs de servicios
    List<Map<String, dynamic>>?
        servicios, // Array de {servicio_id, cantidad, precio_unitario}
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

      // Convertir serviciosIds a formato esperado por backend
      if (serviciosIds != null && serviciosIds.isNotEmpty) {
        body['servicios'] = serviciosIds
            .map((id) =>
                {'servicio_id': id, 'cantidad': 1, 'precio_unitario': 0})
            .toList();
      } else if (servicios != null && servicios.isNotEmpty) {
        body['servicios'] = servicios;
      }

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
    String id, {
    int? clienteId,
    String? fecha,
    int? programacionId,
    int? fincaId,
    int? numeroPersonas,
    String? estado,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (clienteId != null) updates['cliente_id'] = clienteId;
      if (fecha != null) updates['fecha'] = fecha;
      if (programacionId != null) updates['programacion_id'] = programacionId;
      if (fincaId != null) updates['finca_id'] = fincaId;
      if (numeroPersonas != null) updates['numero_personas'] = numeroPersonas;
      if (estado != null) updates['estado'] = estado;

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

  // ========================================
  // CLIENTES
  // ========================================

  /// GET /api/clientes - Obtener todos los clientes
  Future<List<dynamic>> getClientes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['clientes'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener clientes';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// GET /api/clientes/by-cedula/:cedula - Obtener cliente por cédula
  Future<Map<String, dynamic>> getClienteByCedula(String cedula) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes/by-cedula/$cedula'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['cliente'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener cliente';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  // ========================================
  // FINCAS
  // ========================================

  /// GET /api/fincas - Obtener todas las fincas
  Future<List<dynamic>> getFincas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fincas'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['fincas'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener fincas';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  // ========================================
  // SERVICIOS
  // ========================================

  /// GET /api/servicios - Obtener todos los servicios
  Future<List<dynamic>> getServicios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/servicios'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['servicios'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener servicios';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  // ========================================
  // RUTAS
  // ========================================

  /// GET /api/rutas - Obtener todas las rutas
  Future<List<dynamic>> getRutas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rutas'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['rutas'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener rutas';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  // ========================================
  // PROGRAMACIONES
  // ========================================

  /// GET /api/programaciones - Obtener todas las programaciones
  Future<List<dynamic>> getProgramaciones() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/programaciones'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['programaciones'];
      } else {
        throw data['message'] ??
            data['error'] ??
            'Error al obtener programaciones';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  // ========================================
  // VENTAS - Gestión de ventas y pagos
  // ========================================
  // Las ventas agrupan múltiples reservas de un cliente
  // y permiten gestionar pagos parciales (abonos).

  /// GET /api/ventas - Obtener todas las ventas
  ///
  /// Returns: Lista de ventas con cliente, asesor y número de reservas
  /// [ { id, cliente_nombre, asesor_nombre, fecha, total, estado, num_reservas }, ... ]
  Future<List<dynamic>> getVentas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ventas'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['ventas'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener ventas';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// GET /api/ventas/:id - Obtener una venta por ID
  ///
  /// Returns: Objeto con venta, reservas asociadas y abonos realizados
  /// { venta: {...}, reservas: [...], abonos: [...] }
  Future<Map<String, dynamic>> getVenta(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ventas/$id'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['venta'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener venta';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// POST /api/ventas - Crear nueva venta
  ///
  /// Params:
  /// - clienteId: ID del cliente (requerido)
  /// - asesorId: ID del asesor (opcional)
  /// - reservasIds: Lista de IDs de reservas a asociar (opcional)
  ///
  /// Returns: { success: true, venta: {...} }
  Future<Map<String, dynamic>> createVenta({
    required int clienteId,
    int? asesorId,
    String? fecha,
    double? total,
    String estado = 'pendiente',
    List<int>? reservasIds,
  }) async {
    try {
      final body = {
        'cliente_id': clienteId,
        'fecha': fecha ?? DateTime.now().toIso8601String().split('T')[0],
        'estado': estado,
      };

      if (asesorId != null) body['asesor_id'] = asesorId;
      if (total != null) body['total'] = total;
      if (reservasIds != null && reservasIds.isNotEmpty) {
        body['reservas_ids'] = reservasIds;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/ventas'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al crear venta';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// PUT /api/ventas/:id - Actualizar venta
  Future<Map<String, dynamic>> updateVenta(
    String id, {
    int? clienteId,
    int? asesorId,
    String? fecha,
    double? total,
    String? estado,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (clienteId != null) updates['cliente_id'] = clienteId;
      if (asesorId != null) updates['asesor_id'] = asesorId;
      if (fecha != null) updates['fecha'] = fecha;
      if (total != null) updates['total'] = total;
      if (estado != null) updates['estado'] = estado;

      final response = await http.put(
        Uri.parse('$baseUrl/ventas/$id'),
        headers: _getHeaders(),
        body: jsonEncode(updates),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al actualizar venta';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// DELETE /api/ventas/:id - Eliminar venta
  Future<void> deleteVenta(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/ventas/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw data['message'] ?? data['error'] ?? 'Error al eliminar venta';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// POST /api/ventas/:id/abono - Agregar abono a venta
  Future<Map<String, dynamic>> addAbonoToVenta(
    String ventaId, {
    required double monto,
    String? fecha,
  }) async {
    try {
      final body = {
        'monto': monto,
        'fecha': fecha ?? DateTime.now().toIso8601String().split('T')[0],
      };

      final response = await http.post(
        Uri.parse('$baseUrl/ventas/$ventaId/abono'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al agregar abono';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  // ========================================
  // DASHBOARD - Estadísticas y Analytics
  // ========================================
  // Estos métodos obtienen datos agregados para mostrar
  // en los dashboards de administración (gráficos, métricas, tops).

  /// GET /api/dashboard/stats - Estadísticas generales del sistema
  ///
  /// Returns: {
  ///   totales: { fincas, rutas, servicios, clientes, reservas, ventas },
  ///   ingresos: { total_general, total_completado, total_confirmado, total_pendiente },
  ///   reservas_por_estado: [ { estado, cantidad }, ... ]
  /// }
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/stats'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw data['message'] ??
            data['error'] ??
            'Error al obtener estadísticas';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// GET /api/dashboard/ingresos-mensuales - Ingresos agrupados por mes
  ///
  /// Params:
  /// - year: Año para filtrar (opcional, por defecto año actual)
  ///
  /// Returns: {
  ///   year: 2025,
  ///   data: [150000, 230000, ...] // Array de 12 posiciones (enero a diciembre)
  /// }
  ///
  /// Uso: Para generar gráficos de barras mensuales
  Future<Map<String, dynamic>> getIngresosMensuales({int? year}) async {
    try {
      final queryParams = year != null ? '?year=$year' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/ingresos-mensuales$queryParams'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw data['message'] ??
            data['error'] ??
            'Error al obtener ingresos mensuales';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// GET /api/dashboard/top-fincas - Top 5 fincas más reservadas
  ///
  /// Returns: [
  ///   { nombre, total_reservas, ingresos_totales },
  ///   ...
  /// ]
  Future<List<dynamic>> getTopFincas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/top-fincas'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener top fincas';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// GET /api/dashboard/top-rutas - Top 5 rutas más populares
  ///
  /// Returns: [
  ///   { nombre, total_reservas, ingresos_totales },
  ///   ...
  /// ]
  Future<List<dynamic>> getTopRutas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/top-rutas'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw data['message'] ?? data['error'] ?? 'Error al obtener top rutas';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// GET /api/dashboard/top-servicios - Top 5 servicios
  Future<List<dynamic>> getTopServicios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/top-servicios'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw data['message'] ??
            data['error'] ??
            'Error al obtener top servicios';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  /// GET /api/dashboard/reservas-recientes - Últimas reservas
  Future<List<dynamic>> getReservasRecientes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/reservas-recientes'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw data['message'] ??
            data['error'] ??
            'Error al obtener reservas recientes';
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }
}
