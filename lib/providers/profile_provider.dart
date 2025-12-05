import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class ProfileProvider with ChangeNotifier {
  User? _user;
  bool _loading = false;

  User? get user => _user;
  bool get loading => _loading;

  Future<void> loadProfile(String userId) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 600));
    // TODO: Cargar usuario desde backend usando userId
    _user = null; // Sin datos mock, cargar desde API
    // intentar cargar ediciones de perfil persistidas
    final prefs = await SharedPreferences.getInstance();
    final key = 'profile_$userId';
    if (_user != null && prefs.containsKey(key)){
      try {
        final raw = prefs.getString(key);
        if (raw!=null){
          final parts = raw.split('|');
          if (parts.length>=3){
            _user!.name = parts[0];
            _user!.phone = parts[1];
            _user!.address = parts[2];
          }
        }
      } catch(_){}
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateProfile(User updated) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 400));
    _user = updated;
    // persist small profile changes locally
    final prefs = await SharedPreferences.getInstance();
    final key = 'profile_${_user!.id}';
    await prefs.setString(key, '${_user!.name}|${_user!.phone ?? ''}|${_user!.address ?? ''}');
    _loading = false;
    notifyListeners();
  }
}
