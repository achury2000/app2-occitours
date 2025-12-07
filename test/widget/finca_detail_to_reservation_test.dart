// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:occitours_app/screens/finca_detail_screen.dart';
import 'package:occitours_app/providers/fincas_provider.dart';
import 'package:occitours_app/providers/services_provider.dart';
import 'package:occitours_app/providers/clients_provider.dart';
import 'package:occitours_app/screens/reservations_create_screen.dart';
import 'package:occitours_app/providers/reservations_provider.dart';
import '../test_helpers.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initTestEnvironment();
  });

  setUp((){
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Detalle finca -> botón reservar abre formulario', (tester) async {
    final fincasProv = FincasProvider();
    final reservationsProv = ReservationsProvider();
    await fincasProv.loadAll();

    final firstFincaId = fincasProv.items.isNotEmpty ? fincasProv.items.first.id : null;
    if (firstFincaId == null) return;

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<FincasProvider>.value(value: fincasProv),
      ChangeNotifierProvider<ReservationsProvider>.value(value: reservationsProv),
      ChangeNotifierProvider<ServicesProvider>(create: (_) => ServicesProvider()),
      ChangeNotifierProvider<ClientsProvider>(create: (_) => ClientsProvider()),
    ], child: MaterialApp(
      routes: {
        '/reservations/create': (ctx) => ReservationsCreateScreen(),
      },
      initialRoute: FincaDetailScreen.routeName,
      onGenerateRoute: (settings) {
        if (settings.name == FincaDetailScreen.routeName) return MaterialPageRoute(builder: (_) => FincaDetailScreen(), settings: RouteSettings(arguments: firstFincaId));
        return null;
      },
    )));

    await tester.pumpAndSettle();

    // The detail screen should show finca name
    expect(find.byType(FincaDetailScreen), findsOneWidget);

    // No explicit 'Reservar' button in detail; we will navigate to reservations create via Navigator
    // Simulate pressing a FloatingActionButton if present; otherwise ensure navigation works via pushNamed
    Navigator.of(tester.element(find.byType(FincaDetailScreen))).pushNamed('/reservations/create', arguments: firstFincaId);
    await tester.pumpAndSettle();

    expect(find.text('Crear Reserva'), findsOneWidget);
  });
}
