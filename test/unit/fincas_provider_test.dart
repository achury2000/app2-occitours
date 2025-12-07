// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/fincas_provider.dart';
import 'package:occitours_app/models/finca.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('add, search by proximity and export/import CSV', () async {
    final prov = FincasProvider();
    await prov.loadAll();

    final f = Finca(id: 't1', code: 'T1', name: 'Test Finca', description: 'desc', location: 'loc', capacity: 10, pricePerNight: 100.0, latitude: 0.0, longitude: 0.0);
    await prov.addFinca(f, actor: {'id':'test'});
    expect(prov.items.any((e) => e.id == 't1'), true);

    final nearby = prov.search(lat: 0.0, lng: 0.0, radiusKm: 1.0);
    expect(nearby.any((e) => e.id == 't1'), true);

    final csv = prov.exportCsv();
    expect(csv.contains('t1'), true);

    // import back replacing
    await prov.importFromCsv(csv, replace: true, actor: {'id': 'imp'});
    expect(prov.items.isNotEmpty, true);
  });
}
