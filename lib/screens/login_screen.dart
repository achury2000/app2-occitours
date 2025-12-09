/**
 * =============================================
 * LOGIN_SCREEN.DART - PANTALLA DE INICIO DE SESIÓN
 * =============================================
 * 
 * Pantalla principal de autenticación que permite a los usuarios
 * iniciar sesión en la aplicación Occitours.
 * 
 * CARACTERÍSTICAS:
 * - Formulario de login con validaciones
 * - Integración con AuthProvider para llamadas al backend
 * - Manejo de estados de carga (loading spinner)
 * - Navegación automática según rol del usuario
 * - Opción de recuperar contraseña (simulada)
 * - Cuentas demo para pruebas rápidas
 * - Diseño responsive (desktop/móvil)
 * - Background con imagen de naturaleza
 * 
 * FLUJO:
 * 1. Usuario ingresa email y contraseña
 * 2. Validación local (formato email, longitud password)
 * 3. auth.login() llama al backend (POST /api/auth/login)
 * 4. Si exitoso: Navega según rol (admin → /admin, cliente → /client/home)
 * 5. Si falla: Muestra SnackBar con error
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Pantalla de login con formulario de autenticación
class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ====== CONTROLADORES DEL FORMULARIO ======
  final _formKey = GlobalKey<FormState>(); // Key para validar formulario
  final _emailCtrl = TextEditingController(); // Controlador del campo email
  final _passCtrl = TextEditingController(); // Controlador del campo password

  @override
  void dispose() {
    // Liberar recursos de los controladores al salir de la pantalla
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Crea decoración consistente para los campos de texto
  /// @param label - Texto del label (ej: "Correo Electrónico")
  /// @param icon - Ícono a mostrar (ej: Icons.email)
  /// @returns InputDecoration con estilos personalizados
  /// Crea decoración consistente para los campos de texto
  /// @param label - Texto del label (ej: "Correo Electrónico")
  /// @param icon - Ícono a mostrar (ej: Icons.email)
  /// @returns InputDecoration con estilos personalizados
  InputDecoration _fieldDecoration(String label, IconData icon) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFF1B5E20)), // Verde oscuro
    );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Color(0xFF1B5E20)), // Ícono verde
      filled: true,
      fillColor: Colors.white,
      enabledBorder: border, // Borde cuando NO está enfocado
      focusedBorder: border.copyWith(
          borderSide: BorderSide(
              color: Color(0xFF2E7D32),
              width: 2)), // Borde cuando SÍ está enfocado
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🎧 OBTENER PROVIDER DE AUTENTICACIÓN
    // Escucha cambios para actualizar UI automáticamente (loading, error, etc.)
    final auth = Provider.of<AuthProvider>(context);
    final themeGreen = Color(0xFF1B5E20); // Color tema de Occitours

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeGreen,
        elevation: 0,
        title: Text('Login'),
      ),
      body: Stack(
        children: [
          // 🖼️ BACKGROUND: Imagen de naturaleza
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    NetworkImage('https://picsum.photos/seed/loginbg/1600/900'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 🎨 OVERLAY: Capa oscura sobre la imagen para mejorar legibilidad
          Container(color: Color.fromRGBO(0, 0, 0, 0.35)),

          // 📱 LAYOUT RESPONSIVE
          LayoutBuilder(builder: (ctx, constraints) {
            final wide = constraints.maxWidth >= 900; // Desktop si >= 900px
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: wide ? 1000 : 520),
                  child: wide
                      ? Row(
                          children: [
                            // 💬 COLUMNA IZQUIERDA: Información de Occitours (solo desktop)
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
                            // 📋 COLUMNA DERECHA: Formulario de login
                            Expanded(child: _buildCard(auth, themeGreen)),
                          ],
                        )
                      : _buildCard(auth, themeGreen), // Solo card en móvil
                ),
              ),
            );
          })
        ],
      ),
    );
  }

  /// Construye el card con el formulario de login
  /// @param auth - Provider de autenticación
  /// @param themeGreen - Color tema de la app
  /// @returns Widget Card con formulario
  Widget _buildCard(AuthProvider auth, Color themeGreen) {
    // Obtener argumentos de redirección (si viene de otra pantalla)
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
              // 📝 TÍTULO DEL FORMULARIO
              Text('Iniciar Sesión',
                  style: TextStyle(
                      color: themeGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('Accede a tu cuenta de Occitours',
                  style: TextStyle(color: Colors.black54, fontSize: 13)),
              SizedBox(height: 16),

              // 📧 CAMPO EMAIL
              TextFormField(
                controller: _emailCtrl,
                decoration: _fieldDecoration('Correo Electrónico', Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  // Validación 1: Campo no vacío
                  if (v == null || v.trim().isEmpty)
                    return 'El email es requerido';

                  // Validación 2: Formato de email válido
                  final email = v.trim();
                  if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email))
                    return 'Email inválido';

                  return null; // ✅ Validación pasó
                },
              ),
              SizedBox(height: 12),

              // 🔒 CAMPO PASSWORD
              TextFormField(
                controller: _passCtrl,
                decoration: _fieldDecoration('Contraseña', Icons.lock),
                obscureText: true, // Ocultar texto (mostrar •••)
                validator: (v) {
                  // Validación 1: Campo no vacío
                  if (v == null || v.isEmpty)
                    return 'La contraseña es requerida';

                  // Validación 2: Mínimo 4 caracteres
                  if (v.length < 4)
                    return 'La contraseña debe tener al menos 4 caracteres';

                  return null; // ✅ Validación pasó
                },
              ),
              SizedBox(height: 8),

              // 🔗 LINK: Olvidaste tu contraseña
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: _showForgotDialog,
                      child: Text('¿Olvidaste tu contraseña?',
                          style: TextStyle(color: themeGreen)))),
              SizedBox(height: 18),

              // 🚀 BOTÓN DE LOGIN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: themeGreen,
                      padding: EdgeInsets.symmetric(vertical: 12)),
                  onPressed: auth.loading
                      ? null // Deshabilitar si está cargando
                      : () async {
                          // 1️⃣ VALIDAR FORMULARIO LOCALMENTE
                          if (!_formKey.currentState!.validate()) return;

                          // 2️⃣ LLAMAR AL PROVIDER PARA LOGIN
                          // Esto hará petición HTTP al backend
                          await auth.login(
                              _emailCtrl.text.trim(), _passCtrl.text);

                          // 3️⃣ VERIFICAR RESULTADO
                          if (auth.isAuthenticated) {
                            // ✅ LOGIN EXITOSO: Navegar según rol

                            // Obtener rol del usuario (convertir a minúsculas)
                            final role = (auth.user?.role ?? '').toLowerCase();

                            // Verificar si hay redirección pendiente
                            final redirect = routeArgs?['redirect'] as String?;
                            final redirectArgs = routeArgs?['redirectArgs'];
                            final allowedRoles =
                                (routeArgs?['allowedRoles'] as List?)
                                    ?.map((e) => e.toString().toLowerCase())
                                    .toList();

                            if (redirect != null &&
                                allowedRoles != null &&
                                allowedRoles.contains(role)) {
                              // Navegar a ruta solicitada (ej: reserva)
                              Navigator.of(context).pushReplacementNamed(
                                  redirect,
                                  arguments: redirectArgs);
                            } else {
                              // Navegar a home según rol
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
                            // ❌ LOGIN FALLÓ: Mostrar error en SnackBar
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(auth.error!)));
                          }
                        },
                  child: auth.loading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)) // Spinner
                      : Text('Iniciar Sesión'),
                ),
              ),
              SizedBox(height: 12),

              // 📱 LINKS Y CUENTA DEMO
              Column(
                children: [
                  // Link a registro
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

                  // 🎭 CUENTA DEMO
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Cuenta de demostración:',
                          style:
                              TextStyle(fontSize: 12, color: Colors.black54))),
                  SizedBox(height: 8),
                  Wrap(spacing: 12, runSpacing: 6, children: [
                    _demoChip(
                        'Administrador', 'admin@occitours.com', 'admin123'),
                  ])
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Crea un card informativo con título y subtítulo
  /// Usado en la columna izquierda (desktop)
  Widget _infoPill(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.12), // Blanco translúcido
          borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Text(subtitle, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  /// Chip clickeable que rellena el formulario con cuenta demo
  /// @param role - Rol de la cuenta (ej: "Administrador")
  /// @param email - Email de la cuenta demo
  /// @param password - Contraseña de la cuenta demo
  Widget _demoChip(String role, String email, String password) {
    return ActionChip(
      label: Text('$role — $email', style: TextStyle(fontSize: 12)),
      onPressed: () {
        // Rellenar formulario automáticamente con cuenta demo
        setState(() {
          _emailCtrl.text = email;
          _passCtrl.text = password;
        });
      },
    );
  }

  /// Muestra diálogo modal para recuperar contraseña
  /// NOTA: La funcionalidad es simulada (no envía email real)
  void _showForgotDialog() {
    final emailCtrl = TextEditingController(text: _emailCtrl.text);
    showDialog(
        context: context,
        builder: (ctx) {
          final _formKey2 = GlobalKey<FormState>();
          bool sending = false; // Estado de carga del botón "Enviar"

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Recuperar contraseña'),
              content: Form(
                key: _formKey2,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                      'Ingresa tu correo y te enviaremos instrucciones para restablecer la contraseña.'),
                  SizedBox(height: 12),

                  // 📧 CAMPO EMAIL
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
                // Botón Cancelar
                TextButton(
                    onPressed: sending
                        ? null
                        : () {
                            Navigator.of(ctx).pop();
                          },
                    child: Text('Cancelar')),

                // Botón Enviar
                ElevatedButton(
                    onPressed: sending
                        ? null
                        : () async {
                            // Validar formulario
                            if (!(_formKey2.currentState?.validate() ?? false))
                              return;

                            setState(() => sending = true);

                            // ⏳ SIMULAR ENVÍO DE EMAIL (1 segundo)
                            // En producción: Llamar endpoint POST /api/auth/forgot-password
                            await Future.delayed(Duration(seconds: 1));

                            setState(() => sending = false);
                            Navigator.of(ctx).pop();

                            // Mostrar confirmación
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
