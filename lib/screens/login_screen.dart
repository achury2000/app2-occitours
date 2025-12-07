import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFF1B5E20)),
    );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Color(0xFF1B5E20)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: border,
      focusedBorder: border.copyWith(
          borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeGreen = Color(0xFF1B5E20);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeGreen,
        elevation: 0,
        title: Text('Login'),
      ),
      body: Stack(
        children: [
          // Background image with subtle overlay
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    NetworkImage('https://picsum.photos/seed/loginbg/1600/900'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Color.fromRGBO(0, 0, 0, 0.35)),

          LayoutBuilder(builder: (ctx, constraints) {
            final wide = constraints.maxWidth >= 900;
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: wide ? 1000 : 520),
                  child: wide
                      ? Row(
                          children: [
                            // Left intro column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 12),
                                  CircleAvatar(
                                      backgroundColor:
                                          Color.fromRGBO(255, 255, 255, 0.15),
                                      child: Icon(Icons.park,
                                          color: Colors.white)),
                                  SizedBox(height: 18),
                                  Text('Occitours',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  Text('Explora la naturaleza',
                                      style: TextStyle(color: Colors.white70)),
                                  SizedBox(height: 20),
                                  Text(
                                      'Bienvenido a tu plataforma de turismo\nDescubre experiencias únicas en los paisajes más hermosos de Colombia.',
                                      style: TextStyle(color: Colors.white70)),
                                  SizedBox(height: 24),
                                  Wrap(spacing: 12, runSpacing: 8, children: [
                                    _infoPill('Tours Naturales',
                                        'Senderismo, avistamiento de aves'),
                                    _infoPill('Fincas Auténticas',
                                        'Experiencias rurales genuinas'),
                                  ])
                                ],
                              ),
                            ),
                            SizedBox(width: 28),
                            // Right card with form
                            Expanded(child: _buildCard(auth, themeGreen)),
                          ],
                        )
                      : _buildCard(auth, themeGreen),
                ),
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _buildCard(AuthProvider auth, Color themeGreen) {
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 12,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Iniciar Sesión',
                  style: TextStyle(
                      color: themeGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('Accede a tu cuenta de Occitours',
                  style: TextStyle(color: Colors.black54, fontSize: 13)),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: _fieldDecoration('Correo Electrónico', Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'El email es requerido';
                  final email = v.trim();
                  if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email))
                    return 'Email inválido';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                decoration: _fieldDecoration('Contraseña', Icons.lock),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'La contraseña es requerida';
                  if (v.length < 4)
                    return 'La contraseña debe tener al menos 4 caracteres';
                  return null;
                },
              ),
              SizedBox(height: 8),
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: _showForgotDialog,
                      child: Text('¿Olvidaste tu contraseña?',
                          style: TextStyle(color: themeGreen)))),
              SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: themeGreen,
                      padding: EdgeInsets.symmetric(vertical: 12)),
                  onPressed: auth.loading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          await auth.login(
                              _emailCtrl.text.trim(), _passCtrl.text);
                          if (auth.isAuthenticated) {
                            // If a redirect was requested (e.g. trying to reserve), honor it if role allowed
                            final role = (auth.user?.role ?? '').toLowerCase();
                            final redirect = routeArgs?['redirect'] as String?;
                            final redirectArgs = routeArgs?['redirectArgs'];
                            final allowedRoles =
                                (routeArgs?['allowedRoles'] as List?)
                                    ?.map((e) => e.toString().toLowerCase())
                                    .toList();
                            if (redirect != null &&
                                allowedRoles != null &&
                                allowedRoles.contains(role)) {
                              Navigator.of(context).pushReplacementNamed(
                                  redirect,
                                  arguments: redirectArgs);
                            } else {
                              if (role == 'admin' || role == 'administrador') {
                                Navigator.of(context)
                                    .pushReplacementNamed('/admin');
                              } else if (role == 'asesor' ||
                                  role == 'advisor' ||
                                  role == 'guía') {
                                Navigator.of(context)
                                    .pushReplacementNamed('/advisor');
                              } else if (role == 'cliente' ||
                                  role == 'client') {
                                Navigator.of(context)
                                    .pushReplacementNamed('/client/home');
                              } else {
                                Navigator.of(context).pushReplacementNamed('/');
                              }
                            }
                          } else if (auth.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(auth.error!)));
                          }
                        },
                  child: auth.loading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Iniciar Sesión'),
                ),
              ),
              SizedBox(height: 12),
              Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('¿No tienes cuenta? ',
                        style: TextStyle(color: Colors.black54, fontSize: 12)),
                    GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed('/register'),
                        child: Text('Regístrate aquí',
                            style: TextStyle(
                                color: themeGreen,
                                fontWeight: FontWeight.w600)))
                  ]),
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 8),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'Cuentas de demostración (contraseña: 123456):',
                          style:
                              TextStyle(fontSize: 12, color: Colors.black54))),
                  SizedBox(height: 8),
                  Wrap(spacing: 12, runSpacing: 6, children: [
                    _demoChip('Administrador', 'admin@occitours.com'),
                    _demoChip('Asesor', 'asesor@occitours.com'),
                    _demoChip('Cliente', 'cliente@demo.com'),
                  ])
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoPill(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.12),
          borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Text(subtitle, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  Widget _demoChip(String role, String email) {
    return ActionChip(
      label: Text('$role — $email', style: TextStyle(fontSize: 12)),
      onPressed: () {
        // fill form with demo account
        setState(() {
          _emailCtrl.text = email;
          _passCtrl.text = '123456';
        });
      },
    );
  }

  void _showForgotDialog() {
    final emailCtrl = TextEditingController(text: _emailCtrl.text);
    showDialog(
        context: context,
        builder: (ctx) {
          final _formKey2 = GlobalKey<FormState>();
          bool sending = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Recuperar contraseña'),
              content: Form(
                key: _formKey2,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                      'Ingresa tu correo y te enviaremos instrucciones para restablecer la contraseña.'),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration:
                        InputDecoration(labelText: 'Correo electrónico'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'El email es requerido';
                      if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
                          .hasMatch(v.trim())) return 'Email inválido';
                      return null;
                    },
                  )
                ]),
              ),
              actions: [
                TextButton(
                    onPressed: sending
                        ? null
                        : () {
                            Navigator.of(ctx).pop();
                          },
                    child: Text('Cancelar')),
                ElevatedButton(
                    onPressed: sending
                        ? null
                        : () async {
                            if (!(_formKey2.currentState?.validate() ?? false))
                              return;
                            setState(() => sending = true);
                            // simulate sending
                            await Future.delayed(Duration(seconds: 1));
                            setState(() => sending = false);
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Se ha enviado un correo a ${emailCtrl.text.trim()} con instrucciones.')));
                          },
                    child: sending
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('Enviar'))
              ],
            );
          });
        });
  }
}
