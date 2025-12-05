// parte linsaith
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

enum ProductSort { priceAsc, priceDesc, nameAsc, popularity }

/// Proveedor de productos y gestión de catálogo.
///
/// Responsabilidades:
/// - Cargar/guardar productos en `SharedPreferences`.
/// - Índice en memoria para búsquedas rápidas, paginación y control de stock.
/// - Import/Export CSV y registro histórico de stock.
class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];
  List<Product> _allItems = [];
  bool _loading = false;
  String? _error;
  // In-memory inverted index: token -> set of product ids
  final Map<String, Set<String>> _index = {};

  // paginación simple
  int _page = 0;
  final int _pageSize = 6;

  static const String _prefsKey = 'products_v1';
  static const String _stockHistoryKey = 'stock_history_v1';
  static const String _reorderLevelsKey = 'reorder_levels_v1';
  static const int _defaultReorderLevel = 5;

  final Map<String, List<Map<String,dynamic>>> _stockHistory = {};
  final Map<String, int> _reorderLevels = {};

  List<Product> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> _ensureLoaded() async {
    if (_items.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _allItems = Product.decodeList(raw);
      } catch (_) {
        _allItems = [];
      }
    } else {
      _allItems = [];
      await _saveToPrefs();
    }
    // load stock history
    final shRaw = prefs.getString(_stockHistoryKey);
    if (shRaw != null && shRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(shRaw) as Map<String,dynamic>;
        _stockHistory.clear();
        decoded.forEach((k,v){ _stockHistory[k] = List<Map<String,dynamic>>.from((v as List).map((e)=> Map<String,dynamic>.from(e as Map))); });
      } catch(_){ }
    }
    // load reorder levels
    final rlRaw = prefs.getString(_reorderLevelsKey);
    if (rlRaw != null && rlRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(rlRaw) as Map<String,dynamic>;
        _reorderLevels.clear();
        decoded.forEach((k,v){ _reorderLevels[k] = (v as num).toInt(); });
      } catch(_){ }
    }
    // build search index after loading
    _rebuildIndex();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, Product.encodeList(_allItems));
  }

  Future<void> _saveStockHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final enc = jsonEncode(_stockHistory);
    await prefs.setString(_stockHistoryKey, enc);
  }

  Future<void> _saveReorderLevels() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reorderLevelsKey, jsonEncode(_reorderLevels));
  }

  Future<void> loadInitial({String? category, String? query, ProductSort? sort}) async {
    _loading = true;
    _error = null;
    _page = 0;
    notifyListeners();
    try {
      await _ensureLoaded();

      List<Product> results = List.from(_allItems);
      if (query != null && query.isNotEmpty) {
        // use optimized search if index available
        final found = _searchByQuery(query);
        results = _allItems.where((p) => found.contains(p.id)).toList();
      }
      if (category != null) results = results.where((p) => p.category == category).toList();
      if (sort != null) {
        switch (sort) {
          case ProductSort.priceAsc:
            results.sort((a,b)=>a.price.compareTo(b.price));
            break;
          case ProductSort.priceDesc:
            results.sort((a,b)=>b.price.compareTo(a.price));
            break;
          case ProductSort.nameAsc:
            results.sort((a,b)=>a.name.compareTo(b.name));
            break;
          case ProductSort.popularity:
            results.sort((a,b)=>b.popularity.compareTo(a.popularity));
            break;
        }
      }
      _items = results.take(_pageSize).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    try {
      await _ensureLoaded();
      await Future.delayed(Duration(milliseconds: 300));
      _page++;
      final start = _page * _pageSize;
      final List<Product> next = (_allItems.length > start) ? _allItems.skip(start).take(_pageSize).toList() : <Product>[];
      _items.addAll(next);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Product? findById(String id) => _allItems.firstWhere((p) => p.id == id, orElse: ()=>throw 'Not found');

  // --- Search/index helpers ---
  void _rebuildIndex(){
    _index.clear();
    for (final p in _allItems){
      final tokens = _tokenize('${p.name} ${p.code}');
      for (final t in tokens){
        _index.putIfAbsent(t, ()=> <String>{}).add(p.id);
      }
    }
  }

  Set<String> _searchByQuery(String query){
    final tokens = _tokenize(query);
    if (tokens.isEmpty) return _allItems.map((e)=>e.id).toSet();
    Set<String>? result;
    for (final t in tokens){
      final ids = _index[t] ?? <String>{};
      if (result == null) result = Set<String>.from(ids);
      else result = result.intersection(ids);
      if (result.isEmpty) break;
    }
    return result ?? <String>{};
  }

  List<String> _tokenize(String text){
    return text
        .toLowerCase()
        .split(RegExp(r"[^a-z0-9]+"))
        .where((s)=> s.isNotEmpty)
        .toList();
  }

  // CRUD operations
  Future<void> addProduct(Product product) async {
    if (product.name.trim().isEmpty) throw Exception('El nombre es obligatorio');
    if (product.code.trim().isEmpty) throw Exception('El código es obligatorio');
    final exists = _allItems.any((p) => p.name.toLowerCase() == product.name.toLowerCase());
    if (exists) throw Exception('Ya existe un servicio con ese nombre');
    final codeExists = _allItems.any((p) => p.code.toLowerCase() == product.code.toLowerCase());
    if (codeExists) throw Exception('Ya existe un servicio con ese código');
    _allItems.insert(0, product);
    await _saveToPrefs();
    _rebuildIndex();
    _items = _allItems.take((_page + 1) * _pageSize).toList();
    notifyListeners();
  }

  Future<void> updateProduct(Product product, {String? reason, Map<String,String>? actor}) async {
    final index = _allItems.indexWhere((p) => p.id == product.id);
    if (index == -1) throw Exception('Producto no encontrado');
    if (product.name.trim().isEmpty) throw Exception('El nombre es obligatorio');
    if (product.code.trim().isEmpty) throw Exception('El código es obligatorio');
    final dup = _allItems.any((p) => p.id != product.id && p.name.toLowerCase() == product.name.toLowerCase());
    if (dup) throw Exception('Otro servicio ya tiene ese nombre');
    final codeDup = _allItems.any((p) => p.id != product.id && p.code.toLowerCase() == product.code.toLowerCase());
    if (codeDup) throw Exception('Otro servicio ya tiene ese código');
    // if stock changed, register history
    final prevStock = _allItems[index].stock;
    _allItems[index] = product;
    await _saveToPrefs();
    if (product.stock != prevStock) {
      final entry = {'productId': product.id, 'timestamp': DateTime.now().toIso8601String(), 'previous': prevStock, 'new': product.stock, 'reason': reason ?? 'manual', 'actor': actor ?? {}};
      _stockHistory.putIfAbsent(product.id, ()=>[]).insert(0, entry);
      await _saveStockHistory();
    }
    _rebuildIndex();
    _items = _allItems.take((_page + 1) * _pageSize).toList();
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    _allItems.removeWhere((p) => p.id == id);
    await _saveToPrefs();
    _stockHistory.remove(id);
    await _saveStockHistory();
    _rebuildIndex();
    _items = _allItems.take((_page + 1) * _pageSize).toList();
    notifyListeners();
  }

  // Stock history API
  List<Map<String,dynamic>> stockHistoryFor(String productId) => List.unmodifiable(_stockHistory[productId] ?? []);

  // reorder level per product
  int reorderLevelFor(String productId) => _reorderLevels[productId] ?? _defaultReorderLevel;
  Future<void> setReorderLevel(String productId, int level) async {
    _reorderLevels[productId] = level;
    await _saveReorderLevels();
    notifyListeners();
  }

  // Low stock items
  List<Product> lowStockItems() {
    return _allItems.where((p) => p.stock <= reorderLevelFor(p.id)).toList();
  }

  // CSV export/import (simple: id,code,name,category,price,stock)
  String exportCsv() {
    final sb = StringBuffer();
    sb.writeln('id,code,name,category,price,stock');
    for (final p in _allItems) {
      final line = '${p.id},${_escape(p.code)},${_escape(p.name)},${_escape(p.category)},${p.price},${p.stock}';
      sb.writeln(line);
    }
    return sb.toString();
  }

  Future<void> importFromCsv(String csv, {bool updateExisting = true}) async {
    final lines = LineSplitter.split(csv).toList();
    if (lines.length <= 1) return;
    for (int i=1;i<lines.length;i++) {
      final row = lines[i].trim();
      if (row.isEmpty) continue;
      // simple split by comma, no advanced parsing
      final parts = row.split(',');
      if (parts.length < 6) continue;
      final id = parts[0].trim();
      final code = parts[1].trim();
      final name = parts[2].trim();
      final category = parts[3].trim();
      final price = double.tryParse(parts[4].trim()) ?? 0.0;
      final stock = int.tryParse(parts[5].trim()) ?? 0;
      final existingIndex = _allItems.indexWhere((p) => p.id == id || p.code == code);
      final prod = Product(id: id, code: code, name: name, description: '', price: price, imageUrl: '', category: category, stock: stock, variants: [], popularity: 0);
      if (existingIndex >= 0) {
        if (updateExisting) {
          _allItems[existingIndex] = prod;
        }
      } else {
        _allItems.insert(0, prod);
      }
    }
    await _saveToPrefs();
    _rebuildIndex();
    _items = _allItems.take((_page + 1) * _pageSize).toList();
    notifyListeners();
  }

  String _escape(String s){
    if (s.contains(',') || s.contains('"')) return '"${s.replaceAll('"', '""')}"';
    return s;
  }
}
