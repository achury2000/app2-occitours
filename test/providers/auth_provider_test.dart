import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('login with mock user succeeds', () async {
    final auth = AuthProvider();
    await auth.login('cliente@demo.com', 'whatever');
    expect(auth.isAuthenticated, isTrue);
    expect(auth.user, isNotNull);
  });
}
