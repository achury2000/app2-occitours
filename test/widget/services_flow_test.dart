// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:occitours_app/screens/services_list_screen.dart';
import 'package:occitours_app/screens/service_detail_screen.dart';
import 'package:occitours_app/providers/services_provider.dart';
import 'package:occitours_app/providers/auth_provider.dart';
import 'package:occitours_app/models/user.dart';

class TestAuthProvider extends AuthProvider {
  final User _u;
  TestAuthProvider(this._u): super();
  @override
  User? get user => _u;
  @override
  bool hasAnyRole(List<String> roles) {
    final r = _u.role.toLowerCase();
    return roles.map((e) => e.toLowerCase()).contains(r);
  }
}

class SpyServicesProvider extends ServicesProvider {
  String? lastAddedId;
  bool added = false;
  @override
  Future<String> addService(Map<String,dynamic> data) async {
    added = true;
    lastAddedId = 'S_TEST';
    return lastAddedId!;
  }
}

void main(){
  testWidgets('Services list shows and can create service', (tester) async {
    final spy = SpyServicesProvider();
    final auth = TestAuthProvider(User(id: 'A1', name: 'Admin', email: 'a@test', role: 'admin'));

    await tester.pumpWidget(MultiProvider(providers:[
      ChangeNotifierProvider<ServicesProvider>(create: (_) => spy),
      ChangeNotifierProvider<AuthProvider>(create: (_) => auth),
    ], child: MaterialApp(home: ServicesListScreen(), routes: {'/services/create': (_) => ServiceDetailScreen()})));

    await tester.pumpAndSettle();
    // FAB should be present for admin
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    // Should navigate to create screen
    expect(find.text('Crear Servicio'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Nuevo Servicio');
    await tester.enterText(find.widgetWithText(TextFormField, 'Duración (min)'), '45');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(spy.added, isTrue);
  });
}
