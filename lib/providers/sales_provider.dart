// parte juanjo
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesProvider with ChangeNotifier {
  static const _prefsKey = 'sales_v1';
  final List<Map<String,dynamic>> _sales = [];
  final List<Map<String,dynamic>> _audit = [];

  SalesProvider(){ _load(); }

  List<Map<String,dynamic>> get sales => List.unmodifiable(_sales);
  List<Map<String,dynamic>> get audit => List.unmodifiable(_audit);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _sales.clear();
        _sales.addAll(decoded.map((e) => Map<String,dynamic>.from(e as Map)));
      } catch (_){ }
    }
    final ar = prefs.getString('sales_audit');
    if (ar != null) {
      try {
        final d = jsonDecode(ar) as List<dynamic>;
        _audit.clear();
        _audit.addAll(d.map((e) => Map<String,dynamic>.from(e as Map)));
      } catch (_){ }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_sales));
  }

  Future<void> _saveAudit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sales_audit', jsonEncode(_audit));
  }

  Future<String> addSale(Map<String,dynamic> s, {Map<String,String>? actor}) async {
    final id = 'S${DateTime.now().millisecondsSinceEpoch}';
    final entry = Map<String,dynamic>.from(s);
    entry['id'] = id;
    entry['createdAt'] = entry['createdAt'] ?? DateTime.now().toIso8601String();
    entry['status'] = entry['status'] ?? 'Pendiente';
    _sales.insert(0, entry);
    _audit.insert(0, {'action':'create_sale','saleId': id, 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String(), 'data': entry});
    await _save();
    await _saveAudit();
    notifyListeners();
    return id;
  }

  Map<String,dynamic> getById(String id){
    try { return _sales.firstWhere((s) => s['id'] == id); } catch (_) { return {}; }
  }

  List<Map<String,dynamic>> salesForClient(String clientId){
    return _sales.where((s)=> (s['clientId'] ?? '') == clientId).toList();
  }

  Future<void> updateSale(String id, Map<String,dynamic> changes, {Map<String,String>? actor}) async {
    final idx = _sales.indexWhere((s)=> s['id'] == id);
    if (idx < 0) throw Exception('Venta no encontrada');
    final prev = Map<String,dynamic>.from(_sales[idx]);
    _sales[idx] = {..._sales[idx], ...changes};
    _audit.insert(0, {'action':'update_sale','saleId': id, 'previous': prev, 'new': _sales[idx], 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String()});
    await _save(); await _saveAudit(); notifyListeners();
  }

  Future<void> deleteSale(String id, {Map<String,String>? actor}) async {
    final idx = _sales.indexWhere((s)=> s['id'] == id);
    if (idx < 0) return;
    final removed = _sales.removeAt(idx);
    _audit.insert(0, {'action':'delete_sale','saleId': id, 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String(), 'data': removed});
    await _save(); await _saveAudit(); notifyListeners();
  }

  // simple search with filters
  List<Map<String,dynamic>> search({String? clientId, String? serviceType, String? query, DateTime? from, DateTime? to}){
    Iterable<Map<String,dynamic>> res = _sales;
    if (clientId != null) res = res.where((s)=> (s['clientId'] ?? '') == clientId);
    if (serviceType != null) res = res.where((s)=> (s['serviceType'] ?? '').toString().toLowerCase() == serviceType.toLowerCase());
    if (query != null && query.isNotEmpty) res = res.where((s)=> (s['serviceName'] ?? '').toString().toLowerCase().contains(query.toLowerCase()));
    if (from != null) res = res.where((s){ try{ final d = DateTime.parse(s['createdAt']); return !d.isBefore(from);} catch(_){ return true; }});
    if (to != null) res = res.where((s){ try{ final d = DateTime.parse(s['createdAt']); return !d.isAfter(to);} catch(_){ return true; }});
    return res.toList();
  }
}
