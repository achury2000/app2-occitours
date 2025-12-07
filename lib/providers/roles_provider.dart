// parte linsaith
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor para roles y permisos del sistema.
///
/// - Mantiene roles con sus permisos, activa/desactiva roles y registra auditoría.
class RolesProvider with ChangeNotifier {
  static const _prefsKey = 'roles';

  List<Map<String, dynamic>> _roles = [];
  final List<Map<String, dynamic>> _audit = [];

  List<Map<String, dynamic>> get roles => List.unmodifiable(_roles);

  RolesProvider() {
    loadRoles();
  }

  Future<void> loadRoles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      _roles = [];
      await _saveToPrefs();
    } else {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _roles =
            decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (e) {
        _roles = [];
      }
    }
    // load audit log if present
    final auditRaw = prefs.getString('roles_audit');
    if (auditRaw != null) {
      try {
        final decoded = jsonDecode(auditRaw) as List<dynamic>;
        _audit.clear();
        _audit.addAll(decoded.map((e) => Map<String, dynamic>.from(e as Map)));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_roles));
  }

  Future<void> _saveAuditToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('roles_audit', jsonEncode(_audit));
  }

  Future<void> addRole(Map<String, dynamic> role) async {
    final id = 'r${DateTime.now().millisecondsSinceEpoch}';
    final newRole = Map<String, dynamic>.from(role);
    newRole['id'] = id;
    _roles.insert(0, newRole);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateRole(String id, Map<String, dynamic> data) async {
    final idx = _roles.indexWhere((r) => r['id'] == id);
    if (idx >= 0) {
      _roles[idx] = {..._roles[idx], ...data};
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteRole(String id) async {
    _roles.removeWhere((r) => r['id'] == id);
    await _saveToPrefs();
    notifyListeners();
  }

  // toggle active with audit entry (actor may be null for system)
  Future<void> toggleActiveWithAudit(String id,
      {Map<String, String>? actor, String? comment}) async {
    final idx = _roles.indexWhere((r) => r['id'] == id);
    if (idx >= 0) {
      _roles[idx]['active'] = !(_roles[idx]['active'] as bool);
      _audit.insert(0, {
        'action': 'toggle_active',
        'roleId': id,
        'newValue': _roles[idx]['active'],
        'actor': actor ?? {},
        'comment': comment ?? '',
        'timestamp': DateTime.now().toIso8601String()
      });
      await _saveToPrefs();
      await _saveAuditToPrefs();
      notifyListeners();
    }
  }

  Future<void> setPermissions(String id, List<String> permissions,
      {Map<String, String>? actor, String? comment}) async {
    final idx = _roles.indexWhere((r) => r['id'] == id);
    if (idx >= 0) {
      _roles[idx]['permissions'] = permissions;
      _audit.insert(0, {
        'action': 'set_permissions',
        'roleId': id,
        'permissions': permissions,
        'actor': actor ?? {},
        'comment': comment ?? '',
        'timestamp': DateTime.now().toIso8601String()
      });
      await _saveToPrefs();
      await _saveAuditToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteRoleWithAudit(String id,
      {Map<String, String>? actor, String? comment}) async {
    _roles.removeWhere((r) => r['id'] == id);
    _audit.insert(0, {
      'action': 'delete_role',
      'roleId': id,
      'actor': actor ?? {},
      'comment': comment ?? '',
      'timestamp': DateTime.now().toIso8601String()
    });
    await _saveToPrefs();
    await _saveAuditToPrefs();
    notifyListeners();
  }

  List<Map<String, dynamic>> get audit => List.unmodifiable(_audit);
}
