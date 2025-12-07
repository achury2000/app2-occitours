import 'package:flutter/material.dart';

class RecoverPasswordScreen extends StatefulWidget {
  static const routeName = '/recover';
  @override
  _RecoverPasswordScreenState createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose(){ _email.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recuperar contraseña')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children:[
            Text('Introduce tu correo para recibir el enlace de recuperación', style: TextStyle(fontSize: 14)),
            SizedBox(height:12),
            TextFormField(controller: _email, decoration: InputDecoration(labelText: 'Correo electrónico'), validator: (v){ if(v==null||v.isEmpty) return 'Requerido'; return null; }),
            SizedBox(height:16),
            ElevatedButton(onPressed: ()=> _send(), child: Text('Enviar enlace'))
          ])
        ),
      ),
    );
  }

  void _send(){ if(!_formKey.currentState!.validate()) return; // call recovery logic
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enlace enviado (simulado)')));
  }
}
