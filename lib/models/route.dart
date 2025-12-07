// parte isa
// parte linsaith
// parte juanjo
import 'dart:convert';

/// Modelo que representa una ruta/itinerario.
///
/// Responsabilidades:
/// - Contener metadatos sobre una ruta (lista ordenada de `fincaIds`, duración estimada, distancia, coordenadas opcionales).
/// - Proveer serialización/deserialización y utilidades para encode/decode de listas.
///
/// Notas de implementación:
/// - `fromJson` parsea de forma defensiva campos numéricos y coordenadas (acepta `num`, `String` o `null`).
class RouteModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  // Lista de ids de fincas en la ruta, en orden
  final List<String> fincaIds;
  // Coordenadas opcionales para inicio/fin
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;
  final double? distanceKm;
  final int? estimatedMinutes;

  RouteModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.fincaIds = const [],
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    this.distanceKm,
    this.estimatedMinutes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'fincaIds': fincaIds,
        'startLat': startLat,
        'startLng': startLng,
        'endLat': endLat,
        'endLng': endLng,
        'distanceKm': distanceKm,
        'estimatedMinutes': estimatedMinutes,
      };

  factory RouteModel.fromJson(Map<String, dynamic> map) => RouteModel(
        id: map['id'] as String,
        code: map['code'] as String? ?? '',
        name: map['name'] as String? ?? '',
        description: map['description'] as String?,
        fincaIds: (map['fincaIds'] as List?)?.map((e) => e as String).toList() ?? [],
        startLat: (map['startLat'] is num) ? (map['startLat'] as num).toDouble() : (map['startLat'] != null ? double.tryParse('${map['startLat']}') : null),
        startLng: (map['startLng'] is num) ? (map['startLng'] as num).toDouble() : (map['startLng'] != null ? double.tryParse('${map['startLng']}') : null),
        endLat: (map['endLat'] is num) ? (map['endLat'] as num).toDouble() : (map['endLat'] != null ? double.tryParse('${map['endLat']}') : null),
        endLng: (map['endLng'] is num) ? (map['endLng'] as num).toDouble() : (map['endLng'] != null ? double.tryParse('${map['endLng']}') : null),
        distanceKm: (map['distanceKm'] is num) ? (map['distanceKm'] as num).toDouble() : (map['distanceKm'] != null ? double.tryParse('${map['distanceKm']}') : null),
        estimatedMinutes: map['estimatedMinutes'] is int ? map['estimatedMinutes'] as int : (map['estimatedMinutes'] != null ? int.tryParse('${map['estimatedMinutes']}') : null),
      );

  static String encodeList(List<RouteModel> items) => json.encode(items.map((e) => e.toJson()).toList());

  static List<RouteModel> decodeList(String source) {
    final list = json.decode(source) as List<dynamic>;
    return list.map((m) => RouteModel.fromJson(m as Map<String, dynamic>)).toList();
  }
}
