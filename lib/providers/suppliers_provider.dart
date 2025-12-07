// parte linsaith
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor para proveedores (suppliers).
///
/// - Gestiona información de proveedores, persistencia y auditoría.
class SuppliersProvider with ChangeNotifier {
  static const _prefsKey = 'suppliers_v1';
  final List<Map<String, dynamic>> _suppliers = [];
  final List<Map<String, dynamic>> _audit = [];

  List<Map<String, dynamic>> get suppliers => List.unmodifiable(_suppliers);
  List<Map<String, dynamic>> get audit => List.unmodifiable(_audit);

  SuppliersProvider() { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _suppliers.clear();
        _suppliers.addAll(decoded.map((e) => Map<String, dynamic>.from(e as Map)));
      } catch (_) {}
    }
    final auditRaw = prefs.getString('suppliers_audit');
    if (auditRaw != null) {
      try {
        final decoded = jsonDecode(auditRaw) as List<dynamic>;
        _audit.clear();
        _audit.addAll(decoded.map((e) => Map<String, dynamic>.from(e as Map)));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_suppliers));
  }

  Future<void> _saveAudit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('suppliers_audit', jsonEncode(_audit));
  }

  Map<String,dynamic>? getById(String id) {
    try {
      return Map<String,dynamic>.from(_suppliers.firstWhere((s) => s['id'] == id));
    } catch (_) { return null; }
  }

  bool existsByName(String name, {String? excludeId}) {
    final n = name.trim().toLowerCase();
    return _suppliers.any((s) => (s['name'] ?? '').toString().toLowerCase() == n && (excludeId == null || s['id'] != excludeId));
  }

  Future<String> addSupplier(Map<String,dynamic> s, {Map<String,String>? actor}) async {
    final id = 'S${DateTime.now().millisecondsSinceEpoch}';
    final entry = Map<String,dynamic>.from(s);
    entry['id'] = id;
    _suppliers.insert(0, entry);
    _audit.insert(0, {'action': 'create_supplier', 'supplierId': id, 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String(), 'data': entry});
    await _save();
    await _saveAudit();
    notifyListeners();
    return id;
  }

  Future<void> updateSupplier(String id, Map<String,dynamic> changes, {Map<String,String>? actor}) async {
    final idx = _suppliers.indexWhere((s) => s['id'] == id);
    if (idx < 0) throw Exception('Proveedor no encontrado');
    final prev = Map<String,dynamic>.from(_suppliers[idx]);
    _suppliers[idx].addAll(changes);
    _audit.insert(0, {'action':'update_supplier','supplierId': id, 'previous': prev, 'new': Map<String,dynamic>.from(_suppliers[idx]), 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String()});
    await _save();
    await _saveAudit();
    notifyListeners();
  }

  Future<void> deleteSupplier(String id, {Map<String,String>? actor}) async {
    final idx = _suppliers.indexWhere((s) => s['id'] == id);
    if (idx < 0) return;
    final removed = _suppliers.removeAt(idx);
    _audit.insert(0, {'action':'delete_supplier','supplierId': id, 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String(), 'data': removed});
    await _save();
    await _saveAudit();
    notifyListeners();
  }
}
