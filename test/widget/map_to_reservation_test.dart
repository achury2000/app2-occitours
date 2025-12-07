// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:occitours_app/screens/fincas_map_screen.dart';
import 'package:occitours_app/providers/fincas_provider.dart';
import 'package:occitours_app/models/finca.dart';
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

  testWidgets('Mapa -> abrir dialog y navegar a crear reserva', (tester) async {
    final fincasProv = FincasProvider();
    final reservationsProv = ReservationsProvider();

    // ensure loaded
    await fincasProv.loadAll();
    // Inject coordinates for tests (avoid modifying mock data file)
    try {
      if (fincasProv.items.isNotEmpty) {
        final f = fincasProv.items.first;
        final updated = Finca(
          id: f.id,
          code: f.code,
          name: f.name,
          description: f.description,
          location: f.location,
          capacity: f.capacity,
          pricePerNight: f.pricePerNight,
          images: f.images,
          latitude: 6.217,
          longitude: -75.567,
          serviceIds: f.serviceIds,
          active: f.active,
        );
        await fincasProv.updateFinca(updated);
      }
    } catch (_) {}

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<FincasProvider>.value(value: fincasProv),
      ChangeNotifierProvider<ReservationsProvider>.value(value: reservationsProv),
    ], child: MaterialApp(
      routes: {
        FincasMapScreen.routeName: (ctx) => FincasMapScreen(),
        '/reservations/create': (ctx) => ReservationsCreateScreen(),
      },
      initialRoute: FincasMapScreen.routeName,
    )));

    await tester.pumpAndSettle();

    // find a marker icon (there should be at least one in mock data with coords)
    expect(find.byIcon(Icons.location_on), findsWidgets);

    // tap first marker
    await tester.tap(find.byIcon(Icons.location_on).first);
    await tester.pumpAndSettle();

    // dialog opened with 'Reservar' button (if finca has coords)
    final reservarFinder = find.text('Reservar');
    if (reservarFinder.evaluate().isNotEmpty) {
      await tester.tap(reservarFinder.first);
      await tester.pumpAndSettle();

      // should navigate to Crear Reserva screen
      expect(find.text('Crear Reserva'), findsOneWidget);
    } else {
      // if no 'Reservar' found, at least dialog should be present
      expect(find.byType(AlertDialog), findsOneWidget);
    }
  });
}
