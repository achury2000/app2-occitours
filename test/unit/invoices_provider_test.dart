// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:occitours_app/models/invoice.dart';
import 'package:occitours_app/providers/invoices_provider.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async { SharedPreferences.setMockInitialValues({}); });

  test('add, find, export/import, delete invoice', () async {
    final prov = InvoicesProvider();
    while(prov.loading) await Future.delayed(Duration(milliseconds:20));
    final id = Uuid().v4();
    final items = [InvoiceItem(description: 'A', quantity: 1, unitPrice: 10.0)];
    final inv = Invoice(id: id, reservationIds: ['R1'], items: items, total: 10.0);
    await prov.addInvoice(inv, actor: {'id':'t'});
    final found = prov.findById(id);
    expect(found, isNotNull);
    final csv = prov.exportCsv();
    expect(csv, contains(id));
    final prov2 = InvoicesProvider(); while(prov2.loading) await Future.delayed(Duration(milliseconds:20));
    await prov2.importFromCsv(csv, replace: true, actor: {'id':'t2'});
    expect(prov2.items.isNotEmpty, true);
    await prov.deleteInvoice(id, actor: {'id':'t'});
    final after = prov.findById(id);
    expect(after, isNull);
  }, timeout: Timeout(Duration(seconds:10)));
}
