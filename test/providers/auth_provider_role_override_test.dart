import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/auth_provider.dart';
import 'package:occitours_app/data/mock_users.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  test('verifySession picks up role override', () async {
    final user = mockUsers.first;
    SharedPreferences.setMockInitialValues({
      'token': 't',
      'userId': user.id,
      'userRole_' + user.id: 'admin'
    });
    final prov = AuthProvider();
    await Future.delayed(Duration(milliseconds: 50));
    await prov.verifySession();
    expect(prov.user?.role, 'admin');
  });
}
