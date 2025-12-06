import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  AuthProvider() {
    _loadFromPrefs();
  }
  User? _user;
  String? _token;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Llamar al backend real
      final response = await _apiService.login(email, password);

      if (response['success'] == true) {
        _token = response['token'];
        _apiService.setToken(_token);

        final userData = response['usuario'];
        _user = User(
          id: userData['id'].toString(),
          name: '${userData['nombre']} ${userData['apellido']}',
          email: userData['email'],
          role: userData['rol'],
          phone: '', // No viene en la respuesta del login
          address: '',
        );

        // Persistir token y datos
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userId', _user!.id);
        await prefs.setString('userName', _user!.name);
        await prefs.setString('userEmail', _user!.email);
        await prefs.setString('userRole', _user!.role);

        print('💾 Sesión guardada en SharedPreferences');
        print('   Token: ${_token?.substring(0, 20)}...');
        print('   Usuario: ${_user!.email} (${_user!.role})');
      } else {
        _error = response['message'] ?? 'Error al iniciar sesión';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

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
      return response;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> verifySession() async {
    _loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');

    if (storedToken != null) {
      try {
        _token = storedToken;
        _apiService.setToken(storedToken);

        // Verificar si el token sigue válido obteniendo el perfil
        final response = await _apiService.getProfile();

        if (response['success'] == true) {
          final userData = response['usuario'];
          _user = User(
            id: userData['id'].toString(),
            name: '${userData['nombre']} ${userData['apellido']}',
            email: userData['email'],
            role: userData['rol'],
            phone: '',
            address: '',
          );
        }
      } catch (e) {
        // Token inválido o expirado, limpiar
        await logout();
      }
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
