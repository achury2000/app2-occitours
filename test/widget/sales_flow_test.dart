// parte juanjo
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:occitours_app/screens/sales_list_client_screen.dart';
import 'package:occitours_app/providers/sales_provider.dart';
import 'package:occitours_app/models/user.dart';
import 'package:occitours_app/providers/auth_provider.dart';

class TestAuthProvider extends AuthProvider {
  final User _u;
  TestAuthProvider(this._u): super();
  @override
  User? get user => _u;
}

class FakeSalesProvider extends SalesProvider {
  final List<Map<String,dynamic>> _sales;
  FakeSalesProvider(this._sales) : super();
  @override
  List<Map<String,dynamic>> salesForClient(String clientId) => _sales.where((s) => (s['clientId'] ?? '') == clientId).toList();
}

void main(){
  testWidgets('SalesList shows sale items for client', (tester) async {
    final fake = FakeSalesProvider([
      {'id': 'S1', 'clientId': 'C1', 'serviceName': 'Tour A', 'createdAt': DateTime.now().toIso8601String(), 'amount': 120000},
    ]);

    final auth = TestAuthProvider(User(id: 'C1', name: 'Cliente Test', email: 'c@test', role: 'cliente'));

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<SalesProvider>(create: (_) => fake as SalesProvider),
      ChangeNotifierProvider<AuthProvider>(create: (_) => auth),
    ], child: MaterialApp(home: SalesListClientScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Tour A'), findsOneWidget);
  });
}
