// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:occitours_app/providers/itineraries_provider.dart';
import 'package:occitours_app/providers/reservations_provider.dart';
import 'package:occitours_app/models/itinerary.dart';
import 'package:occitours_app/screens/itinerary_detail_screen.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async { SharedPreferences.setMockInitialValues({}); });

  testWidgets('convert itinerary to reservations via UI', (tester) async {
    final itinProv = ItinerariesProvider();
    while(itinProv.loading) await Future.delayed(Duration(milliseconds:20));
    final id = Uuid().v4();
    final it = Itinerary(id: id, title: 'WidgetConv', routeIds: ['S_W1'], durationMinutes: 45, price: 20.0);
    await itinProv.addItinerary(it, actor: {'id':'t'});

    final resProv = ReservationsProvider();
    while(resProv.loading) await Future.delayed(Duration(milliseconds:20));

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider.value(value: itinProv),
      ChangeNotifierProvider.value(value: resProv),
    ], child: MaterialApp(home: ItineraryDetailScreen(itineraryId: id))));

    await tester.pumpAndSettle();

    // Tap the convert button
    expect(find.text('Convertir a reservas'), findsOneWidget);
    await tester.tap(find.text('Convertir a reservas'));
    await tester.pumpAndSettle();

    // Dialog appears; fill fields
    await tester.enterText(find.byType(TextField).at(0), DateTime.now().add(Duration(days:2)).toIso8601String().split('T').first);
    await tester.enterText(find.byType(TextField).at(1), '08:30');
    await tester.enterText(find.byType(TextField).at(2), 'C_WIDGET');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // After conversion, reservations provider should have entries
    expect(resProv.reservations.isNotEmpty, true);
  });
}
