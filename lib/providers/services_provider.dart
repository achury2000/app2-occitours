// parte isa
// parte linsaith
// parte juanjo
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service.dart';

/// Proveedor para servicios ofrecidos por las fincas.
///
/// Responsabilidades:
/// - Gestionar la colección de `Service`, persistir en `SharedPreferences` y mantener un audit trail.
/// - Operaciones CRUD y funciones de import/export CSV.
///
/// Herencia / Interfaces:
/// - Mezcla `ChangeNotifier` para notificar cambios a la UI.
///
/// Call-sites típicos:
/// - Consumido por formularios y pantallas relacionadas con la creación/edición de servicios.
class ServicesProvider with ChangeNotifier {
  static const _prefsKey = 'services_v1';
  final List<Map<String,dynamic>> _audit = [];
  List<Service> _services = [];
  bool _loading = true;

  bool get loading => _loading;

  ServicesProvider(){
    _load();
  }

  List<Service> get services => List.unmodifiable(_services);

  Future<void> _load() async {
    _loading = true; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      _services = [];
      await _save();
    } else {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _services = decoded.map((e) => Service.fromMap(Map<String,dynamic>.from(e as Map))).toList();
      } catch (e) { _services = []; }
    }
    _loading = false; notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_services.map((s)=> s.toMap()).toList()));
  }

  Future<String> addService(Map<String,dynamic> data) async {
    final id = 'S${DateTime.now().millisecondsSinceEpoch}';
    final entry = Service.fromMap({...data, 'id': id});
    _services.insert(0, entry);
    _audit.insert(0, {'action':'create_service','serviceId': id, 'data': entry.toMap(), 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
    return id;
  }

  Future<void> updateService(String id, Map<String,dynamic> data) async {
    final idx = _services.indexWhere((s) => s.id == id);
    if (idx < 0) throw Exception('Servicio no encontrado');
    final prev = _services[idx].toMap();
    final merged = {...prev, ...data};
    _services[idx] = Service.fromMap(merged);
    _audit.insert(0, {'action':'update_service','serviceId': id, 'previous': prev, 'new': _services[idx].toMap(), 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
  }

  Future<void> deleteService(String id) async {
    final idx = _services.indexWhere((s) => s.id == id);
    if (idx < 0) return;
    final removed = _services.removeAt(idx);
    _audit.insert(0, {'action':'delete_service','serviceId': id, 'data': removed.toMap(), 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
  }

  Service? getById(String id) {
    try { return _services.firstWhere((s) => s.id == id); } catch(_) { return null; }
  }

  List<Service> search({String? query, bool? active}){
    Iterable<Service> res = _services;
    if (active != null) res = res.where((s)=> s.active == active);
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      res = res.where((s)=> s.name.toLowerCase().contains(q) || s.description.toLowerCase().contains(q));
    }
    return res.toList();
  }

  String exportCsv(){
    final headers = ['id','name','description','durationMinutes','capacity','price','active'];
    final rows = _services.map((s) => headers.map((h) => (s.toMap()[h] ?? '').toString()).join(',')).toList();
    return [headers.join(','), ...rows].join('\n');
  }

  Future<void> importFromCsv(String csv, {bool replace = false, Map<String,String>? actor}) async {
    final lines = csv.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return;
    final headers = lines.first.split(',').map((s)=> s.trim()).toList();
    final entries = <Service>[];
    for (var i=1;i<lines.length;i++){
      final cols = lines[i].split(',');
      final Map<String,dynamic> map = {};
      for (var j=0;j<headers.length && j<cols.length;j++) map[headers[j]] = cols[j];
      if (map['id'] == null || (map['id'] ?? '').toString().isEmpty) map['id'] = 'S${DateTime.now().millisecondsSinceEpoch}${i}';
      entries.add(Service.fromMap(map));
    }
    if (replace) _services = entries;
    else _services.insertAll(0, entries);
    _audit.insert(0, {'action':'import_services','count': entries.length, 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
  }

  List<Map<String,dynamic>> get audit => List.unmodifiable(_audit);
}
