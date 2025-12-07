// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:occitours_app/screens/reservations_list_screen.dart';
import 'package:occitours_app/providers/reservations_provider.dart';
import 'package:occitours_app/providers/auth_provider.dart';
import 'package:occitours_app/models/user.dart';
import 'package:occitours_app/providers/clients_provider.dart';

class TestAuthProvider extends AuthProvider {
  final User _u;
  TestAuthProvider(this._u): super();
  @override
  User? get user => _u;
}

class FakeReservationsProvider extends ReservationsProvider {
  final List<Map<String,dynamic>> _data;
  FakeReservationsProvider(this._data): super();
  @override
  List<Map<String,dynamic>> search({String? query, String? service, String? status, DateTime? from, DateTime? to, String? clientId}){
    return _data.where((r){
      if (status != null && (r['status'] ?? '').toString() != status) return false;
      if (query != null && query.isNotEmpty){
        final s = query.toLowerCase();
        final serviceStr = (r['service'] ?? '').toString().toLowerCase();
        final idStr = (r['id'] ?? '').toString().toLowerCase();
        return serviceStr.contains(s) || idStr.contains(s);
      }
      return true;
    }).toList();
  }
}

class FakeClientsProvider extends ClientsProvider {
  final Map<String, Map<String,dynamic>> _map;
  FakeClientsProvider(this._map): super();
  @override
  Map<String,dynamic>? getById(String id) => _map[id];
}

void main(){
  testWidgets('Reservations list shows items', (tester) async {
    final fake = FakeReservationsProvider([
      {'id':'R1','service':'Tour Test','date':'2025-01-01','status':'Activas','clientId':'C1'},
    ]);
    final auth = TestAuthProvider(User(id: 'C1', name: 'Cliente 1', email: 'c1@test', role: 'cliente'));

    await tester.pumpWidget(MultiProvider(providers:[
      ChangeNotifierProvider<ReservationsProvider>(create: (_) => fake as ReservationsProvider),
      ChangeNotifierProvider<ClientsProvider>(create: (_) => FakeClientsProvider({'C1': {'id':'C1','name':'Cliente 1','email':'c1@test'}}) as ClientsProvider),
      ChangeNotifierProvider<AuthProvider>(create: (_) => auth),
    ], child: MaterialApp(home: ReservationsListScreen())));

    await tester.pumpAndSettle();
    expect(find.text('Tour Test'), findsOneWidget);
  });
}
