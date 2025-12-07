import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/sales_provider.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SalesProvider CRUD', (){
    setUp(() async { SharedPreferences.setMockInitialValues({}); });

    test('create, read, update, delete', () async {
      final prov = SalesProvider();
      await Future.delayed(Duration(milliseconds:100));
      final id = await prov.addSale({'clientId':'C1','clientName':'Test','serviceName':'Tour','amount':100.0});
      expect(prov.sales.any((s)=> s['id']==id), true);
      await prov.updateSale(id, {'status':'Pagada'});
      final st = prov.getById(id)['status'];
      expect(st, 'Pagada');
      await prov.deleteSale(id);
      expect(prov.sales.any((s)=> s['id']==id), false);
    });
  });
}
