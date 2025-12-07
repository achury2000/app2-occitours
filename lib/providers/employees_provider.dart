import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor para gestión de empleados.
///
/// - Carga y persiste una lista simple de empleados en `SharedPreferences`.
/// - Provee operaciones básicas CRUD y notificaciones a la UI.
class EmployeesProvider with ChangeNotifier {
  static const _prefsKey = 'employees';

  List<Map<String, String>> _employees = [];

  EmployeesProvider() {
    loadEmployees();
  }

  List<Map<String, String>> get employees => List.unmodifiable(_employees);

  Future<void> loadEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      _employees = [];
      await _saveToPrefs();
    } else {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _employees = decoded
            .map((e) => Map<String, String>.fromEntries((e as Map).entries.map(
                (kv) => MapEntry(kv.key.toString(),
                    kv.value == null ? '' : kv.value.toString()))))
            .toList();
      } catch (e) {
        _employees = [];
      }
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_employees));
  }

  Future<void> addEmployee(Map<String, String> emp) async {
    final id = 'e${DateTime.now().millisecondsSinceEpoch}';
    final newEmp = Map<String, String>.from(emp);
    newEmp['id'] = id;
    _employees.insert(0, newEmp);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateEmployee(String id, Map<String, String> data) async {
    final idx = _employees.indexWhere((e) => e['id'] == id);
    if (idx >= 0) {
      _employees[idx] = {..._employees[idx], ...data};
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteEmployee(String id) async {
    _employees.removeWhere((e) => e['id'] == id);
    await _saveToPrefs();
    notifyListeners();
  }
}
