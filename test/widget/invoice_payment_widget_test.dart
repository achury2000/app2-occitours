// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:occitours_app/providers/invoices_provider.dart';
import 'package:occitours_app/providers/payments_provider.dart';
import 'package:occitours_app/models/invoice.dart';
import 'package:occitours_app/screens/invoice_detail_screen.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async { SharedPreferences.setMockInitialValues({}); });

  testWidgets('create payment from invoice detail and mark invoice paid', (tester) async {
    final invProv = InvoicesProvider();
    while(invProv.loading) await Future.delayed(Duration(milliseconds:20));
    final id = Uuid().v4();
    final items = [InvoiceItem(description: 'X', quantity:1, unitPrice: 5.0)];
    final inv = Invoice(id: id, reservationIds: ['R_X'], items: items, total: 5.0);
    await invProv.addInvoice(inv, actor: {'id':'t'});

    final paymentsProv = PaymentsProvider();
    while(paymentsProv.loading) await Future.delayed(Duration(milliseconds:20));

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider.value(value: invProv),
      ChangeNotifierProvider.value(value: paymentsProv),
    ], child: MaterialApp(home: InvoiceDetailScreen(invoiceId: id))));

    await tester.pumpAndSettle();
    // Find button and tap create payment
    expect(find.text('Crear pago y marcar pagada'), findsOneWidget);
    await tester.tap(find.text('Crear pago y marcar pagada'));
    await tester.pumpAndSettle();

    // Fill dialog
    await tester.enterText(find.byType(TextField).first, '5');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Payment should be created and invoice marked paid
    expect(paymentsProv.items.isNotEmpty, true);
    final updated = invProv.findById(id);
    expect(updated?.status.toLowerCase(), 'paid');
  });
}
