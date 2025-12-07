// parte lucho
// parte linsaith
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'role_detail_screen.dart';

class RolesListScreen extends StatefulWidget {
  static const routeName = '/roles';
  @override
  _RolesListScreenState createState() => _RolesListScreenState();
}

class _RolesListScreenState extends State<RolesListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _roles = [];
  bool _isLoading = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _cargarRoles();
  }

  Future<void> _cargarRoles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('📡 Llamando a _apiService.getRoles()...');
      final roles = await _apiService.getRoles();

      setState(() {
        _roles = roles;
        _isLoading = false;
      });

      print('✅ Roles cargados desde BD: ${roles.length}');
      roles.forEach((r) => print('  - ${r['nombre']} (ID: ${r['id']})'));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      print('❌ Error al cargar roles: $e');

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

  Future<void> _eliminarRol(Map<String, dynamic> rol) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text(
          '¿Seguro que deseas eliminar el rol "${rol['nombre']}"? Esta acción no se puede deshacer.',
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
        await _apiService.deleteRol(rol['id'].toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rol eliminado correctamente')),
        );

        // Recargar roles
        await _cargarRoles();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar rol: $e'),
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
        appBar: AppBar(title: Text('Roles')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _roles
        .where((r) =>
            _query.isEmpty ||
            (r['nombre'] ?? '').toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Roles'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarRoles,
            tooltip: 'Recargar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).pushNamed('/roles/create');
          _cargarRoles();
        },
        tooltip: 'Crear rol',
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por nombre',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                setState(() => _query = v);
              },
            ),
            SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No hay roles para mostrar',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final r = filtered[i];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                (r['nombre'] ?? 'R')[0].toUpperCase(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              r['nombre'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text('ID: ${r['id']}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'view') {
                                  Navigator.of(context).pushNamed(
                                    RoleDetailScreen.routeName,
                                    arguments: r['id'],
                                  );
                                } else if (value == 'edit') {
                                  await Navigator.of(context).pushNamed(
                                    '/roles/edit',
                                    arguments: r['id'],
                                  );
                                  _cargarRoles(); // Recargar después de editar
                                } else if (value == 'delete') {
                                  _eliminarRol(r);
                                } else if (value == 'permissions') {
                                  Navigator.of(context).pushNamed(
                                    '/roles/assign',
                                    arguments: r['id'],
                                  );
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility),
                                      SizedBox(width: 8),
                                      Text('Ver detalle'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'permissions',
                                  child: Row(
                                    children: [
                                      Icon(Icons.security),
                                      SizedBox(width: 8),
                                      Text('Permisos'),
                                    ],
                                  ),
                                ),
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
                          ),
                        );
                      }),
            )
          ],
        ),
      ),
    );
  }
}
