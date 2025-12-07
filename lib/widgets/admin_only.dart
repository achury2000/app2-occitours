import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  const AdminOnly({Key? key, required this.child, this.fallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = (auth.user?.role ?? '').toLowerCase();
    if (role == 'admin') return child;
    return fallback ?? SizedBox.shrink();
  }
}
