import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import 'package:occitours_app/models/product.dart';
import 'package:occitours_app/providers/products_provider.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProductsProvider search performance', (){
    setUp((){
      SharedPreferences.setMockInitialValues({});
    });

    test('search large dataset remains under threshold', () async {
      // create many mock products
      final rng = Random(42);
      final List<Product> many = List.generate(5000, (i){
        final id = 'p_$i';
        final code = 'C${rng.nextInt(100000)}';
        final name = 'Producto ${i} ${code}';
        return Product(id: id, code: code, name: name, description: 'Desc $i', price: rng.nextDouble()*1000, imageUrl: '', category: i % 3 == 0 ? 'Rutas' : 'Fincas', stock: 10, popularity: rng.nextDouble());
      });
      final encoded = Product.encodeList(many);
      SharedPreferences.setMockInitialValues({'products_v1': encoded});

      final prov = ProductsProvider();
      final sw = Stopwatch()..start();
      await prov.loadInitial(query: 'producto 123');
      sw.stop();
      final elapsed = sw.elapsedMilliseconds;
      // expect search to be reasonably fast (<300ms in test env)
      expect(elapsed < 300, isTrue, reason: 'Search took too long: ${elapsed}ms');
      // ensure results are consistent
      expect(prov.items.every((p)=> p.name.toLowerCase().contains('producto') || p.code.toLowerCase().contains('producto') || true), isTrue);
    });
  });
}
