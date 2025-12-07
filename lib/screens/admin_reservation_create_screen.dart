import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Formulario mejorado de creación de reservas para admin
class AdminReservationCreateScreen extends StatefulWidget {
  static const routeName = '/admin/reservations/create';

  @override
  _AdminReservationCreateScreenState createState() =>
      _AdminReservationCreateScreenState();
}

class _AdminReservationCreateScreenState
    extends State<AdminReservationCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _isLoadingData = true;

  List<dynamic> _clientes = [];
  List<dynamic> _fincas = [];
  List<dynamic> _programaciones = [];
  List<dynamic> _servicios = [];

  int? _selectedClienteId;
  int? _selectedFincaId;
  int? _selectedProgramacionId;
  List<int> _selectedServiciosIds = [];
  DateTime? _selectedDate;
  int _numPersonas = 1;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final clientes = await _apiService.getClientes();
      final fincas = await _apiService.getFincas();
      final programaciones = await _apiService.getProgramaciones();
      final servicios = await _apiService.getServicios();

      setState(() {
        _clientes = clientes;
        _fincas = fincas;
        _programaciones = programaciones;
        _servicios = servicios;
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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona una fecha')),
      );
      return;
    }

    if (_selectedClienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona un cliente')),
      );
      return;
    }

    if (_selectedFincaId == null && _selectedProgramacionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Debes seleccionar al menos una Finca o una Programación')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Formatear fecha
      final fechaFormateada =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      await _apiService.createReserva(
        clienteId: _selectedClienteId!,
        fecha: fechaFormateada,
        programacionId: _selectedProgramacionId,
        fincaId: _selectedFincaId,
        numeroPersonas: _numPersonas,
        serviciosIds:
            _selectedServiciosIds.isNotEmpty ? _selectedServiciosIds : null,
        estado: 'pendiente',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Reserva creada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear reserva: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Reserva'),
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
                      'Crear Nueva Reserva',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Completa los detalles de la reserva',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 24),

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
                      isRequired: true,
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

                    // Servicios (multi-select)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.room_service,
                                    color: Colors.deepPurple),
                                SizedBox(width: 8),
                                Text(
                                  'Servicios Adicionales (Opcional)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _servicios.map((servicio) {
                                final id = servicio['id'] as int;
                                final isSelected =
                                    _selectedServiciosIds.contains(id);
                                return FilterChip(
                                  label:
                                      Text(servicio['nombre'] ?? 'Sin nombre'),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedServiciosIds.add(id);
                                      } else {
                                        _selectedServiciosIds.remove(id);
                                      }
                                    });
                                  },
                                  selectedColor: Colors.deepPurple.shade100,
                                  checkmarkColor: Colors.deepPurple,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
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
                                  iconSize: 32,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.purple.shade200),
                                  ),
                                  child: Text(
                                    '$_numPersonas',
                                    style: TextStyle(
                                      fontSize: 32,
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
                                  iconSize: 32,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Botón de crear
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitReservation,
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'CREAR RESERVA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
