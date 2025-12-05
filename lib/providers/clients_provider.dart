// parte juanjo
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor que gestiona los clientes y campañas relacionadas.
///
/// Responsabilidades:
/// - Mantener la lista de clientes, campañas y un registro de auditoría en `SharedPreferences`.
/// - Proveer operaciones CRUD, activación/desactivación, import/export CSV y búsquedas filtradas.
///
/// Herencia / Interfaces:
/// - Mezcla `ChangeNotifier` para notificar cambios a la UI.
///
/// Call-sites típicos:
/// - Consumido por pantallas de clientes, formularios de creación/edición y módulos de campañas.
class ClientsProvider with ChangeNotifier {
  static const _clientsKey = 'clients';
  static const _campaignsKey = 'client_campaigns';
  static const _auditKey = 'clients_audit_v1';

  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _campaigns = [];
  List<Map<String, dynamic>> _audit = [];
  bool _loading = true;

  bool get loading => _loading;

  ClientsProvider({List<Map<String,dynamic>>? initialClients}) {
    if (initialClients != null) {
      _clients = initialClients;
      _loading = false;
      notifyListeners();
    } else {
      _loadAll();
    }
  }

  List<Map<String, dynamic>> get clients => List.unmodifiable(_clients);
  List<Map<String, dynamic>> get campaigns => List.unmodifiable(_campaigns);
  List<Map<String, dynamic>> get audit => List.unmodifiable(_audit);

  Future<void> _loadAll() async {
    _loading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final rawClients = prefs.getString(_clientsKey);
    final rawCampaigns = prefs.getString(_campaignsKey);
    final rawAudit = prefs.getString(_auditKey);
    if (rawClients == null) {
      _clients = [];
      await _saveClients();
    } else {
      try {
        final decoded = jsonDecode(rawClients) as List<dynamic>;
        _clients = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (e) {
        _clients = [];
      }
    }

    if (rawCampaigns == null) {
      _campaigns = [];
      await _saveCampaigns();
    } else {
      try {
        final decoded = jsonDecode(rawCampaigns) as List<dynamic>;
        _campaigns = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (e) {
        _campaigns = [];
      }
    }

    if (rawAudit == null) {
      _audit = [];
      await _saveAudit();
    } else {
      try {
        final decoded = jsonDecode(rawAudit) as List<dynamic>;
        _audit = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (e) {
        _audit = [];
      }
    }

    notifyListeners();
    _loading = false;
    notifyListeners();
  }

  Future<void> _saveClients() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clientsKey, jsonEncode(_clients));
  }

  Future<void> _saveCampaigns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_campaignsKey, jsonEncode(_campaigns));
  }

  Future<void> _saveAudit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_auditKey, jsonEncode(_audit));
  }

  Future<String> addClient(Map<String, dynamic> data, {Map<String,String>? actor}) async {
    final id = 'C${DateTime.now().millisecondsSinceEpoch}';
    final entry = Map<String, dynamic>.from(data);
    entry['id'] = id;
    entry['created'] = entry['created'] ?? DateTime.now().toIso8601String().split('T')[0];
    entry['active'] = entry['active'] ?? true;
    _clients.insert(0, entry);
    _audit.insert(0, {'action':'create_client','clientId': id, 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String(), 'data': entry});
    await _saveClients();
    await _saveAudit();
    notifyListeners();
    return id;
  }

  Future<void> updateClient(String id, Map<String, dynamic> data, {Map<String,String>? actor}) async {
    final idx = _clients.indexWhere((c) => c['id'] == id);
    if (idx >= 0) {
      final prev = Map<String,dynamic>.from(_clients[idx]);
      _clients[idx] = {..._clients[idx], ...data};
      _audit.insert(0, {'action':'update_client','clientId': id, 'previous': prev, 'new': _clients[idx], 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String()});
      await _saveClients();
      await _saveAudit();
      notifyListeners();
    }
  }

  Future<void> deleteClient(String id, {Map<String,String>? actor}) async {
    final removed = _clients.firstWhere((c)=> c['id']==id, orElse: ()=> {});
    _clients.removeWhere((c) => c['id'] == id);
    _audit.insert(0, {'action':'delete_client','clientId': id, 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String(), 'data': removed});
    await _saveClients();
    await _saveAudit();
    notifyListeners();
  }

  Map<String, dynamic>? getById(String id) {
    try {
      return _clients.firstWhere((c) => c['id'] == id);
    } catch (_) {
      return null;
    }
  }

  // Block/unblock
  Future<void> setActive(String id, bool active, {Map<String,String>? actor}) async {
    final idx = _clients.indexWhere((c) => c['id'] == id);
    if (idx < 0) return;
    final prev = Map<String,dynamic>.from(_clients[idx]);
    _clients[idx]['active'] = active;
    _audit.insert(0, {'action': active ? 'activate_client' : 'deactivate_client','clientId': id, 'previous': prev, 'new': _clients[idx], 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String()});
    await _saveClients(); await _saveAudit(); notifyListeners();
  }

  // Búsqueda y filtros
  List<Map<String,dynamic>> searchClients({String? query, bool? active}){
    Iterable<Map<String,dynamic>> res = _clients;
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      res = res.where((c) => ((c['name'] ?? '') as String).toLowerCase().contains(q) || ((c['email'] ?? '') as String).toLowerCase().contains(q) || ((c['phone'] ?? '') as String).toLowerCase().contains(q));
    }
    if (active != null) res = res.where((c) => (c['active'] ?? true) == active);
    return res.toList();
  }

  // Exportación e importación CSV
  String exportCsv(){
    final headers = ['id','name','email','phone','address','active','created'];
    final rows = [_clients.map((c) => headers.map((h) => (c[h] ?? '').toString()).join(','))];
    return [headers.join(','), ...rows].join('\n');
  }

  Future<void> importFromCsv(String csv, {bool replace = false, Map<String,String>? actor}) async {
    final lines = csv.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return;
    final headers = lines.first.split(',').map((s)=> s.trim()).toList();
    final entries = <Map<String,dynamic>>[];
    for (var i=1;i<lines.length;i++){
      final cols = lines[i].split(',');
      final Map<String,dynamic> item = {};
      for (var j=0;j<headers.length && j<cols.length;j++){
        item[headers[j]] = cols[j];
      }
      if (!item.containsKey('id') || (item['id'] == null || (item['id'] as String).isEmpty)) item['id'] = 'C${DateTime.now().millisecondsSinceEpoch}${i}';
      item['active'] = (item['active'] == 'false' || item['active'] == '0') ? false : true;
      entries.add(item);
    }
    if (replace) {
      _clients = entries;
    } else {
      _clients.insertAll(0, entries);
    }
    _audit.insert(0, {'action':'import_clients','count': entries.length, 'actor': actor ?? {}, 'timestamp': DateTime.now().toIso8601String()});
    await _saveClients(); await _saveAudit(); notifyListeners();
  }

  // Utilidades para campañas
  Future<String> addCampaign(Map<String, String> data) async {
    final id = 'CAM${DateTime.now().millisecondsSinceEpoch}';
    final entry = {'id': id, 'title': data['title'] ?? '', 'description': data['description'] ?? '', 'created': DateTime.now().toIso8601String()};
    _campaigns.insert(0, entry);
    await _saveCampaigns();
    notifyListeners();
    return id;
  }

  Future<void> deleteCampaign(String id) async {
    _campaigns.removeWhere((c) => c['id'] == id);
    await _saveCampaigns();
    notifyListeners();
  }
}
