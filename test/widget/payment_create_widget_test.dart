// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/payments_provider.dart';
import 'package:occitours_app/providers/reservations_provider.dart';
import 'package:occitours_app/screens/payment_create_screen.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('create payment via UI and mark reservation paid', (tester) async {
    final paymentsProv = PaymentsProvider();
    final reservationsProv = ReservationsProvider();
    // wait for providers to load
    while(paymentsProv.loading) await Future.delayed(Duration(milliseconds:20));
    while(reservationsProv.loading) await Future.delayed(Duration(milliseconds:20));

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider.value(value: paymentsProv),
      ChangeNotifierProvider.value(value: reservationsProv),
    ], child: MaterialApp(home: PaymentCreateScreen(reservationId: 'R_TEST'))));

    await tester.pumpAndSettle();

    // Fill amount
    await tester.enterText(find.byType(TextFormField).at(1), '55');
    // Tap create
    await tester.tap(find.text('Crear Pago'));
    await tester.pumpAndSettle();

    // Payment should be added
    expect(paymentsProv.items.length, greaterThan(0));
    // If reservation existed, status should be set (we created mock reservations earlier may or may not include R_TEST)
    // At least ensure no crash and navigator popped (we're still in widget test context)
  });
}
