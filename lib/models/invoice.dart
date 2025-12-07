// parte linsaith
// parte juanjo
import 'dart:convert';
import '../utils/date_utils.dart';

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  InvoiceItem({required this.description, this.quantity = 1, this.unitPrice = 0.0});

  Map<String,dynamic> toMap() => {'description': description, 'quantity': quantity, 'unitPrice': unitPrice};
  factory InvoiceItem.fromMap(Map<String,dynamic> m) => InvoiceItem(description: m['description'] ?? '', quantity: (m['quantity'] is num) ? (m['quantity'] as num).toInt() : int.tryParse('${m['quantity']}') ?? 1, unitPrice: (m['unitPrice'] is num) ? (m['unitPrice'] as num).toDouble() : double.tryParse('${m['unitPrice']}') ?? 0.0);
}

class Invoice {
  final String id;
  final List<String> reservationIds;
  final List<InvoiceItem> items;
  final double total;
  final String currency;
  final String status; // draft, issued, paid, cancelled
  final String? paymentId;
  final DateTime createdAt;

  Invoice({required this.id, List<String>? reservationIds, List<InvoiceItem>? items, this.total = 0.0, this.currency = 'USD', this.status = 'draft', this.paymentId, DateTime? createdAt})
    : this.reservationIds = reservationIds ?? [], this.items = items ?? [], this.createdAt = createdAt ?? DateTime.now();

  Map<String,dynamic> toMap() => {
    'id': id,
    'reservationIds': reservationIds,
    'items': items.map((i)=> i.toMap()).toList(),
    'total': total,
    'currency': currency,
    'status': status,
    'paymentId': paymentId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Invoice.fromMap(Map<String,dynamic> m) => Invoice(
    id: m['id'] as String,
    reservationIds: (m['reservationIds'] is List) ? List<String>.from(m['reservationIds'] as List) : (m['reservationIds'] != null ? (m['reservationIds'] as String).split(',').map((s)=> s.trim()).where((s)=> s.isNotEmpty).toList() : []),
    items: (m['items'] is List) ? (m['items'] as List).map((e)=> InvoiceItem.fromMap(Map<String,dynamic>.from(e as Map))).toList() : [],
    total: (m['total'] is num) ? (m['total'] as num).toDouble() : double.tryParse('${m['total']}') ?? 0.0,
    currency: m['currency'] as String? ?? 'USD',
    status: m['status'] as String? ?? 'draft',
    paymentId: m['paymentId'] as String?,
    createdAt: m['createdAt'] != null ? (parseDateFlexible(m['createdAt']) ?? DateTime.now()) : DateTime.now(),
  );

  static String encodeList(List<Invoice> items) => json.encode(items.map((e)=> e.toMap()).toList());
  static List<Invoice> decodeList(String source) { final list = json.decode(source) as List<dynamic>; return list.map((m)=> Invoice.fromMap(Map<String,dynamic>.from(m as Map))).toList(); }
}
