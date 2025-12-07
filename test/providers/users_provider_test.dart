import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:occitours_app/providers/users_provider.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  test('updateRole persists and writes override key', () async {
    SharedPreferences.setMockInitialValues({});

    final prov = UsersProvider();
    // wait a tick for load
    await Future.delayed(Duration(milliseconds: 50));
    final users = prov.users;
    expect(users.isNotEmpty, true);
    final id = users.first.id;
    await prov.updateRole(id, 'admin');
    final prefs = await SharedPreferences.getInstance();
    final override = prefs.getString('userRole_' + id);
    expect(override, 'admin');
  });
}
