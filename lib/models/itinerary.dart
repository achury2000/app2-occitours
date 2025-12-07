// parte isa
// parte linsaith
// parte juanjo
import 'dart:convert';
import '../utils/date_utils.dart';

class Itinerary {
  final String id;
  final String title;
  final String? description;
  final List<String> routeIds; // sequence of route IDs
  final List<String> fincaIds; // optional associated fincas
  final int durationMinutes;
  final double price;
  final bool active;
  final DateTime createdAt;

  Itinerary({required this.id, required this.title, this.description, List<String>? routeIds, List<String>? fincaIds, this.durationMinutes = 0, this.price = 0.0, this.active = true, DateTime? createdAt})
    : this.routeIds = routeIds ?? [], this.fincaIds = fincaIds ?? [], this.createdAt = createdAt ?? DateTime.now();

  Map<String,dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description ?? '',
    'routeIds': routeIds,
    'fincaIds': fincaIds,
    'durationMinutes': durationMinutes,
    'price': price,
    'active': active,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Itinerary.fromMap(Map<String,dynamic> m) => Itinerary(
    id: m['id'] as String,
    title: m['title'] as String? ?? '',
    description: m['description'] as String?,
    routeIds: (m['routeIds'] is List) ? List<String>.from(m['routeIds'] as List) : (m['routeIds'] != null ? (m['routeIds'] as String).split(',').map((s)=> s.trim()).where((s)=> s.isNotEmpty).toList() : []),
    fincaIds: (m['fincaIds'] is List) ? List<String>.from(m['fincaIds'] as List) : (m['fincaIds'] != null ? (m['fincaIds'] as String).split(',').map((s)=> s.trim()).where((s)=> s.isNotEmpty).toList() : []),
    durationMinutes: (m['durationMinutes'] is num) ? (m['durationMinutes'] as num).toInt() : int.tryParse('${m['durationMinutes']}') ?? 0,
    price: (m['price'] is num) ? (m['price'] as num).toDouble() : double.tryParse('${m['price']}') ?? 0.0,
    active: m['active'] == null ? true : (m['active'] == true || m['active'] == 'true'),
    createdAt: m['createdAt'] != null ? (parseDateFlexible(m['createdAt']) ?? DateTime.now()) : DateTime.now(),
  );

  static String encodeList(List<Itinerary> items) => json.encode(items.map((e)=> e.toMap()).toList());
  static List<Itinerary> decodeList(String source) { final list = json.decode(source) as List<dynamic>; return list.map((m)=> Itinerary.fromMap(Map<String,dynamic>.from(m as Map))).toList(); }
}
