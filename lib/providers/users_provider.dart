/**
 * =============================================
 * USERS_PROVIDER.DART - GESTIÓN DE USUARIOS
 * =============================================
 * 
 * Provider que maneja la lista de usuarios del sistema,
 * conectándose al backend para operaciones CRUD.
 * 
 * RESPONSABILIDADES:
 * - Cargar usuarios desde el backend (GET /api/auth/users)
 * - Actualizar roles de usuarios (PUT /api/auth/users/:id)
 * - Eliminar usuarios (DELETE /api/auth/users/:id)
 * - Mantener estado de carga y errores
 * - Notificar cambios a la UI con ChangeNotifier
 * 
 * INTEGRACIÓN CON BACKEND:
 * - Usa ApiService para todas las peticiones HTTP
 * - Requiere token JWT para autenticación
 * - Mapea roles del backend (admin, guia) al frontend
 * 
 * USO:
 * ```dart
 * final usersProvider = Provider.of<UsersProvider>(context);
 * await usersProvider.loadUsersFromBackend();
 * final users = usersProvider.users;
 * ```
 */

// parte linsaith
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

/// Provider de usuarios con integración al backend
class UsersProvider with ChangeNotifier {
  static const _prefsKey = 'users_v1';

  // ====== ESTADO PRIVADO ======
  List<User> _users = []; // Lista de usuarios cargados
  final List<Map<String, dynamic>> _audit =
      []; // Registro de cambios (auditoría)
  final ApiService _apiService = ApiService(); // Cliente HTTP para backend
  bool _isLoading = false; // Estado de carga
  String? _error; // Mensaje de error si falla algo

  // ====== GETTERS PÚBLICOS ======
  List<User> get users => List.unmodifiable(_users); // Lista inmutable para UI
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Constructor - Inicializa con lista vacía
  UsersProvider() {
    _users = [];
  }

  /// Configura el token JWT para peticiones autenticadas
  /// Debe llamarse después del login exitoso
  void setToken(String? token) {
    _apiService.setToken(token);
  }

  /// Carga la lista de usuarios desde el backend
  /// Endpoint: GET /api/auth/users
  ///
  /// Mapea los roles del backend al formato del frontend:
  /// - 'admin'/'administrador' → 'admin'
  /// - 'guia'/'guide' → 'guide'
  /// - otros → 'customer'
  Future<void> loadUsersFromBackend() async {
    _isLoading = true;
    _error = null;

    try {
      // Llamada HTTP al backend
      final usuariosData = await _apiService.getUsers();

      // Transformar datos del backend a objetos User
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

  /// Actualiza el rol de un usuario en el backend
  /// Endpoint: PUT /api/auth/users/:id
  ///
  /// Mapea roles del frontend al ID de rol del backend:
  /// - 'admin' → rol_id: 1
  /// - 'guide' → rol_id: 3
  /// - 'customer' → rol_id: 2
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

      // Llamada HTTP al backend
      await _apiService.updateUser(id, {'rol_id': rolId});

      // Actualizar localmente si la petición fue exitosa
      final idx = _users.indexWhere((u) => u.id == id);
      if (idx >= 0) {
        _users[idx].role = role;
        await _save();

        // Persistir cambio en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole_' + id, role);
        notifyListeners();
      }

      // Recargar desde backend para asegurar sincronización
      await loadUsersFromBackend();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow; // Relanzar error para que la UI pueda manejarlo
    }
  }

  /// Elimina un usuario del sistema
  /// Endpoint: DELETE /api/auth/users/:id
  ///
  /// También registra la acción en el log de auditoría
  /// y recarga la lista desde el backend para sincronizar
  Future<void> deleteUserWithAudit(String id,
      {Map<String, String>? actor}) async {
    try {
      // Llamada HTTP al backend
      await _apiService.deleteUser(id);

      // Actualizar lista local
      _users.removeWhere((u) => u.id == id);

      // Registrar en auditoría
      _audit.insert(0, {
        'action': 'delete_user',
        'userId': id,
        'actor': actor ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _save();
      await _saveAudit();
      notifyListeners();

      // Recargar desde backend para confirmar eliminación
      await loadUsersFromBackend();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
