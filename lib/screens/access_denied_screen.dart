import 'package:flutter/material.dart';

class AccessDeniedScreen extends StatelessWidget {
  static const routeName = '/access-denied';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Acceso denegado')),
      body: Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('No tienes permisos para acceder a esta sección. Si crees que es un error, inicia sesión con una cuenta administrativa.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
      )),
    );
  }
}
