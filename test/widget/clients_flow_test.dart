// parte juanjo
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:occitours_app/screens/clients_list_screen.dart';
import 'package:occitours_app/providers/clients_provider.dart';
import 'package:occitours_app/providers/auth_provider.dart';
import 'package:occitours_app/models/user.dart';

class TestAuthProvider extends AuthProvider {
  final User _u;
  TestAuthProvider(this._u): super();
  @override
  User? get user => _u;
}

void main(){
  testWidgets('ClientsList shows client items', (tester) async {
    final initial = [
      {'id':'C1','name':'Cliente Uno','email':'uno@test','phone':'3001112222','active':true,'created':'2025-01-01'},
    ];
    final clientsProv = ClientsProvider(initialClients: initial);
    final auth = TestAuthProvider(User(id: 'A1', name: 'Admin', email: 'a@test', role: 'admin'));

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<ClientsProvider>(create: (_) => clientsProv),
      ChangeNotifierProvider<AuthProvider>(create: (_) => auth),
    ], child: MaterialApp(home: ClientsListScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Cliente Uno'), findsOneWidget);
  });
}
