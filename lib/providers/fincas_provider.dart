// parte isa
// parte linsaith
// parte juanjo
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/finca.dart';

/// Proveedor que gestiona las fincas (CRUD, búsqueda y persistencia).
///
/// Responsabilidades:
/// - Mantener la lista de `Finca` en memoria y sincronizarla con `SharedPreferences`.
/// - Proveer operaciones de creación, actualización, eliminación, búsqueda geográfica y import/export CSV.
/// - Llevar un registro de auditoría (`_audit`) para cambios relevantes.
///
/// Herencia / Interfaces:
/// - Mezcla `ChangeNotifier` para notificar cambios a la UI.
///
/// Call-sites típicos:
/// - Consumido por pantallas de listado, detalle y formularios (ej. `finca_detail_screen.dart`, `fincas_map_screen.dart`).
class FincasProvider with ChangeNotifier {
  List<Finca> _items = [];
  bool _loading = false;
  String? _error;
  static const String _prefsKey = 'fincas_v1';
  static const String _auditKey = 'fincas_audit_v1';

  List<Map<String, dynamic>> _audit = [];

  List<Finca> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;
  List<Map<String, dynamic>> get audit => List.unmodifiable(_audit);

  Future<void> _ensureLoaded() async {
    if (_items.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _items = Finca.decodeList(raw);
      } catch (_) {
        _items = [];
      }
    } else {
      _items = [];
      await _saveToPrefs();
    }

    final auditRaw = prefs.getString(_auditKey);
    if (auditRaw != null && auditRaw.isNotEmpty) {
      try {
        final list = List<dynamic>.from(jsonDecode(auditRaw));
        _audit = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {
        _audit = [];
      }
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, Finca.encodeList(_items));
    await prefs.setString(_auditKey, jsonEncode(_audit));
  }

  Future<void> loadAll() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _ensureLoaded();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Finca? findById(String id) => _items.firstWhere((f) => f.id == id, orElse: ()=>throw 'Not found');

  Future<void> addFinca(Finca finca, {Map<String,String>? actor}) async {
    if (finca.name.trim().isEmpty) throw Exception('El nombre es obligatorio');
    if (finca.code.trim().isEmpty) throw Exception('El código es obligatorio');
    final exists = _items.any((f) => f.name.toLowerCase() == finca.name.toLowerCase());
    if (exists) throw Exception('Ya existe una finca con ese nombre');
    final codeExists = _items.any((f) => f.code.toLowerCase() == finca.code.toLowerCase());
    if (codeExists) throw Exception('Ya existe una finca con ese código');
    _items.insert(0, finca);
    _audit.insert(0, {
      'action': 'create',
      'id': finca.id,
      'data': finca.toJson(),
      'actor': actor,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateFinca(Finca finca, {Map<String,String>? actor, String? reason}) async {
    final index = _items.indexWhere((f) => f.id == finca.id);
    if (index == -1) throw Exception('Finca no encontrada');
    if (finca.name.trim().isEmpty) throw Exception('El nombre es obligatorio');
    if (finca.code.trim().isEmpty) throw Exception('El código es obligatorio');
    final dup = _items.any((f) => f.id != finca.id && f.name.toLowerCase() == finca.name.toLowerCase());
    if (dup) throw Exception('Otra finca ya tiene ese nombre');
    final codeDup = _items.any((f) => f.id != finca.id && f.code.toLowerCase() == finca.code.toLowerCase());
    if (codeDup) throw Exception('Otra finca ya tiene ese código');
    final before = _items[index];
    _items[index] = finca;
    _audit.insert(0, {
      'action': 'update',
      'id': finca.id,
      'before': before.toJson(),
      'after': finca.toJson(),
      'actor': actor,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> deleteFinca(String id, {Map<String,String>? actor, String? reason}) async {
    final removed = _items.firstWhere((f) => f.id == id, orElse: () => throw Exception('Finca no encontrada'));
    _items.removeWhere((f) => f.id == id);
    _audit.insert(0, {
      'action': 'delete',
      'id': id,
      'data': removed.toJson(),
      'actor': actor,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _saveToPrefs();
    notifyListeners();
  }

  // Búsqueda: por texto (name/code) y/o por proximidad (lat/lng + radio en km)
  List<Finca> search({String? query, double? lat, double? lng, double? radiusKm}) {
    var results = _items;
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((f) => f.name.toLowerCase().contains(q) || f.code.toLowerCase().contains(q) || f.description.toLowerCase().contains(q)).toList();
    }
    if (lat != null && lng != null && radiusKm != null) {
      results = results.where((f) {
        if (f.latitude == null || f.longitude == null) return false;
        final d = _distanceKm(lat, lng, f.latitude!, f.longitude!);
        return d <= radiusKm;
      }).toList();
    }
    return results;
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat/2) * math.sin(dLat/2) + math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) * math.sin(dLon/2) * math.sin(dLon/2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
    return earthRadius * c;
  }

  double _toRadians(double deg) => deg * (math.pi / 180);

  // Exportación CSV simple (id,code,name,location,capacity,price,lat,lng,active)
  String exportCsv() {
    final sb = StringBuffer();
    sb.writeln('id,code,name,location,capacity,pricePerNight,latitude,longitude,active');
    for (final f in _items) {
      sb.writeln([f.id,f.code,_escapeCsv(f.name),_escapeCsv(f.location),f.capacity,f.pricePerNight,f.latitude ?? '',f.longitude ?? '',f.active].join(','));
    }
    return sb.toString();
  }

  String _escapeCsv(String input) => '"${input.replaceAll('"', '""')}"';

  Future<void> importFromCsv(String csv, {bool replace = false, Map<String,String>? actor}) async {
    final lines = csv.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return;
    // header row intentionally ignored (we parse columns by position)
    final rows = lines.skip(1);
    final imported = <Finca>[];
    for (final r in rows) {
      final cols = _parseCsvLine(r);
      // Aceptar filas con campos opcionales faltantes; requerimos al menos id, code y name
      if (cols.length < 3) continue;
      final id = cols.length > 0 ? cols[0] : '';
      final code = cols.length > 1 ? cols[1] : '';
      final name = cols.length > 2 ? cols[2] : '';
      final location = cols.length > 3 ? cols[3] : '';
      final capacity = cols.length > 4 ? int.tryParse(cols[4]) ?? 0 : 0;
      final price = cols.length > 5 ? double.tryParse(cols[5]) ?? 0.0 : 0.0;
      final lat = cols.length > 6 && cols[6].isNotEmpty ? double.tryParse(cols[6]) : null;
      final lng = cols.length > 7 && cols[7].isNotEmpty ? double.tryParse(cols[7]) : null;
      final active = cols.length > 8 ? cols[8].toLowerCase() == 'true' : true;
      imported.add(Finca(id: id, code: code, name: name, description: '', location: location, capacity: capacity, pricePerNight: price, images: [], latitude: lat, longitude: lng, serviceIds: [], active: active));
    }
    if (replace) {
      _items = imported;
    } else {
      // upsert by id
      for (final f in imported) {
        final idx = _items.indexWhere((e) => e.id == f.id);
        if (idx == -1) _items.add(f);
        else _items[idx] = f;
      }
    }
    _audit.insert(0, {
      'action': 'import_csv',
      'count': imported.length,
      'actor': actor,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _saveToPrefs();
    notifyListeners();
  }

  List<String> _parseCsvLine(String line) {
    // Parser CSV tolerante:
    // - Soporta campos entrecomillados y comillas escapadas como "".
    // - Intentamos ser lenientes con formatos imperfectos (comillas interiores no exactamente RFC-4180).
    // Uso: utilizado por `importFromCsv` para leer filas de CSV exportadas externamente.
    final result = <String>[];
    var cur = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i+1 < line.length && line[i+1] == '"') {
            // comilla escapada representada como ""
            cur.write('"');
          i++; // skip escaped quote
          continue;
        }
        if (inQuotes) {
            // Si el siguiente caracter es coma o fin de línea, esto cierra la comilla
          final next = i+1 < line.length ? line[i+1] : null;
          if (next == null || next == ',') {
            inQuotes = false;
            continue;
          }
            // En caso contrario tratamos la comilla como carácter literal (modo tolerante)
          cur.write('"');
          continue;
        }
          // apertura de comillas
        inQuotes = true;
        continue;
      }
      if (ch == ',' && !inQuotes) {
        result.add(cur.toString());
        cur = StringBuffer();
        continue;
      }
      cur.write(ch);
    }
    result.add(cur.toString());
    return result;
  }
}
