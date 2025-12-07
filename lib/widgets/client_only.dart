import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ClientOnly extends StatelessWidget {
  final Widget child;
  ClientOnly({required this.child});

  @override
  Widget build(BuildContext context) {
    final role = (Provider.of<AuthProvider>(context).user?.role ?? '').toLowerCase();
    if (role == 'cliente' || role == 'client') return child;
    return SizedBox.shrink();
  }
}
