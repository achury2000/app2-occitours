// parte isa
// parte linsaith
// parte juanjo
import 'dart:convert';

/// Modelo que representa una finca (lugar/turístico).
///
/// Responsabilidades:
/// - Contener atributos estáticos de la finca (id, código, nombre, ubicación, precio, imágenes y coordenadas).
/// - Proveer serialización/deserialización `toJson` / `fromJson` y utilidades para encode/decode de listas.
///
/// Notas de implementación:
/// - `fromJson` intenta parsear de manera defensiva campos numéricos y coordenadas (acepta `num`, `String` o `null`).
class Finca {
  final String id;
  final String code;
  final String name;
  final String description;
  final String location;
  final int capacity;
  final double pricePerNight;
  final List<String> images;
  // Geolocalización
  final double? latitude;
  final double? longitude;
  // Servicios disponibles en la finca (ids)
  final List<String> serviceIds;
  final bool active;

  Finca({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.location,
    required this.capacity,
    required this.pricePerNight,
    this.images = const [],
    this.latitude,
    this.longitude,
    this.serviceIds = const [],
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'location': location,
        'capacity': capacity,
        'pricePerNight': pricePerNight,
        'images': images,
        'latitude': latitude,
        'longitude': longitude,
        'serviceIds': serviceIds,
        'active': active,
      };

  factory Finca.fromJson(Map<String, dynamic> map) => Finca(
        id: map['id'] as String,
        code: map['code'] as String? ?? '',
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        location: map['location'] as String? ?? '',
        capacity: map['capacity'] is int ? map['capacity'] as int : int.tryParse('${map['capacity']}') ?? 0,
        pricePerNight: (map['pricePerNight'] is int) ? (map['pricePerNight'] as int).toDouble() : (map['pricePerNight'] as double? ?? 0.0),
        images: (map['images'] as List?)?.map((e) => e as String).toList() ?? [],
        latitude: (map['latitude'] is num) ? (map['latitude'] as num).toDouble() : (map['latitude'] != null ? double.tryParse('${map['latitude']}') : null),
        longitude: (map['longitude'] is num) ? (map['longitude'] as num).toDouble() : (map['longitude'] != null ? double.tryParse('${map['longitude']}') : null),
        serviceIds: (map['serviceIds'] as List?)?.map((e) => e as String).toList() ?? [],
        active: map['active'] as bool? ?? true,
      );

  static String encodeList(List<Finca> items) => json.encode(items.map((e) => e.toJson()).toList());

  static List<Finca> decodeList(String source) {
    final list = json.decode(source) as List<dynamic>;
    return list.map((m) => Finca.fromJson(m as Map<String, dynamic>)).toList();
  }
}
