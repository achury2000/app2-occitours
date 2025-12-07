// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:occitours_app/models/itinerary.dart';
import 'package:occitours_app/providers/itineraries_provider.dart';
import 'package:occitours_app/providers/reservations_provider.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async { SharedPreferences.setMockInitialValues({}); });

  test('create reservations from itinerary using real ReservationsProvider', () async {
    final itinProv = ItinerariesProvider();
    while(itinProv.loading) await Future.delayed(Duration(milliseconds:20));
    final id = Uuid().v4();
    final it = Itinerary(id: id, title: 'Conv Test', routeIds: ['S_TEST_1','S_TEST_2'], durationMinutes: 60, price: 10.0);
    await itinProv.addItinerary(it, actor: {'id':'t'});

    final resProv = ReservationsProvider();
    while(resProv.loading) await Future.delayed(Duration(milliseconds:20));

    final date = DateTime.now().add(Duration(days:1));
    final results = await itinProv.createReservationsFromItinerary(id, date: date, time: '09:00', clientId: 'C_TEST', reservationsProvider: resProv, actor: {'id':'t'});
    expect(results.length, 2);
    // each entry should be a reservation id string or an error map
    for (final v in results.values){
      expect(v != null, true);
    }
    // Ensure reservations provider has at least one reservation
    final all = resProv.reservations;
    expect(all.isNotEmpty, true);
  }, timeout: Timeout(Duration(seconds:10)));
}
