import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/access_denied_screen.dart';

class AuthGuard extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;
  const AuthGuard({Key? key, required this.allowedRoles, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isAuthenticated) return AccessDeniedScreen();
    final role = (auth.user?.role ?? '').toLowerCase();
    if (allowedRoles.map((e)=> e.toLowerCase()).contains(role)) return child;
    return AccessDeniedScreen();
  }
}
