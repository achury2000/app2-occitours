// parte isa
// parte linsaith
// parte juanjo
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/route.dart';

/// Proveedor para rutas/itinerarios.
///
/// Responsabilidades:
/// - Mantener la colección de `RouteModel` y persistirla en `SharedPreferences`.
/// - Proveer operaciones CRUD, búsqueda y import/export en formato CSV.
///
/// Herencia / Interfaces:
/// - Mezcla `ChangeNotifier` para notificar cambios a la UI.
///
/// Call-sites típicos:
/// - Utilizado por pantallas de gestión de rutas y para construir recorridos en la UI.
class RoutesProvider with ChangeNotifier {
  List<RouteModel> _items = [];
  bool _loading = false;
  static const String _prefsKey = 'routes_v1';

  List<RouteModel> get items => List.unmodifiable(_items);
  bool get loading => _loading;

  Future<void> _ensureLoaded() async {
    if (_items.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _items = RouteModel.decodeList(raw);
      } catch (_) {
        _items = [];
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, RouteModel.encodeList(_items));
  }

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    try {
      await _ensureLoaded();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  RouteModel? findById(String id) => _items.firstWhere((r) => r.id == id, orElse: ()=>throw 'Not found');

  Future<void> addRoute(RouteModel route) async {
    if (route.name.trim().isEmpty) throw Exception('El nombre es obligatorio');
    _items.insert(0, route);
    await _save();
    notifyListeners();
  }

  Future<void> updateRoute(RouteModel route) async {
    final index = _items.indexWhere((r) => r.id == route.id);
    if (index == -1) throw Exception('Ruta no encontrada');
    _items[index] = route;
    await _save();
    notifyListeners();
  }

  Future<void> deleteRoute(String id) async {
    _items.removeWhere((r) => r.id == id);
    await _save();
    notifyListeners();
  }

  // búsqueda básica por nombre o código
  List<RouteModel> search({String? query}) {
    var results = _items;
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((r) => r.name.toLowerCase().contains(q) || r.code.toLowerCase().contains(q)).toList();
    }
    return results;
  }

  String exportCsv() {
    final sb = StringBuffer();
    sb.writeln('id,code,name,description,fincaIds,distanceKm,estimatedMinutes');
    for (final r in _items) {
      sb.writeln([r.id,r.code,_escapeCsv(r.name),_escapeCsv(r.description ?? ''),r.fincaIds.join('|'),r.distanceKm ?? '',r.estimatedMinutes ?? ''].join(','));
    }
    return sb.toString();
  }

  String _escapeCsv(String input) => '"${input.replaceAll('"', '""')}"';

  Future<void> importFromCsv(String csv, {bool replace = false}) async {
    final lines = csv.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return;
    final rows = lines.skip(1);
    final imported = <RouteModel>[];
    for (final r in rows) {
      var cols = _parseCsvLine(r);
        // Recuperación: si el parser combinó campos entrecomillados, intentar recuperar cuando queda un separador '","'
      if (cols.length == 3 && cols[2].contains('\",\"')) {
        final parts = cols[2].split('\",\"');
        final newCols = <String>[];
        newCols.add(cols[0]);
        newCols.add(cols[1]);
        newCols.add(parts[0]);
        final rest = parts.sublist(1).join('\",\"');
        final restCols = rest.split(',');
        newCols.addAll(restCols);
        cols = newCols;
      }
      
      if (cols.length < 1) continue;
      final id = cols.length > 0 ? cols[0] : '';
      final code = cols.length > 1 ? cols[1] : '';
      final name = cols.length > 2 ? cols[2] : '';
      final desc = cols.length > 3 ? cols[3] : null;
      final fincaIds = cols.length > 4 && cols[4].isNotEmpty ? cols[4].split('|') : <String>[];
      final dist = cols.length > 5 && cols[5].isNotEmpty ? double.tryParse(cols[5]) : null;
      final est = cols.length > 6 && cols[6].isNotEmpty ? int.tryParse(cols[6]) : null;
      imported.add(RouteModel(id: id, code: code, name: name, description: desc, fincaIds: fincaIds, distanceKm: dist, estimatedMinutes: est));
    }
    if (replace) _items = imported; else {
      for (final r in imported) {
        final idx = _items.indexWhere((e) => e.id == r.id);
        if (idx == -1) _items.add(r); else _items[idx] = r;
      }
    }
    await _save();
    notifyListeners();
  }

  List<String> _parseCsvLine(String line) {
    // Parser CSV que divide en comas no entrecomilladas.
    // - Usa una expresión regular para respetar comillas dobles.
    // - Devuelve campos descomillados y con comillas dobles internas normalizadas.
    final parts = line.split(RegExp(r',(?=(?:[^"]*"[^"]*")*[^"]*$)'));
    // Recortar y descomillar campos
    return parts.map((p) {
      var s = p.trim();
      if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
        s = s.substring(1, s.length - 1);
      }
      // Replace double double-quotes with a single quote
      s = s.replaceAll('""', '"');
      return s;
    }).toList();
  }
}
