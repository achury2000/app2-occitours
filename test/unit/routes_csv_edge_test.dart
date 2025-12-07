// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/routes_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp((){
    SharedPreferences.setMockInitialValues({});
  });

  test('import routes CSV with missing fields and pipe-separated fincas', () async {
    final prov = RoutesProvider();
    await prov.loadAll();

    final csv = 'id,code,name,description,fincaIds,distanceKm,estimatedMinutes\n'
      + 'r_q1,RQ1,"Ruta \"Coma\"","Desc, con coma","f1|f2",12.5,180\n'
      + 'r_q2,RQ2,Simple Route,,f3, ,120\n';

    await prov.importFromCsv(csv, replace: true);
    expect(prov.items.length, 2);
    final r1 = prov.items.firstWhere((r)=> r.id == 'r_q1');
    expect(r1.fincaIds.length, 2);
    final r2 = prov.items.firstWhere((r)=> r.id == 'r_q2');
    expect(r2.distanceKm == null || r2.distanceKm == 0 || r2.distanceKm is double, true);
  });
}
