// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:occitours_app/models/invoice.dart';
import 'package:occitours_app/providers/invoices_provider.dart';
import 'package:occitours_app/providers/payments_provider.dart';
import 'package:occitours_app/models/payment.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async { SharedPreferences.setMockInitialValues({}); });

  test('setInvoiceStatus links to payment and updates payment status', () async {
    final paymentsProv = PaymentsProvider();
    while(paymentsProv.loading) await Future.delayed(Duration(milliseconds:20));
    final payId = 'P_TEST_${DateTime.now().millisecondsSinceEpoch}';
    final payment = (await (() async {
      final p = Payment(id: payId, reservationId: null, amount: 20.0, currency: 'USD', method: 'card', status: 'pending', timestamp: DateTime.now(), metadata: {});
      return p;
    })());
    await paymentsProv.addPayment(payment, actor: {'id':'t'});

    final invProv = InvoicesProvider();
    while(invProv.loading) await Future.delayed(Duration(milliseconds:20));
    final id = Uuid().v4();
    final items = [InvoiceItem(description: 'I1', quantity:1, unitPrice: 20.0)];
    final inv = Invoice(id: id, reservationIds: [], items: items, total: 20.0);
    await invProv.addInvoice(inv, actor: {'id':'t'});

    await invProv.setInvoiceStatus(id, 'paid', paymentId: payId, paymentsProvider: paymentsProv, actor: {'id':'t'});

    final updatedInv = invProv.findById(id);
    expect(updatedInv?.status.toLowerCase(), 'paid');
    final updatedPayment = paymentsProv.findById(payId);
    expect(updatedPayment?.status.toLowerCase(), 'completed');
  });
}
