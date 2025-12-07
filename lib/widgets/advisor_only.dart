import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdvisorOnly extends StatelessWidget {
  final Widget child;
  AdvisorOnly({required this.child});

  @override
  Widget build(BuildContext context) {
    final role = (Provider.of<AuthProvider>(context).user?.role ?? '').toLowerCase();
    if (role == 'asesor' || role == 'advisor') return child;
    return SizedBox.shrink();
  }
}
