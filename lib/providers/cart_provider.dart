import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// Proveedor que gestiona el carrito de compras.
///
/// - Añade, elimina y actualiza cantidades de productos en el carrito.
/// - Soporta variantes opcionales por producto y un sistema simple de cupones.
/// - Persiste el estado en `SharedPreferences` bajo la clave `cart`.
class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  CartProvider(){
    _loadCart();
  }

  List<CartItem> get items => List.unmodifiable(_items);

  // Agrega un producto al carrito. `variant` es opcional y distingue variantes del mismo producto.
  void addProduct(Product p, {int qty = 1, String? variant}){
    final idx = _items.indexWhere((c) => c.product.id == p.id && c.selectedVariant == variant);
    if(idx>=0){
      _items[idx].quantity += qty;
    } else {
      _items.add(CartItem(product: p, quantity: qty, selectedVariant: variant));
    }
    notifyListeners();
    _saveCart();
  }

  void removeProduct(String productId, {String? variant}){
    _items.removeWhere((c)=> c.product.id==productId && c.selectedVariant==variant);
    notifyListeners();
    _saveCart();
  }

  void updateQuantity(String productId, int qty, {String? variant}){
    final idx = _items.indexWhere((c)=> c.product.id==productId && c.selectedVariant==variant);
    if(idx>=0){
      _items[idx].quantity = qty;
      if(_items[idx].quantity<=0) _items.removeAt(idx);
      notifyListeners();
      _saveCart();
    }
  }

  double get subtotal => _items.fold(0, (s, c) => s + c.product.price * c.quantity);

  double get shipping => _items.isEmpty ? 0 : 15000; // simplified

  double get total => subtotal + shipping - _couponValue;

  // simple coupon system
  String? _couponCode;
  double _couponValue = 0;

  String? get couponCode => _couponCode;
  double get couponValue => _couponValue;

  bool applyCoupon(String code){
    // simulated coupons
    if (code=='DESC10'){
      _couponCode = code;
      _couponValue = subtotal * 0.10;
      _saveCart();
      notifyListeners();
      return true;
    }
    if (code=='FREESHIP'){
      _couponCode = code;
      _couponValue = shipping;
      _saveCart();
      notifyListeners();
      return true;
    }
    return false;
  }

  double get discount => _couponValue;

  void clear(){
    _items.clear();
    notifyListeners();
    _saveCart();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.map((c)=>{'id': c.product.id, 'qty': c.quantity, 'variant': c.selectedVariant}).toList();
    await prefs.setString('cart', jsonEncode(data));
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cart');
    if(raw==null) return;
    try {
      // TODO: Cargar productos desde backend/ProductsProvider en lugar de datos mock
      // final List decoded = jsonDecode(raw) as List;
      // _items.clear();
      // for(final e in decoded){
      //   final id = e['id'] as String;
      //   final qty = e['qty'] as int;
      //   final variant = e['variant'] as String?;
      //   // Buscar producto desde ProductsProvider o API
      // }
      _items.clear();
      notifyListeners();
    } catch (e) {
        // ignorar errores de parseo
    }
  }
}
