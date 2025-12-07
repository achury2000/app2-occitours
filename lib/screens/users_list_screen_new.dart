import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class UsersListScreen extends StatefulWidget {
  static const routeName = '/users';

  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _usuarios = [];
  bool _isLoading = false;
  String _query = '';
  String _roleFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _apiService.setToken(auth.token);

      final usuarios = await _apiService.getUsers();

      setState(() {
        _usuarios = usuarios;
        _isLoading = false;
      });

      print('✅ Usuarios cargados desde BD: ${usuarios.length}');
      usuarios.forEach(
          (u) => print('  - ${u['nombre']} ${u['apellido']} (${u['email']})'));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      print('❌ Error al cargar usuarios: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _mapearRol(String rol) {
    switch (rol.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return 'Administrador';
      case 'guia':
      case 'guide':
        return 'Guía';
      default:
        return 'Cliente';
    }
  }

  int _obtenerRolId(String rolLabel) {
    switch (rolLabel) {
      case 'Administrador':
        return 1;
      case 'Guía':
        return 3;
      default:
        return 2;
    }
  }

  Future<void> _actualizarRol(
      Map<String, dynamic> usuario, String nuevoRolLabel) async {
    try {
      final rolId = _obtenerRolId(nuevoRolLabel);
      await _apiService.updateUser(usuario['id'].toString(), {'rol_id': rolId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rol actualizado correctamente')),
      );

      // Recargar usuarios
      await _cargarUsuarios();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar rol: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarUsuario(Map<String, dynamic> usuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text(
          '¿Eliminar al usuario ${usuario['nombre']} ${usuario['apellido']}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteUser(usuario['id'].toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario eliminado correctamente')),
        );

        // Recargar usuarios
        await _cargarUsuarios();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Usuarios')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final usuariosFiltrados = _usuarios.where((u) {
      final nombre = '${u['nombre']} ${u['apellido']}'.toLowerCase();
      final email = (u['email'] ?? '').toLowerCase();

      final matchQuery = _query.isEmpty ||
          nombre.contains(_query.toLowerCase()) ||
          email.contains(_query.toLowerCase());

      final matchRol =
          _roleFilter == 'Todos' || _mapearRol(u['rol'] ?? '') == _roleFilter;

      return matchQuery && matchRol;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarUsuarios,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                TextFormField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar por nombre o correo',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _roleFilter,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por rol',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Todos', 'Cliente', 'Guía', 'Administrador']
                      .map((r) => DropdownMenuItem(child: Text(r), value: r))
                      .toList(),
                  onChanged: (v) => setState(() => _roleFilter = v ?? 'Todos'),
                ),
              ],
            ),
          ),
          Expanded(
            child: usuariosFiltrados.isEmpty
                ? Center(
                    child: Text(
                      'No hay usuarios para mostrar',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: usuariosFiltrados.length,
                    itemBuilder: (ctx, i) {
                      final usuario = usuariosFiltrados[i];
                      final nombreCompleto =
                          '${usuario['nombre']} ${usuario['apellido']}';
                      final email = usuario['email'] ?? '';
                      final rol = _mapearRol(usuario['rol'] ?? '');

                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              nombreCompleto[0].toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(nombreCompleto),
                          subtitle: Text('$email • $rol'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButton<String>(
                                value: rol,
                                underline: SizedBox(),
                                items: ['Cliente', 'Guía', 'Administrador']
                                    .map((r) => DropdownMenuItem(
                                          value: r,
                                          child: Text(r),
                                        ))
                                    .toList(),
                                onChanged: (nuevoRol) {
                                  if (nuevoRol != null) {
                                    _actualizarRol(usuario, nuevoRol);
                                  }
                                },
                              ),
                              PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'delete') {
                                    _eliminarUsuario(usuario);
                                  }
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Eliminar'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
