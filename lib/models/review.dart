// parte linsaith
// parte juanjo
import 'dart:convert';
import '../utils/date_utils.dart';

/// Modelo que representa una reseña (review) realizada por un usuario.
///
/// Responsabilidades:
/// - Contener metadatos de la reseña (objetivo, autor, puntuación, comentario y timestamp).
/// - Serialización/Deserialización desde mapas; `fromMap` usa `parseDateFlexible` para aceptar múltiples formatos de fecha.
///
/// Call-sites típicos:
/// - Creación desde UI cuando un usuario deja una reseña y lectura para mostrar listados de valoraciones.
class Review {
  final String id;
  final String targetId; // id de finca o servicio
  final String targetType; // 'finca' | 'service'
  final String authorId;
  final int rating; // 1..5
  final String? comment;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Review({required this.id, required this.targetId, required this.targetType, required this.authorId, required this.rating, this.comment, DateTime? timestamp, this.metadata}) : this.timestamp = timestamp ?? DateTime.now();

  Map<String,dynamic> toMap() => {
    'id': id,
    'targetId': targetId,
    'targetType': targetType,
    'authorId': authorId,
    'rating': rating,
    'comment': comment,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory Review.fromMap(Map<String,dynamic> m) => Review(
    id: m['id'] as String,
    targetId: m['targetId'] as String,
    targetType: m['targetType'] as String,
    authorId: m['authorId'] as String,
    rating: (m['rating'] is num) ? (m['rating'] as num).toInt() : int.tryParse('${m['rating']}') ?? 0,
    comment: m['comment'] as String?,
    timestamp: m['timestamp'] != null ? (parseDateFlexible(m['timestamp']) ?? DateTime.now()) : DateTime.now(),
    metadata: m['metadata'] != null ? Map<String,dynamic>.from(m['metadata'] as Map) : null,
  );

  static String encodeList(List<Review> items) => json.encode(items.map((e)=> e.toMap()).toList());
  static List<Review> decodeList(String source) { final list = json.decode(source) as List<dynamic>; return list.map((m)=> Review.fromMap(Map<String,dynamic>.from(m as Map))).toList(); }
}
