// parte linsaith
// parte juanjo
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';

/// Proveedor para opiniones/reseñas (reviews).
///
/// Responsabilidades:
/// - Almacenar y recuperar `Review` desde `SharedPreferences`.
/// - Proveer operaciones CRUD y búsqueda filtrada por objetivo o puntuación.
///
/// Herencia / Interfaces:
/// - Mezcla `ChangeNotifier` para notificar a la UI cuando cambian las reseñas.
///
/// Call-sites típicos:
/// - Utilizado por pantallas que muestran o permiten añadir reseñas para fincas, rutas o servicios.
class ReviewsProvider with ChangeNotifier {
  static const _prefsKey = 'reviews_v1';
  List<Review> _items = [];
  bool _loading = true;

  ReviewsProvider(){ _load(); }

  bool get loading => _loading;
  List<Review> get items => List.unmodifiable(_items);

  Future<void> _load() async {
    _loading = true; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try { _items = Review.decodeList(raw); } catch(_) { _items = []; }
    } else {
      _items = [];
      await _save();
    }
    _loading = false; notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, Review.encodeList(_items));
  }

  Future<String> addReview(Review r) async {
    _items.insert(0, r);
    await _save(); notifyListeners();
    return r.id;
  }

  Future<void> updateReview(String id, Review updated) async {
    final idx = _items.indexWhere((e)=> e.id == id);
    if (idx == -1) throw Exception('Review no encontrada');
    _items[idx] = updated;
    await _save(); notifyListeners();
  }

  Future<void> deleteReview(String id) async {
    final idx = _items.indexWhere((e)=> e.id == id);
    if (idx == -1) return;
    _items.removeAt(idx);
    await _save(); notifyListeners();
  }

  Review? findById(String id){ try{ return _items.firstWhere((e)=> e.id == id);} catch(_) { return null; } }

  List<Review> search({String? targetId, String? targetType, int? minRating}){
    Iterable<Review> res = _items;
    if (targetId != null && targetId.isNotEmpty) res = res.where((r)=> r.targetId == targetId);
    if (targetType != null && targetType.isNotEmpty) res = res.where((r)=> r.targetType == targetType);
    if (minRating != null) res = res.where((r)=> r.rating >= minRating);
    return res.toList();
  }
}
