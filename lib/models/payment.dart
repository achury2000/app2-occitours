// parte linsaith
// parte juanjo
import 'dart:convert';
import '../utils/date_utils.dart';

class Payment {
  final String id;
  final String? reservationId;
  final double amount;
  final String currency;
  final String method; // e.g., 'efectivo', 'tarjeta', 'transferencia'
  final String status; // 'pending','completed','failed','refunded'
  final DateTime timestamp;
  final Map<String,dynamic>? metadata;

  Payment({required this.id, this.reservationId, required this.amount, this.currency = 'COP', this.method = 'efectivo', this.status = 'pending', DateTime? timestamp, this.metadata}) : this.timestamp = timestamp ?? DateTime.now();

  Map<String,dynamic> toMap() => {
    'id': id,
    'reservationId': reservationId,
    'amount': amount,
    'currency': currency,
    'method': method,
    'status': status,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory Payment.fromMap(Map<String,dynamic> m) => Payment(
    id: m['id'] as String,
    reservationId: m['reservationId'] as String?,
    amount: (m['amount'] is num) ? (m['amount'] as num).toDouble() : double.tryParse('${m['amount']}') ?? 0.0,
    currency: m['currency'] as String? ?? 'COP',
    method: m['method'] as String? ?? 'efectivo',
    status: m['status'] as String? ?? 'pending',
    timestamp: m['timestamp'] != null ? (parseDateFlexible(m['timestamp']) ?? DateTime.now()) : DateTime.now(),
    metadata: m['metadata'] != null ? Map<String,dynamic>.from(m['metadata'] as Map) : null,
  );

  static String encodeList(List<Payment> items) => json.encode(items.map((e)=> e.toMap()).toList());
  static List<Payment> decodeList(String source) { final list = json.decode(source) as List<dynamic>; return list.map((m)=> Payment.fromMap(Map<String,dynamic>.from(m as Map))).toList(); }
}
