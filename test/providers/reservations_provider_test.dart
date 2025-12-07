import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/reservations_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReservationsProvider', () {
    setUp(() async {
      // ensure clean SharedPreferences for each test
      SharedPreferences.setMockInitialValues({});
    });

    test('prevents adding duplicate reservation (service+date+time)', () async {
      final prov = ReservationsProvider();
      // wait until loading completes
      while (prov.loading) await Future.delayed(Duration(milliseconds: 50));

      // create a reservation
      final data = {'service': 'Reserva Test', 'date': '2025-12-01', 'time': '10:00', 'price': 1000};
      final id = await prov.addReservation(data);
      expect(id, isNotNull);

      // attempt to add duplicate
      expect(() async => await prov.addReservation({'service': 'Reserva Test', 'date': '2025-12-01', 'time': '10:00'}), throwsA(isA<Exception>()));
    });

    test('deleteReservation blocks deleting active activities and allows deleting non-active', () async {
      final prov = ReservationsProvider();
      while (prov.loading) await Future.delayed(Duration(milliseconds: 50));

      // add inactive reservation
      final id1 = await prov.addReservation({'service':'ToDelete', 'date':'2025-12-02', 'time':'09:00', 'status':'Cancelada'});
      // should be deletable
      await prov.deleteReservation(id1);
      expect(prov.getById(id1), isNull);

      // add active reservation
      final id2 = await prov.addReservation({'service':'Active', 'date':'2025-12-03', 'time':'11:00', 'status':'Activa'});
      // deletion should throw
      expect(() async => await prov.deleteReservation(id2), throwsA(isA<Exception>()));
    });

    test('updateReservation throws when causing duplication', () async {
      final prov = ReservationsProvider();
      while (prov.loading) await Future.delayed(Duration(milliseconds: 50));
      await prov.addReservation({'service':'S1','date':'2025-12-10','time':'08:00'});
      final b = await prov.addReservation({'service':'S2','date':'2025-12-10','time':'09:00'});
      // attempt to update b to have same service/date/time as a
      try {
        await prov.updateReservation(b, {'service':'S1','date':'2025-12-10','time':'08:00'});
        // if update did not throw, fail with debug info
        final all = prov.reservations;
        fail('updateReservation did not throw. reservations: ${all.map((r)=> {'id': r['id'], 'service': r['service'], 'date': r['date'], 'time': r['time']}).toList()}');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('setReservationStatus updates status correctly', () async {
      final prov = ReservationsProvider();
      while (prov.loading) await Future.delayed(Duration(milliseconds: 50));
      final id = await prov.addReservation({'service':'StatusTest','date':'2025-12-20','time':'12:00','status':'Activa'});
      await prov.setReservationStatus(id, 'Inactiva');
      final r = prov.getById(id);
      expect(r != null && (r['status'] ?? '') == 'Inactiva', true);
    });
  });
}
