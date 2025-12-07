import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/products_provider.dart';
import 'package:occitours_app/models/product.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp((){ SharedPreferences.setMockInitialValues({}); });

  test('CRUD for Rutas via ProductsProvider', () async {
    final prov = ProductsProvider();
    await prov.loadInitial();
    final r = Product(id: 'r1', code: 'R-001', name: 'Ruta Test', description: '', price: 100.0, imageUrl: '', category: 'Rutas', stock: 5);
    await prov.addProduct(r);
    expect(prov.items.any((it)=>it.id=='r1' || it.name=='Ruta Test'), isTrue);

    // duplicate name
    final dup = Product(id: 'r2', code: 'R-002', name: 'Ruta Test', description: '', price: 100, imageUrl: '', category: 'Rutas', stock: 1);
    expect(() => prov.addProduct(dup), throwsA(isA<Exception>()));

    // update to duplicate code
    final p2 = Product(id: 'r3', code: 'R-003', name: 'Otra', description: '', price: 50, imageUrl: '', category: 'Rutas', stock: 2);
    await prov.addProduct(p2);
    final updated = Product(id: p2.id, code: r.code, name: p2.name, description: p2.description, price: p2.price, imageUrl: p2.imageUrl, category: p2.category, stock: p2.stock);
    expect(() => prov.updateProduct(updated), throwsA(isA<Exception>()));

    // delete
    await prov.deleteProduct(r.id);
    // findById may throw a String ('Not found') or Exception; accept any thrown object
    expect(() => prov.findById(r.id), throwsA(isA<Object>()));
  });
}
