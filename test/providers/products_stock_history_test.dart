import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/products_provider.dart';
import 'package:occitours_app/models/product.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProductsProvider stock history', (){
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('updateProduct records stock history', () async {
      final prov = ProductsProvider();
      // wait a short while for load
      await Future.delayed(Duration(milliseconds: 200));
      // create a product
      final p = Product(id: 'T1', code: 'T1', name: 'TestProd', description: '', price: 10.0, imageUrl: '', category: 'Test', stock: 5, variants: [], popularity: 0);
      await prov.addProduct(p);
      // update stock
      final updated = Product(id: 'T1', code: 'T1', name: 'TestProd', description: '', price: 10.0, imageUrl: '', category: 'Test', stock: 12, variants: [], popularity: 0);
      await prov.updateProduct(updated, reason: 'test', actor: {'id':'u','name':'t'});
      final hist = prov.stockHistoryFor('T1');
      expect(hist.isNotEmpty, true);
      expect(hist.first['previous'], 5);
      expect(hist.first['new'], 12);
      expect(hist.first['reason'], 'test');
    });
  });
}
