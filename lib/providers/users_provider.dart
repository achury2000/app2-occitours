// parte linsaith
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UsersProvider with ChangeNotifier {
  static const _prefsKey = 'users_v1';

  List<User> _users = [];
  final List<Map<String, dynamic>> _audit = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;

  List<User> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  String? get error => _error;

  UsersProvider() {
    // Inicializar con lista vacía para evitar errores
    _users = [];
  }

  // Setter para el token de API
  void setToken(String? token) {
    _apiService.setToken(token);
  }

  // Cargar usuarios desde el backend
  Future<void> loadUsersFromBackend() async {
    _isLoading = true;
    _error = null;
    // No notificar inmediatamente para evitar errores durante el build

    try {
      final usuariosData = await _apiService.getUsers();

      _users = usuariosData.map((data) {
        // Mapear roles del backend a los del frontend
        String roleFrontend = 'customer';
        final roleBackend = (data['rol'] ?? '').toString().toLowerCase();

        if (roleBackend == 'admin' || roleBackend == 'administrador') {
          roleFrontend = 'admin';
        } else if (roleBackend == 'guia' || roleBackend == 'guide') {
          roleFrontend = 'guide';
        } else {
          roleFrontend = 'customer';
        }

        return User(
          id: data['id'].toString(),
          name: '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}'.trim(),
          email: data['email'] ?? '',
          role: roleFrontend,
          phone: data['telefono']?.toString(),
          address: null,
          active: data['activo'] ?? true,
        );
      }).toList();

      await _save();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      // Mantener lista vacía en caso de error
      _users = [];
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _users
        .map((u) => {
              'id': u.id,
              'name': u.name,
              'email': u.email,
              'role': u.role,
              'phone': u.phone,
              'address': u.address,
              'active': u.active,
            })
        .toList();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  Future<void> _saveAudit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('users_audit', jsonEncode(_audit));
  }

  List<Map<String, dynamic>> get audit => List.unmodifiable(_audit);

  bool emailExists(String email, {String? excludeId}) {
    final e = email.toLowerCase();
    return _users.any((u) =>
        u.email.toLowerCase() == e && (excludeId == null || u.id != excludeId));
  }

  Future<void> addUser(Map<String, dynamic> data,
      {Map<String, String>? actor}) async {
    final id = 'u${DateTime.now().millisecondsSinceEpoch}';
    final user = User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      phone: data['phone'],
      address: data['address'],
    );
    _users.insert(0, user);
    _audit.insert(0, {
      'action': 'create_user',
      'userId': id,
      'actor': actor ?? {},
      'timestamp': DateTime.now().toIso8601String(),
      'data': {'name': user.name, 'email': user.email, 'role': user.role}
    });
    await _save();
    await _saveAudit();
    notifyListeners();
  }

  Future<void> updateUser(String id, Map<String, dynamic> data,
      {Map<String, String>? actor}) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx >= 0) {
      final u = _users[idx];
      u.name = data['name'] ?? u.name;
      u.email = data['email'] ?? u.email;
      u.role = data['role'] ?? u.role;
      u.phone = data['phone'] ?? u.phone;
      u.address = data['address'] ?? u.address;
      if (data.containsKey('active')) {
        u.active = data['active'] as bool;
      }
      _audit.insert(0, {
        'action': 'update_user',
        'userId': id,
        'actor': actor ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'changes': data
      });
      await _save();
      await _saveAudit();
      notifyListeners();
    }
  }

  Future<void> toggleActiveWithAudit(String id,
      {Map<String, String>? actor}) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx >= 0) {
      _users[idx].active = !_users[idx].active;
      _audit.insert(0, {
        'action': 'toggle_active_user',
        'userId': id,
        'newValue': _users[idx].active,
        'actor': actor ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _save();
      await _saveAudit();
      notifyListeners();
    }
  }

  Future<void> updateRole(String id, String role) async {
    try {
      // Mapear rol del frontend al backend
      int rolId;
      if (role == 'admin') {
        rolId = 1; // admin
      } else if (role == 'guide') {
        rolId = 3; // guia
      } else {
        rolId = 2; // cliente
      }

      await _apiService.updateUser(id, {'rol_id': rolId});

      // Actualizar localmente
      final idx = _users.indexWhere((u) => u.id == id);
      if (idx >= 0) {
        _users[idx].role = role;
        await _save();

        // Persistir cambio por usuario
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole_' + id, role);
        notifyListeners();
      }

      // Recargar desde backend para asegurar sincronización
      await loadUsersFromBackend();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteUserWithAudit(String id,
      {Map<String, String>? actor}) async {
    try {
      await _apiService.deleteUser(id);

      // Actualizar localmente
      _users.removeWhere((u) => u.id == id);
      _audit.insert(0, {
        'action': 'delete_user',
        'userId': id,
        'actor': actor ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _save();
      await _saveAudit();
      notifyListeners();

      // Recargar desde backend
      await loadUsersFromBackend();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
