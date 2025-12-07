import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/products_provider.dart';
import 'package:occitours_app/models/product.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ProductsProvider prevents adding product with empty name', () async {
    final provider = ProductsProvider();
    await provider.loadInitial();
    final p = Product(id: 'x1', code: 'X-001', name: '', description: '', price: 0.0, imageUrl: '', category: 'Test', stock: 0);
    expect(() => provider.addProduct(p), throwsA(isA<Exception>()));
  });

  test('ProductsProvider prevents adding duplicate name', () async {
    final provider = ProductsProvider();
    await provider.loadInitial();
    final existing = provider.items.first;
    final p = Product(id: 'newid', code: 'NEW-1', name: existing.name, description: '', price: 1.0, imageUrl: '', category: 'Test', stock: 0);
    expect(() => provider.addProduct(p), throwsA(isA<Exception>()));
  });

  test('ProductsProvider update throws when causing duplicate name', () async {
    final provider = ProductsProvider();
    await provider.loadInitial();
    final items = provider.items;
    if (items.length < 2) {
      // ensure there are at least two products to test
      final p1 = Product(id: 'a1', code: 'A-01', name: 'A-one', description: '', price: 1.0, imageUrl: '', category: 'Test', stock: 0);
      final p2 = Product(id: 'b2', code: 'B-02', name: 'B-two', description: '', price: 2.0, imageUrl: '', category: 'Test', stock: 0);
      await provider.addProduct(p1);
      await provider.addProduct(p2);
    }
    final list = provider.items;
    final first = list[0];
    final second = list.length > 1 ? list[1] : first;
    final updated = Product(id: second.id, code: second.code, name: first.name, description: second.description, price: second.price, imageUrl: second.imageUrl, category: second.category, stock: second.stock);
    expect(() => provider.updateProduct(updated), throwsA(isA<Exception>()));
  });

  test('ProductsProvider deleteProduct removes product', () async {
    final provider = ProductsProvider();
    await provider.loadInitial();
    final p = Product(id: 'del-id', code: 'DEL-1', name: 'ToDelete', description: '', price: 0.0, imageUrl: '', category: 'Test', stock: 0);
    await provider.addProduct(p);
    // reload initial page so newly inserted product appears in visible items
    await provider.loadInitial();
    expect(provider.items.any((it) => it.id == 'del-id'), isTrue);
    await provider.deleteProduct('del-id');
    await provider.loadInitial();
    expect(provider.items.any((it) => it.id == 'del-id'), isFalse);
  });
  test('loadInitial returns first page', () async {
    final p = ProductsProvider();
    await p.loadInitial();
    expect(p.items.length, greaterThan(0));
  });

  test('loadMore appends items', () async {
    final p = ProductsProvider();
    await p.loadInitial();
    final firstLen = p.items.length;
    await p.loadMore();
    expect(p.items.length, greaterThan(firstLen));
  });
}
