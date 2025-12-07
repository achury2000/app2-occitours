// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/models/payment.dart';
import 'package:occitours_app/providers/payments_provider.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('add, find, export/import, delete payment', () async {
    final prov = PaymentsProvider();
    // wait until loaded
    while(prov.loading) await Future.delayed(Duration(milliseconds:50));

    final p = Payment(id: 'T1', reservationId: 'R1', amount: 100.0, currency: 'USD', method: 'card', status: 'completed');
    await prov.addPayment(p, actor: {'id':'t','name':'test'});
    final found = prov.findById('T1');
    expect(found, isNotNull);
    expect(found?.amount, 100.0);

    final csv = prov.exportCsv();
    expect(csv, contains('T1'));

    // import into new provider
    final prov2 = PaymentsProvider();
    while(prov2.loading) await Future.delayed(Duration(milliseconds:50));
    await prov2.importFromCsv(csv, replace: true, actor: {'id':'t2'});
    expect(prov2.items.isNotEmpty, true);

    await prov.deletePayment('T1', actor: {'id':'t'});
    final after = prov.findById('T1');
    expect(after, isNull);
  }, timeout: Timeout(Duration(seconds:10)));
}
