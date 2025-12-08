import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ClientProfileScreen extends StatefulWidget {
  static const routeName = '/client/profile';

  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _cedulaController;
  late TextEditingController _emailController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;

    _nombreController = TextEditingController(text: user?.name ?? '');
    _apellidoController = TextEditingController(text: user?.apellido ?? '');
    _cedulaController = TextEditingController(text: user?.cedula ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _cedulaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final apiService = ApiService();

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(child: CircularProgressIndicator()),
    );

    try {
      // Actualizar en el backend (tabla usuarios)
      await apiService.updateUser(
        auth.user!.id,
        {
          'nombre': _nombreController.text,
          'apellido': _apellidoController.text,
          'cedula': _cedulaController.text,
          'email': _emailController.text,
        },
      );

      // Actualizar datos del usuario localmente
      auth.user?.name = _nombreController.text;
      auth.user?.apellido = _apellidoController.text;
      auth.user?.cedula = _cedulaController.text;
      auth.user?.email = _emailController.text;

      // Cerrar loading
      Navigator.of(context).pop();

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Perfil actualizado en la base de datos'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Cerrar loading
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        backgroundColor: Colors.purple.shade700,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Restaurar valores originales si se cancela
                  _nombreController.text = user?.name ?? '';
                  _apellidoController.text = user?.apellido ?? '';
                  _cedulaController.text = user?.cedula ?? '';
                  _emailController.text = user?.email ?? '';
                }
              });
            },
            tooltip: _isEditing ? 'Cancelar' : 'Editar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner superior con avatar
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade700, Colors.purple.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Usuario',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user?.role.toUpperCase() ?? 'CLIENTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Formulario de datos
            Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Información Personal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Nombre
                    _buildTextField(
                      controller: _nombreController,
                      label: 'Nombre',
                      icon: Icons.person_outline,
                      enabled: _isEditing,
                      validator: (val) =>
                          val!.isEmpty ? 'Ingresa tu nombre' : null,
                    ),
                    SizedBox(height: 16),

                    // Apellido
                    _buildTextField(
                      controller: _apellidoController,
                      label: 'Apellido',
                      icon: Icons.person_outline,
                      enabled: _isEditing,
                      validator: (val) =>
                          val!.isEmpty ? 'Ingresa tu apellido' : null,
                    ),
                    SizedBox(height: 16),

                    // Cédula
                    _buildTextField(
                      controller: _cedulaController,
                      label: 'Cédula',
                      icon: Icons.badge_outlined,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val!.isEmpty ? 'Ingresa tu cédula' : null,
                    ),
                    SizedBox(height: 16),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Correo Electrónico',
                      icon: Icons.email_outlined,
                      enabled: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val!.isEmpty) return 'Ingresa tu email';
                        if (!val.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Botón de guardar (solo visible en modo edición)
                    if (_isEditing)
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'GUARDAR CAMBIOS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    if (!_isEditing) ...[
                      SizedBox(height: 20),
                      Divider(),
                      SizedBox(height: 20),
                      Text(
                        'Estadísticas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Reservas Totales',
                              '0',
                              Icons.calendar_today,
                              Colors.blue,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Tours Realizados',
                              '0',
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
