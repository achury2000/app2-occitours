import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminReservationEditScreen extends StatefulWidget {
  static const routeName = '/admin/reservations/edit';

  @override
  _AdminReservationEditScreenState createState() =>
      _AdminReservationEditScreenState();
}

class _AdminReservationEditScreenState
    extends State<AdminReservationEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _isLoadingData = true;

  List<dynamic> _clientes = [];
  List<dynamic> _fincas = [];
  List<dynamic> _programaciones = [];

  int? _selectedClienteId;
  int? _selectedFincaId;
  int? _selectedProgramacionId;
  DateTime? _selectedDate;
  int _numPersonas = 1;
  String _selectedEstado = 'pendiente';

  dynamic _reservaOriginal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reservaOriginal == null) {
      _reservaOriginal = ModalRoute.of(context)?.settings.arguments;
      if (_reservaOriginal != null) {
        _loadInitialData();
      }
    }
  }

  Future<void> _loadInitialData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _apiService.setToken(auth.token);

    try {
      final clientes = await _apiService.getClientes();
      final fincas = await _apiService.getFincas();
      final programaciones = await _apiService.getProgramaciones();

      setState(() {
        _clientes = clientes;
        _fincas = fincas;
        _programaciones = programaciones;

        // Cargar datos de la reserva original
        _selectedClienteId = _reservaOriginal['cliente_id'];
        _selectedFincaId = _reservaOriginal['finca_id'];
        _selectedProgramacionId = _reservaOriginal['programacion_id'];
        _numPersonas = _reservaOriginal['numero_personas'] ?? 1;
        _selectedEstado = _reservaOriginal['estado'] ?? 'pendiente';

        // Parsear fecha
        if (_reservaOriginal['fecha'] != null) {
          _selectedDate = DateTime.parse(
              _reservaOriginal['fecha'].toString().split('T')[0]);
        }

        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona una fecha')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _apiService.setToken(auth.token);

      // Formatear fecha
      final fechaFormateada =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      await _apiService.updateReserva(
        _reservaOriginal['id'].toString(),
        clienteId: _selectedClienteId,
        fecha: fechaFormateada,
        programacionId: _selectedProgramacionId,
        fincaId: _selectedFincaId,
        numeroPersonas: _numPersonas,
        estado: _selectedEstado,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Reserva actualizada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar reserva: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Reserva #${_reservaOriginal?['id'] ?? ''}'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: _isLoadingData
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Datos de la Reserva',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Estado
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Estado de la Reserva',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedEstado,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'pendiente',
                                  child: Row(
                                    children: [
                                      Icon(Icons.pending,
                                          color: Colors.orange, size: 20),
                                      SizedBox(width: 8),
                                      Text('Pendiente'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'confirmada',
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.green, size: 20),
                                      SizedBox(width: 8),
                                      Text('Confirmada'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'completada',
                                  child: Row(
                                    children: [
                                      Icon(Icons.done_all,
                                          color: Colors.blue, size: 20),
                                      SizedBox(width: 8),
                                      Text('Completada'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'cancelada',
                                  child: Row(
                                    children: [
                                      Icon(Icons.cancel,
                                          color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text('Cancelada'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedEstado = val!),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Cliente
                    _buildDropdown(
                      label: 'Cliente',
                      icon: Icons.person,
                      value: _selectedClienteId,
                      items: _clientes
                          .map((c) => DropdownMenuItem<int>(
                                value: c['id'] as int,
                                child: Text(c['nombre'] ?? 'Sin nombre'),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedClienteId = val),
                    ),
                    SizedBox(height: 16),

                    // Finca
                    _buildDropdown(
                      label: 'Finca (Opcional)',
                      icon: Icons.home,
                      value: _selectedFincaId,
                      items: _fincas
                          .map((f) => DropdownMenuItem<int>(
                                value: f['id'] as int,
                                child: Text(f['nombre'] ?? 'Sin nombre'),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedFincaId = val),
                      isRequired: false,
                    ),
                    SizedBox(height: 16),

                    // Programación
                    _buildDropdown(
                      label: 'Programación (Opcional)',
                      icon: Icons.event,
                      value: _selectedProgramacionId,
                      items: _programaciones
                          .map((p) => DropdownMenuItem<int>(
                                value: p['id'] as int,
                                child: Text(
                                    '${p['fecha']} - ${p['hora']} (Guía: ${p['guia_nombre'] ?? 'N/A'})'),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedProgramacionId = val),
                      isRequired: false,
                    ),
                    SizedBox(height: 16),

                    // Fecha
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.blue),
                        title: Text('Fecha'),
                        subtitle: Text(
                          _selectedDate == null
                              ? 'Selecciona una fecha'
                              : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _selectDate,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Número de personas
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people, color: Colors.purple),
                                SizedBox(width: 8),
                                Text(
                                  'Número de Personas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: _numPersonas > 1
                                      ? () => setState(() => _numPersonas--)
                                      : null,
                                  color: Colors.red,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$_numPersonas',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () =>
                                      setState(() => _numPersonas++),
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Botón de guardar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'GUARDAR CAMBIOS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required Function(int?) onChanged,
    bool isRequired = true,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: DropdownButtonFormField<int>(
          value: value,
          decoration: InputDecoration(
            labelText: isRequired ? label : '$label (Opcional)',
            prefixIcon: Icon(icon),
            border: InputBorder.none,
          ),
          items: items,
          onChanged: onChanged,
          validator: isRequired
              ? (val) => val == null ? 'Selecciona $label' : null
              : null,
        ),
      ),
    );
  }
}
