// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/reservations_provider.dart';

void main(){
  group('ReservationsProvider.importFromCsv', (){
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });
    test('import valid CSV rows appends reservations', () async {
      final prov = ReservationsProvider();
      // Wait for provider to finish initial load to avoid race with import
      while (prov.loading) await Future.delayed(Duration(milliseconds: 10));
      final initialCount = prov.reservations.length;
      final csv = 'id,service,date,time,status,clientId,notes\nR100,Tour A,2025-12-01,09:00,Activa,C100,nota1\nR101,Tour B,2025-12-02,10:00,Activa,C101,nota2';
      await prov.importFromCsv(csv, replace: false, actor: {'id':'T1','name':'Test'});
      expect(prov.reservations.length, greaterThan(initialCount));
      expect(prov.getById('R100')?['service'], 'Tour A');
    });

    test('import with replace true clears previous entries', () async {
      final prov = ReservationsProvider();
      while (prov.loading) await Future.delayed(Duration(milliseconds: 10));
      // import an initial CSV with explicit id OLD1
      final csv1 = 'id,service,date,time,status,clientId,notes\nOLD1,Old Service,2025-01-01,08:00,Activa,C0,old';
      await prov.importFromCsv(csv1, replace: false, actor: {'id':'T1','name':'Test'});
      expect(prov.getById('OLD1'), isNotNull);
      final csv2 = 'id,service,date,time,status,clientId,notes\nNEW1,Service X,2025-11-30,12:00,Activa,CX,nt';
      await prov.importFromCsv(csv2, replace: true, actor: {'id':'T1','name':'Test'});
      expect(prov.getById('OLD1'), isNull);
      expect(prov.getById('NEW1')?['service'], 'Service X');
    });

    test('import with unknown headers still records audit', () async {
      final prov = ReservationsProvider();
      while (prov.loading) await Future.delayed(Duration(milliseconds: 10));
      final csv = 'bad,header\n1,2,3';
      await prov.importFromCsv(csv, replace: false, actor: {'id':'T1','name':'Test'});
      expect(prov.audit.first['action'], 'import_reservations');
      expect(prov.audit.first['count'], 1);
    });

    test('addReservation should prevent duplicity for same service/date/time', () async {
      final prov = ReservationsProvider();
      while (prov.loading) await Future.delayed(Duration(milliseconds: 10));
      final data = {'service':'DupTest','date':'2025-12-10','time':'09:00','clientId':'C1'};
      final id = await prov.addReservation(Map<String,dynamic>.from(data));
      expect(prov.getById(id), isNotNull);
      // Attempt to add duplicate
      expect(() async => await prov.addReservation(Map<String,dynamic>.from(data)), throwsA(isA<Exception>()));
    });
  });
}
