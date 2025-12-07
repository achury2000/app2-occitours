// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:occitours_app/models/itinerary.dart';
import 'package:occitours_app/providers/itineraries_provider.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async { SharedPreferences.setMockInitialValues({}); });

  test('add, find, export/import, delete itinerary', () async {
    final prov = ItinerariesProvider();
    while(prov.loading) await Future.delayed(Duration(milliseconds:20));
    final id = Uuid().v4();
    final it = Itinerary(id: id, title: 'Test It', description: 'desc', routeIds: ['R1','R2'], durationMinutes: 120, price: 99.0);
    await prov.addItinerary(it, actor: {'id':'t'});
    final found = prov.findById(id);
    expect(found, isNotNull);
    final csv = prov.exportCsv();
    expect(csv, contains('Test It'));
    final prov2 = ItinerariesProvider(); while(prov2.loading) await Future.delayed(Duration(milliseconds:20));
    await prov2.importFromCsv(csv, replace: true, actor: {'id':'t2'});
    expect(prov2.items.isNotEmpty, true);
    await prov.deleteItinerary(id, actor: {'id':'t'});
    final after = prov.findById(id);
    expect(after, isNull);
  }, timeout: Timeout(Duration(seconds:10)));
}
