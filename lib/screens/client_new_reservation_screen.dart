import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ClientNewReservationScreen extends StatefulWidget {
  static const routeName = '/client/new-reservation';

  @override
  _ClientNewReservationScreenState createState() =>
      _ClientNewReservationScreenState();
}

class _ClientNewReservationScreenState
    extends State<ClientNewReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _isLoadingData = true;

  List<dynamic> _fincas = [];
  List<dynamic> _programaciones = [];
  List<dynamic> _servicios = [];

  int? _selectedFincaId;
  int? _selectedProgramacionId;
  List<int> _selectedServiciosIds = [];

  DateTime? _selectedDate;
  int _numPersonas = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _apiService.setToken(auth.token);

    try {
      final fincas = await _apiService.getFincas();
      final programaciones = await _apiService.getProgramaciones();
      final servicios = await _apiService.getServicios();

      setState(() {
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
      initialDate: DateTime.now(),
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

    // Validar que al menos finca o programación esté seleccionada
    if (_selectedFincaId == null && _selectedProgramacionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecciona al menos una Finca o una Programación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _apiService.setToken(auth.token);

      // Obtener el cliente_id usando la cédula del usuario
      int clienteId;
      if (auth.user?.cedula != null) {
        final clienteData =
            await _apiService.getClienteByCedula(auth.user!.cedula!);
        clienteId = clienteData['id'];
      } else {
        throw 'No se pudo obtener la cédula del usuario';
      }

      // Formatear fecha como YYYY-MM-DD
      final fechaFormateada =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      // Preparar servicios con estructura esperada por la API
      List<Map<String, dynamic>>? serviciosData;
      if (_selectedServiciosIds.isNotEmpty) {
        serviciosData = _selectedServiciosIds.map((id) {
          final servicio = _servicios.firstWhere((s) => s['id'] == id);
          return {
            'servicio_id': id,
            'cantidad': 1,
            'precio_unitario': servicio['precio'],
          };
        }).toList();
      }

      // Crear reserva
      await _apiService.createReserva(
        clienteId: clienteId,
        fecha: fechaFormateada,
        programacionId: _selectedProgramacionId,
        fincaId: _selectedFincaId,
        numeroPersonas: _numPersonas,
        servicios: serviciosData,
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
        backgroundColor: Colors.blue.shade700,
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
                    // Título
                    Text(
                      'Completa los datos de tu reserva',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Selecciona una Finca o una Programación (o ambas)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Finca
                    _buildDropdown(
                      label: 'Finca',
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

                    // Programación (incluye la ruta automáticamente)
                    _buildDropdown(
                      label: 'Programación de Tour',
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

                    // Servicios adicionales
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.orange),
                                SizedBox(width: 8),
                                Text(
                                  'Servicios Adicionales',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _servicios.map((s) {
                                final isSelected =
                                    _selectedServiciosIds.contains(s['id']);
                                return FilterChip(
                                  label:
                                      Text('${s['nombre']} (\$${s['precio']})'),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedServiciosIds.add(s['id']);
                                      } else {
                                        _selectedServiciosIds.remove(s['id']);
                                      }
                                    });
                                  },
                                  selectedColor: Colors.orange.shade100,
                                  checkmarkColor: Colors.orange.shade700,
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

                    // Botón de enviar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitReservation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
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
                              'CREAR RESERVA',
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
    bool isRequired = false,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: DropdownButtonFormField<int>(
          value: value,
          decoration: InputDecoration(
            labelText: isRequired ? '$label *' : '$label (Opcional)',
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
