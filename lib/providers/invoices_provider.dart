// parte linsaith
// parte juanjo
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice.dart';
import 'payments_provider.dart';

/// Proveedor para facturas (invoices).
///
/// - Gestiona facturas, persistencia y auditoría.
/// - Soporta import/export CSV y marcado de estado con integración opcional a `PaymentsProvider`.
class InvoicesProvider with ChangeNotifier {
  static const _prefsKey = 'invoices_v1';
  static const _auditKey = 'invoices_audit_v1';
  List<Invoice> _items = [];
  final List<Map<String,dynamic>> _audit = [];
  bool _loading = true;

  InvoicesProvider(){ _load(); }

  bool get loading => _loading;
  List<Invoice> get items => List.unmodifiable(_items);
  List<Map<String,dynamic>> get audit => List.unmodifiable(_audit);

  Future<void> _load() async {
    _loading = true; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try { _items = Invoice.decodeList(raw); } catch(_) { _items = []; }
    } else { _items = []; await _save(); }
    final auditRaw = prefs.getString(_auditKey);
    if (auditRaw != null && auditRaw.isNotEmpty) {
      try { final decoded = jsonDecode(auditRaw) as List<dynamic>; _audit.clear(); _audit.addAll(decoded.map((e)=> Map<String,dynamic>.from(e as Map))); } catch (_) {}
    }
    _loading = false; notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, Invoice.encodeList(_items));
    await prefs.setString(_auditKey, jsonEncode(_audit));
  }

  Future<String> addInvoice(Invoice inv, {Map<String,String>? actor}) async {
    if (inv.items.isEmpty && inv.total <= 0) throw Exception('Factura sin items o total inválido');
    _items.insert(0, inv);
    _audit.insert(0, {'action':'create_invoice','id': inv.id, 'data': inv.toMap(), 'actor': actor, 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
    return inv.id;
  }

  Future<void> updateInvoice(String id, Invoice updated, {Map<String,String>? actor}) async {
    final idx = _items.indexWhere((e)=> e.id == id);
    if (idx == -1) throw Exception('Factura no encontrada');
    final before = _items[idx].toMap();
    _items[idx] = updated;
    _audit.insert(0, {'action':'update_invoice','id': id, 'before': before, 'after': updated.toMap(), 'actor': actor, 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
  }

  Future<void> deleteInvoice(String id, {Map<String,String>? actor}) async {
    final idx = _items.indexWhere((e)=> e.id == id);
    if (idx == -1) return;
    final removed = _items.removeAt(idx);
    _audit.insert(0, {'action':'delete_invoice','id': id, 'data': removed.toMap(), 'actor': actor, 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
  }

  Invoice? findById(String id){ try{ return _items.firstWhere((e)=> e.id == id);} catch(_) { return null; } }

  List<Invoice> search({String? query}){
    if (query == null || query.trim().isEmpty) return _items;
    final q = query.toLowerCase();
    return _items.where((i) => i.id.toLowerCase().contains(q) || i.reservationIds.any((r)=> r.toLowerCase().contains(q))).toList();
  }

  Future<void> setInvoiceStatus(String id, String status, {String? paymentId, PaymentsProvider? paymentsProvider, Map<String,String>? actor}) async {
    final idx = _items.indexWhere((e)=> e.id == id);
    if (idx == -1) throw Exception('Factura no encontrada');
    final prev = _items[idx].status;
    final inv = _items[idx];
    final updated = Invoice(id: inv.id, reservationIds: inv.reservationIds, items: inv.items, total: inv.total, currency: inv.currency, status: status, paymentId: paymentId, createdAt: inv.createdAt);
    _items[idx] = updated;
    _audit.insert(0, {'action':'set_invoice_status','id': id, 'previous': prev, 'new': status, 'paymentId': paymentId, 'actor': actor, 'timestamp': DateTime.now().toIso8601String()});
    await _save();
    // If paymentId provided and paymentsProvider available, try to mark payment completed
    if (paymentId != null && paymentsProvider != null) {
      try{ await paymentsProvider.updatePayment(paymentId, {'status':'completed'}, actor: actor); } catch(_) {}
    }
    notifyListeners();
  }

  String exportCsv(){
    final headers = ['id','reservationIds','items','total','currency','status','paymentId','createdAt'];
    final rows = _items.map((it) => headers.map((h) => (it.toMap()[h] ?? '').toString()).join(',')).toList();
    return [headers.join(','), ...rows].join('\n');
  }

  Future<void> importFromCsv(String csv, {bool replace = false, Map<String,String>? actor}) async {
    final lines = csv.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return;
    final headers = lines.first.split(',').map((s)=> s.trim()).toList();
    final entries = <Invoice>[];
    for (var i=1;i<lines.length;i++){
      final cols = lines[i].split(',');
      final map = <String,dynamic>{};
      for (var j=0;j<headers.length && j<cols.length;j++) map[headers[j]] = cols[j];
      if (map['id'] == null || (map['id'] as String).isEmpty) map['id'] = 'INV${DateTime.now().millisecondsSinceEpoch}${i}';
      entries.add(Invoice.fromMap(map));
    }
    if (replace) _items = entries; else _items.insertAll(0, entries);
    _audit.insert(0, {'action':'import_invoices','count': entries.length, 'actor': actor, 'timestamp': DateTime.now().toIso8601String()});
    await _save(); notifyListeners();
  }
}
