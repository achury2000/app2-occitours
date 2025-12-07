import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/purchases_provider.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PurchasesProvider basic flow', (){
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('create, set status and delete purchase', () async {
      final prov = PurchasesProvider();
      // wait for load
      await Future.delayed(Duration(milliseconds: 100));
      final id = await prov.addPurchase({'productId':'P1','productName':'X','quantity':2,'unitPrice':10.0});
      expect(prov.purchases.any((p)=>p['id']==id), true);
      await prov.setPurchaseStatus(id, 'Recibido', actor: {'id':'u','name':'t'});
      final st = prov.purchases.firstWhere((p)=>p['id']==id)['status'];
      expect(st, 'Recibido');
      // audit should contain set_purchase_status
      expect(prov.audit.any((a)=> a['action']=='set_purchase_status' && a['purchaseId']==id), true);
      await prov.deletePurchase(id, actor: {'id':'u','name':'t'});
      expect(prov.purchases.any((p)=>p['id']==id), false);
    });
  });
}
