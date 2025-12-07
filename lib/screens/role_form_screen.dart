import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RoleFormScreen extends StatefulWidget {
  static const routeNameCreate = '/roles/create';
  static const routeNameEdit = '/roles/edit';

  @override
  _RoleFormScreenState createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String? _id;
  String _name = '';
  bool _loading = false;
  bool _isEdit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_id == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String || args is int) {
        _id = args.toString();
        _isEdit = true;
        _cargarRol();
      }
    }
  }

  Future<void> _cargarRol() async {
    if (_id == null) return;

    setState(() => _loading = true);

    try {
      final rol = await _apiService.getRolById(_id!);
      setState(() {
        _name = rol['nombre'] ?? '';
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar rol: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      if (_isEdit && _id != null) {
        // Actualizar rol existente
        await _apiService.updateRol(_id!, _name);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rol actualizado correctamente')),
        );
      } else {
        // Crear nuevo rol
        await _apiService.createRol(_name);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rol creado correctamente')),
        );
      }

      setState(() => _loading = false);
      Navigator.of(context).pop(true); // Retornar true para indicar éxito
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar Rol' : 'Crear Rol')),
      body: _loading && _isEdit
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: InputDecoration(labelText: 'Nombre'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nombre requerido' : null,
                      onSaved: (v) => _name = v ?? '',
                    ),
                    SizedBox(height: 20),
                    _loading
                        ? CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _save,
                              child: Text('Guardar'),
                            ),
                          )
                  ],
                ),
              ),
            ),
    );
  }
}
