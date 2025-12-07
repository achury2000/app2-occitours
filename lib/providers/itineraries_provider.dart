// parte isa
// parte linsaith
// parte juanjo
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/itinerary.dart';

/// Proveedor para gestionar itinerarios.
///
/// - Persiste la lista de itinerarios en `SharedPreferences` usando la clave
///   `_prefsKey` y guarda un registro de auditoría en `_auditKey`.
/// - Provee operaciones CRUD, import/export CSV y la creación de
///   reservaciones a partir de un itinerario.
class ItinerariesProvider with ChangeNotifier {
  static const _prefsKey = 'itineraries_v1';
  static const _auditKey = 'itineraries_audit_v1';
  List<Itinerary> _items = [];
  final List<Map<String,dynamic>> _audit = [];
  bool _loading = true;

  ItinerariesProvider(){ _load(); }

  bool get loading => _loading;
  List<Itinerary> get items => List.unmodifiable(_items);
  List<Map<String,dynamic>> get audit => List.unmodifiable(_audit);

  Future<void> _load() async {
    _loading = true; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try { _items = Itinerary.decodeList(raw); } catch(_) { _items = []; }
    } else { _items = []; await _save(); }
    final auditRaw = prefs.getString(_auditKey);
    if (auditRaw != null && auditRaw.isNotEmpty) {
      try { final decoded = jsonDecode(auditRaw) as List<dynamic>; _audit.clear(); _audit.addAll(decoded.map((e)=> Map<String,dynamic>.from(e as Map))); } catch (_) {}
    }
    _loading = false; notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, Itinerary.encodeList(_items));
    await prefs.setString(_auditKey, jsonEncode(_audit));
  }

  Future<String> addItinerary(Itinerary it, {Map<String,String>? actor}) async {
    if (it.title.trim().isEmpty) throw Exception('Título requerido');
    _items.insert(0, it);
    _audit.insert(0, {'action':'create_itinerary','id': it.id, 'data': it.toMap(), 'actor': actor, 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
    return it.id;
  }

  Future<void> updateItinerary(String id, Itinerary updated, {Map<String,String>? actor}) async {
    final idx = _items.indexWhere((e)=> e.id == id);
    if (idx == -1) throw Exception('Itinerario no encontrado');
    final before = _items[idx].toMap();
    _items[idx] = updated;
    _audit.insert(0, {'action':'update_itinerary','id': id, 'before': before, 'after': updated.toMap(), 'actor': actor, 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
  }

  Future<void> deleteItinerary(String id, {Map<String,String>? actor}) async {
    final idx = _items.indexWhere((e)=> e.id == id);
    if (idx == -1) return;
    final removed = _items.removeAt(idx);
    _audit.insert(0, {'action':'delete_itinerary','id': id, 'data': removed.toMap(), 'actor': actor, 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
  }

  Itinerary? findById(String id){ try{ return _items.firstWhere((e)=> e.id == id);} catch(_) { return null; } }

  List<Itinerary> search({String? query}){
    if (query == null || query.trim().isEmpty) return _items;
    final q = query.toLowerCase();
    return _items.where((i) => i.title.toLowerCase().contains(q) || (i.description ?? '').toLowerCase().contains(q)).toList();
  }

  String exportCsv(){
    final headers = ['id','title','description','routeIds','fincaIds','durationMinutes','price','active','createdAt'];
    final rows = _items.map((it) => headers.map((h) => (it.toMap()[h] ?? '').toString()).join(',')).toList();
    return [headers.join(','), ...rows].join('\n');
  }

  Future<void> importFromCsv(String csv, {bool replace = false, Map<String,String>? actor}) async {
    final lines = csv.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return;
    final headers = lines.first.split(',').map((s)=> s.trim()).toList();
    final entries = <Itinerary>[];
    for (var i=1;i<lines.length;i++){
      final cols = lines[i].split(',');
      final map = <String,dynamic>{};
      for (var j=0;j<headers.length && j<cols.length;j++) map[headers[j]] = cols[j];
      if (map['id'] == null || (map['id'] as String).isEmpty) map['id'] = 'IT${DateTime.now().millisecondsSinceEpoch}${i}';
      entries.add(Itinerary.fromMap(map));
    }
    if (replace) _items = entries; else _items.insertAll(0, entries);
    _audit.insert(0, {'action':'import_itineraries','count': entries.length, 'actor': actor, 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
  }

  // Convierte un itinerario en reservaciones usando el ReservationsProvider
  // provisto. Retorna un mapa con resultados por elemento: {routeId: reservationId
  // o un mapa con clave 'error' en caso de fallo}.
  Future<Map<String,dynamic>> createReservationsFromItinerary(String itineraryId, {required DateTime date, required String time, required String clientId, required dynamic reservationsProvider, Map<String,String>? actor}) async {
    final it = findById(itineraryId);
    if (it == null) throw Exception('Itinerario no encontrado');
    final results = <String,dynamic>{};
    for (final routeId in it.routeIds){
      try{
        final data = {'service': routeId, 'date': date.toIso8601String().split('T').first, 'time': time, 'clientId': clientId, 'status': 'Activa'};
        final resId = await reservationsProvider.addReservation(data);
        results[routeId] = resId;
      } catch(e){ results[routeId] = {'error': e.toString()}; }
    }
    _audit.insert(0, {'action':'create_reservations_from_itinerary','itineraryId': itineraryId, 'results': results, 'actor': actor, 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
    return results;
  }
}
