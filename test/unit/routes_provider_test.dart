// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/routes_provider.dart';
import 'package:occitours_app/models/route.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('add and export/import routes CSV', () async {
    final prov = RoutesProvider();
    await prov.loadAll();

    final r = RouteModel(id: 'r1', code: 'R1', name: 'Ruta 1', description: 'desc', fincaIds: ['f1','f2']);
    await prov.addRoute(r);
    expect(prov.items.any((e) => e.id == 'r1'), true);

    final csv = prov.exportCsv();
    expect(csv.contains('r1'), true);

    await prov.importFromCsv(csv, replace: true);
    expect(prov.items.isNotEmpty, true);
  });
}
