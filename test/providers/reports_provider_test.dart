import 'package:flutter_test/flutter_test.dart';
import 'package:occitours_app/providers/reports_provider.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generateReport fills data', () async {
    final rp = ReportsProvider();
    await rp.generateReport();
    expect(rp.data.isNotEmpty, isTrue);
    expect(rp.data.containsKey('sales'), isTrue);
    expect((rp.data['topProducts'] as List).isNotEmpty, isTrue);
  });
}
