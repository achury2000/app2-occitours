// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/fincas_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp((){
    SharedPreferences.setMockInitialValues({});
  });

  test('import CSV with quotes and missing columns', () async {
    final prov = FincasProvider();
    await prov.loadAll();

    // CSV with quoted fields and a missing latitude/longitude
    final csv = 'id,code,name,location,capacity,pricePerNight,latitude,longitude,active\n'
      + 'f_q1,Q1,"Finca \"La\" Querida","Lugar, bonito",10,150000,, ,true\n'
      + 'f_q2,Q2,"Finca Simple",SinLugar,5,80000,6.217,-75.567,false\n';

    await prov.importFromCsv(csv, replace: true, actor: {'id':'test'});

    expect(prov.items.length, 2);
    final a = prov.items.firstWhere((f) => f.id == 'f_q1');
    expect(a.name.contains('La" Querida') || a.name.contains('La\" Querida') || a.name.contains('La"'), true);
    final b = prov.items.firstWhere((f) => f.id == 'f_q2');
    expect(b.latitude, isNotNull);
  });
}
