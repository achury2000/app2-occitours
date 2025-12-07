// parte linsaith
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor para compras (ordenes de compra).
///
/// - Mantiene órdenes de compra, persiste en `SharedPreferences` y registra auditoría.
class PurchasesProvider with ChangeNotifier {
  static const _prefsKey = 'purchases_v1';
  final List<Map<String,dynamic>> _purchases = [];
  final List<Map<String,dynamic>> _audit = [];

  PurchasesProvider(){ _load(); }

  List<Map<String,dynamic>> get purchases => List.unmodifiable(_purchases);
  List<Map<String,dynamic>> get audit => List.unmodifiable(_audit);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _purchases.clear();
        _purchases.addAll(decoded.map((e) => Map<String,dynamic>.from(e as Map)));
      } catch(_){}
    }
    final auditRaw = prefs.getString('purchases_audit');
    if (auditRaw != null) {
      try {
        final decoded = jsonDecode(auditRaw) as List<dynamic>;
        _audit.clear();
        _audit.addAll(decoded.map((e) => Map<String,dynamic>.from(e as Map)));
      } catch(_){}
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_purchases));
  }

  Future<void> _saveAudit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('purchases_audit', jsonEncode(_audit));
  }

  Future<String> addPurchase(Map<String,dynamic> p, {Map<String,String>? actor}) async {
    final id = 'PO${DateTime.now().millisecondsSinceEpoch}';
    final entry = Map<String,dynamic>.from(p);
    entry['id'] = id;
    entry['status'] = entry['status'] ?? 'Pendiente';
    _purchases.insert(0, entry);
    _audit.insert(0, {'action':'create_purchase','purchaseId': id, 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String(), 'data': entry});
    await _save();
    await _saveAudit();
    notifyListeners();
    return id;
  }

  Future<void> setPurchaseStatus(String id, String status, {Map<String,String>? actor}) async {
    final idx = _purchases.indexWhere((p) => p['id'] == id);
    if (idx < 0) throw Exception('Compra no encontrada');
    final prev = _purchases[idx]['status'];
    _purchases[idx]['status'] = status;
    _audit.insert(0, {'action':'set_purchase_status','purchaseId': id, 'previous': prev, 'new': status, 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String()});
    await _save();
    await _saveAudit();
    notifyListeners();
  }

  Future<void> deletePurchase(String id, {Map<String,String>? actor}) async {
    final idx = _purchases.indexWhere((p) => p['id'] == id);
    if (idx < 0) return;
    final removed = _purchases.removeAt(idx);
    _audit.insert(0, {'action':'delete_purchase','purchaseId': id, 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String(), 'data': removed});
    await _save();
    await _saveAudit();
    notifyListeners();
  }
}
