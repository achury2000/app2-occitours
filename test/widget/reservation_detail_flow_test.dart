// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:occitours_app/screens/reservation_detail_screen.dart';
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

class SpyReservationsProvider extends ReservationsProvider {
  String? lastSetStatusId;
  String? lastSetStatus;
  Map<String,dynamic>? lastSetActor;
  String? lastSetReason;

  String? lastCancelId;
  Map<String,dynamic>? lastCancelActor;
  String? lastCancelReason;

  SpyReservationsProvider(): super();

  @override
  Future<void> setReservationStatus(String id, String status, {Map<String, String>? actor, String? reason}) async {
    lastSetStatusId = id;
    lastSetStatus = status;
    lastSetActor = actor;
    lastSetReason = reason;
  }

  @override
  Future<void> cancelReservation(String id, {Map<String, String>? actor, String? reason}) async {
    lastCancelId = id;
    lastCancelActor = actor;
    lastCancelReason = reason;
  }

  @override
  Map<String,dynamic>? getById(String id) {
    return {'id':'R1','service':'Tour Test','date':'2025-01-01','status':'Activa','clientId':'C1'};
  }
}

class FakeClientsProvider extends ClientsProvider {
  final Map<String, Map<String,dynamic>> _map;
  FakeClientsProvider(this._map): super();
  @override
  Map<String,dynamic>? getById(String id) => _map[id];
}

void main(){
  testWidgets('Detail screen calls provider with actor and reason on cancel and status change', (tester) async {
    final spy = SpyReservationsProvider();
    final auth = TestAuthProvider(User(id: 'A1', name: 'Admin', email: 'a@test', role: 'admin'));

    // Provide a minimal ClientsProvider so ReservationDetailScreen can resolve client info
    final fakeClients = FakeClientsProvider({'C1': {'id':'C1','name':'Cliente 1','email':'c1@test'}});
    // enlarge the test window to avoid RenderFlex overflow in dialogs
    tester.view.physicalSize = Size(1024, 2048);
    tester.view.devicePixelRatio = 1.0;
    addTearDown((){
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(MultiProvider(providers:[
      ChangeNotifierProvider<ReservationsProvider>(create: (_) => spy),
      ChangeNotifierProvider<AuthProvider>(create: (_) => auth),
      ChangeNotifierProvider<ClientsProvider>(create: (_) => fakeClients),
    ], child: MaterialApp(
      home: Builder(builder: (ctx){
        // push detail route once the widget tree is ready
        WidgetsBinding.instance.addPostFrameCallback((_){ Navigator.of(ctx).pushNamed('/reservations/detail', arguments: 'R1'); });
        return Container();
      }),
      routes: {'/reservations/detail': (_) => ReservationDetailScreen()},
    )));
    await tester.pumpAndSettle();

    // Tap 'Cambiar Estado'
    expect(find.text('Cambiar Estado'), findsOneWidget);
    await tester.tap(find.text('Cambiar Estado'));
    await tester.pumpAndSettle();
    // Confirm dialog
    expect(find.textContaining('Confirmar cambio de estado'), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    // Motive dialog
    expect(find.textContaining('Motivo'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Actualización de prueba');
    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();

    expect(spy.lastSetStatusId, 'R1');
    expect(spy.lastSetActor?['id'], 'A1');
    expect(spy.lastSetReason, 'Actualización de prueba');

    // Now test cancel
    expect(find.text('Cancelar Reserva'), findsOneWidget);
    await tester.tap(find.text('Cancelar Reserva'));
    await tester.pumpAndSettle();
    // Confirm cancel
    expect(find.textContaining('Confirmar cancelación'), findsOneWidget);
    await tester.tap(find.text('Sí'));
    await tester.pumpAndSettle();
    // Motive required
    expect(find.textContaining('Motivo de cancelación'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Motivo prueba cancel');
    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();

    expect(spy.lastCancelId, 'R1');
    expect(spy.lastCancelActor?['id'], 'A1');
    expect(spy.lastCancelReason, 'Motivo prueba cancel');
  });
}
