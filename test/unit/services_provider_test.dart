// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/services_provider.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ServicesProvider', (){
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('add, update, delete service', () async {
      final prov = ServicesProvider();
      while (prov.loading) await Future.delayed(Duration(milliseconds:10));
      final id = await prov.addService({'name':'Test S','description':'x','durationMinutes':30,'capacity':4,'price':100});
      expect(prov.getById(id)?.name, 'Test S');
      await prov.updateService(id, {'name':'Test S Updated'});
      expect(prov.getById(id)?.name, 'Test S Updated');
      await prov.deleteService(id);
      expect(prov.getById(id), isNull);
    });

    test('import and export csv', () async {
      final prov = ServicesProvider();
      while (prov.loading) await Future.delayed(Duration(milliseconds:10));
      final csv = 'id,name,description,durationMinutes,capacity,price,active\nS1,Serv A,desc,60,2,120.5,true';
      await prov.importFromCsv(csv, replace: true, actor: {'id':'T','name':'Tester'});
      expect(prov.services.length, 1);
      final out = prov.exportCsv();
      expect(out.contains('Serv A'), isTrue);
    });
  });
}
