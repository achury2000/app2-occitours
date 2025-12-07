import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/cart_provider.dart';
import 'package:occitours_app/data/mock_products.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('addProduct and totals', () async {
    final cart = CartProvider();
    final prod = mockProducts.first;
    cart.addProduct(prod, qty: 2);
    expect(cart.items.length, equals(1));
    expect(cart.subtotal, equals(prod.price * 2));
    // apply coupon
    final applied = cart.applyCoupon('DESC10');
    expect(applied, isTrue);
    expect(cart.discount, greaterThan(0));
  });

  test('clear empties cart', () async {
    final cart = CartProvider();
    final prod = mockProducts.first;
    cart.addProduct(prod);
    expect(cart.items.isNotEmpty, isTrue);
    cart.clear();
    expect(cart.items.isEmpty, isTrue);
  });
}
