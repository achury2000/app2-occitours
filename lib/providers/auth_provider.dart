/**
 * =============================================
 * AUTH_PROVIDER.DART - GESTIÓN DE AUTENTICACIÓN
 * =============================================
 * 
 * Provider que maneja la autenticación de usuarios,
 * conectándose al backend para login, registro y logout.
 * 
 * RESPONSABILIDADES:
 * - Iniciar sesión (POST /api/auth/login)
 * - Registrar nuevos usuarios (POST /api/auth/register)
 * - Cerrar sesión (POST /api/auth/logout)
 * - Mantener estado del usuario autenticado
 * - Persistir sesión con SharedPreferences
 * - Recuperar sesión al iniciar la app
 * 
 * INTEGRACIÓN CON BACKEND:
 * - Recibe token JWT del backend al hacer login
 * - Configura token en ApiService para peticiones futuras
 * - Guarda token localmente para mantener sesión
 * 
 * USO:
 * ```dart
 * final auth = Provider.of<AuthProvider>(context);
 * await auth.login(email, password);
 * if (auth.isAuthenticated) {
 *   Navigator.pushReplacementNamed(context, '/home');
 * }
 * ```
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

/// Provider de autenticación con integración al backend
class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// Constructor - Intenta recuperar sesión guardada
  AuthProvider() {
    _loadFromPrefs();
  }

  // ====== ESTADO PRIVADO ======
  User? _user; // Usuario actual (null si no hay sesión)
  String? _token; // Token JWT (null si no está autenticado)
  bool _loading = false; // Estado de carga durante operaciones
  String? _error; // Mensaje de error si algo falla

  // ====== GETTERS PÚBLICOS ======
  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null; // true si hay token
  bool get loading => _loading;
  String? get error => _error;

  /// Inicia sesión con email y contraseña
  /// Endpoint: POST /api/auth/login
  ///
  /// Guarda el token JWT y los datos del usuario tanto en memoria
  /// como en SharedPreferences para mantener la sesión
  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners(); // Notificar: "Estoy cargando, muestra loading"

    try {
      // Llamar al backend real
      final response = await _apiService.login(email, password);

      if (response['success'] == true) {
        // Extraer token JWT del response
        _token = response['token'];
        _apiService.setToken(_token); // Configurar para peticiones futuras

        // Crear objeto User con datos del backend
        final userData = response['usuario'];
        _user = User(
          id: userData['id'].toString(),
          name:
              '${userData['nombre']} ${userData['apellido']}', // Concatenar nombre completo
          email: userData['email'],
          role: userData['rol'], // admin, asesor, cliente, guia
          cedula: userData['cedula']?.toString(),
          phone: '', // No viene en la respuesta del login
          address: '',
        );

        // Persistir sesión en SharedPreferences (almacenamiento local)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userId', _user!.id);
        await prefs.setString('userName', _user!.name);
        await prefs.setString('userEmail', _user!.email);
        await prefs.setString('userRole', _user!.role);
        if (_user!.cedula != null) {
          await prefs.setString('userCedula', _user!.cedula!);
        }

        print('💾 Sesión guardada en SharedPreferences');
        print('   Token: ${_token?.substring(0, 20)}...');
        print('   Usuario: ${_user!.email} (${_user!.role})');
      } else {
        _error = response['message'] ?? 'Error al iniciar sesión';
      }
    } catch (e) {
      _error = e.toString(); // Capturar errores de red o parsing
    } finally {
      _loading = false;
      notifyListeners(); // Notificar: "Terminé, actualiza la UI"
    }
  }

  /// Registra un nuevo usuario en el sistema
  /// Endpoint: POST /api/auth/register
  ///
  /// Retorna un Map con la respuesta del backend
  /// No hace login automático, el usuario debe iniciar sesión después
  Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellido,
    required String cedula,
    required String email,
    required String password,
    String? telefono,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Llamar al backend para registrar usuario
      final response = await _apiService.register(
        nombre: nombre,
        apellido: apellido,
        cedula: cedula,
        email: email,
        password: password,
        telefono: telefono,
      );

      _loading = false;
      notifyListeners();
      return response; // Retornar respuesta para que la UI la maneje
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e; // Relanzar para que la UI muestre el error
    }
  }

  /// Cierra la sesión del usuario
  /// Endpoint: POST /api/auth/logout
  ///
  /// Limpia el token, el usuario y los datos guardados localmente
  Future<void> logout() async {
    await _apiService.logout(); // Notificar al backend

    // Limpiar estado en memoria
    _token = null;
    _user = null;

    // Limpiar SharedPreferences (borra todos los datos guardados)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners(); // Notificar para que la UI redirija al login
  }

  /// Verifica si hay una sesión guardada al iniciar la app
  ///
  /// Lee token y datos de usuario de SharedPreferences
  /// Si encuentra datos válidos, restaura la sesión automáticamente
  Future<void> verifySession() async {
    _loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    final userId = prefs.getString('userId');
    final userName = prefs.getString('userName');
    final userEmail = prefs.getString('userEmail');
    final userRole = prefs.getString('userRole');

    if (storedToken != null && userId != null) {
      // Restaurar sesión desde SharedPreferences (auto-login)
      _token = storedToken;
      _apiService.setToken(storedToken);
      _user = User(
        id: userId,
        name: userName ?? '',
        email: userEmail ?? '',
        role: userRole ?? '',
        phone: '',
        address: '',
      );
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    final userId = prefs.getString('userId');
    final userName = prefs.getString('userName');
    final userEmail = prefs.getString('userEmail');
    final userRole = prefs.getString('userRole');
    final userCedula = prefs.getString('userCedula');

    print('🔄 Cargando sesión desde SharedPreferences...');
    print('   Token existe: ${storedToken != null}');
    print('   UserId: $userId');
    print('   UserRole: $userRole');

    if (storedToken != null && userId != null) {
      _token = storedToken;
      _apiService.setToken(storedToken);
      _user = User(
        id: userId,
        name: userName ?? '',
        email: userEmail ?? '',
        role: userRole ?? '',
        cedula: userCedula,
        phone: '',
        address: '',
      );
      print('✅ Sesión restaurada: ${_user?.email} (${_user?.role})');
      notifyListeners();
    } else {
      print('❌ No hay sesión guardada');
    }
  }

  bool hasAnyRole(List<String> roles) {
    final r = (_user?.role ?? '').toLowerCase();
    return roles.map((e) => e.toLowerCase()).contains(r);
  }
}
