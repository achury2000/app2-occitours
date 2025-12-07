import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/fincas_provider.dart';
import 'package:occitours_app/models/finca.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('addFinca requires name and code and prevents duplicates', () async {
    final prov = FincasProvider();
    await prov.loadAll();
    final f = Finca(id: 'fx1', code: 'FX-01', name: '', description: '', location: '', capacity: 0, pricePerNight: 0.0);
    expect(() => prov.addFinca(f), throwsA(isA<Exception>()));

    final valid = Finca(id: 'fx2', code: 'FX-02', name: 'Test Finca', description: '', location: '', capacity: 5, pricePerNight: 100.0);
    await prov.addFinca(valid);
    expect(prov.items.any((it) => it.id == 'fx2'), isTrue);

    final dup = Finca(id: 'fx3', code: 'FX-02', name: 'Test Finca 2', description: '', location: '', capacity: 3, pricePerNight: 50.0);
    expect(() => prov.addFinca(dup), throwsA(isA<Exception>()));
  });

  test('updateFinca detects code/name duplicates', () async {
    final prov = FincasProvider();
    await prov.loadAll();
    final a = Finca(id: 'a1', code: 'A-01', name: 'A', description: '', location: '', capacity: 1, pricePerNight: 10);
    final b = Finca(id: 'b2', code: 'B-02', name: 'B', description: '', location: '', capacity: 2, pricePerNight: 20);
    await prov.addFinca(a);
    await prov.addFinca(b);

    final updated = Finca(id: b.id, code: b.code, name: a.name, description: b.description, location: b.location, capacity: b.capacity, pricePerNight: b.pricePerNight);
    expect(() => prov.updateFinca(updated), throwsA(isA<Exception>()));
  });

  test('deleteFinca removes item', () async {
    final prov = FincasProvider();
    await prov.loadAll();
    final f = Finca(id: 'del1', code: 'DEL-1', name: 'ToDel', description: '', location: '', capacity: 2, pricePerNight: 10);
    await prov.addFinca(f);
    expect(prov.items.any((it) => it.id == 'del1'), isTrue);
    await prov.deleteFinca('del1');
    expect(prov.items.any((it) => it.id == 'del1'), isFalse);
  });
}
