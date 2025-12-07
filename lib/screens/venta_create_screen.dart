import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VentaCreateScreen extends StatefulWidget {
  static const routeName = '/ventas/create';

  @override
  _VentaCreateScreenState createState() => _VentaCreateScreenState();
}

class _VentaCreateScreenState extends State<VentaCreateScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Form fields
  int? _selectedClienteId;
  DateTime _selectedDate = DateTime.now();
  String _selectedEstado = 'pendiente';
  List<int> _selectedReservasIds = [];

  // Data lists
  List<dynamic> _clientes = [];
  List<dynamic> _reservasSinVenta = [];

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final clientes = await _apiService.getClientes();
      final reservas = await _apiService.getReservas();

      // Filtrar solo reservas sin venta_id y confirmadas
      final reservasSinVenta = reservas
          .where((r) =>
              r['venta_id'] == null &&
              (r['estado'] ?? '').toLowerCase() == 'confirmada')
          .toList();

      setState(() {
        _clientes = clientes;
        _reservasSinVenta = reservasSinVenta;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  List<dynamic> _getReservasForCliente() {
    if (_selectedClienteId == null) return [];
    return _reservasSinVenta
        .where((r) => r['cliente_id'] == _selectedClienteId)
        .toList();
  }

  double _calcularTotal() {
    double total = 0;
    for (var id in _selectedReservasIds) {
      final reserva = _reservasSinVenta.firstWhere((r) => r['id'] == id);
      final precio = reserva['precio_total'] ?? 0;
      if (precio is String) {
        total += double.parse(precio);
      } else {
        total += (precio as num).toDouble();
      }
    }
    return total;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona un cliente')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final total = _calcularTotal();
      final fecha = _selectedDate.toIso8601String().split('T')[0];

      await _apiService.createVenta(
        clienteId: _selectedClienteId!,
        fecha: fecha,
        total: total,
        estado: _selectedEstado,
        reservasIds: _selectedReservasIds.isEmpty ? null : _selectedReservasIds,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Venta creada exitosamente')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear venta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservasDelCliente = _getReservasForCliente();
    final total = _calcularTotal();

    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Venta'),
        backgroundColor: Colors.teal,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cliente selector
                    DropdownButtonFormField<int>(
                      value: _selectedClienteId,
                      decoration: InputDecoration(
                        labelText: 'Cliente *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      items: _clientes
                          .map((c) => DropdownMenuItem<int>(
                                value: c['id'],
                                child: Text(c['nombre'] ?? 'Sin nombre'),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedClienteId = v;
                          _selectedReservasIds
                              .clear(); // Reset reservas selection
                        });
                      },
                      validator: (v) =>
                          v == null ? 'Por favor selecciona un cliente' : null,
                    ),
                    SizedBox(height: 16),

                    // Fecha
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.calendar_today, color: Colors.teal),
                      title: Text('Fecha'),
                      subtitle: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: ElevatedButton.icon(
                        icon: Icon(Icons.edit, color: Colors.white, size: 18),
                        label: Text('Cambiar',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 8),

                    // Estado
                    DropdownButtonFormField<String>(
                      value: _selectedEstado,
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.info),
                        border: OutlineInputBorder(),
                      ),
                      items: ['pendiente', 'completada', 'cancelada']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedEstado = v!),
                    ),
                    SizedBox(height: 16),

                    // Reservas disponibles
                    if (_selectedClienteId != null) ...[
                      Text(
                        'Reservas Confirmadas Disponibles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (reservasDelCliente.isEmpty)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'No hay reservas confirmadas sin venta para este cliente',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: reservasDelCliente.length,
                            itemBuilder: (ctx, i) {
                              final reserva = reservasDelCliente[i];
                              final id = reserva['id'];
                              final isSelected =
                                  _selectedReservasIds.contains(id);
                              final precio = reserva['precio_total'] ?? 0;
                              final precioStr = precio is String
                                  ? double.parse(precio).toStringAsFixed(0)
                                  : (precio as num).toStringAsFixed(0);

                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedReservasIds.add(id);
                                    } else {
                                      _selectedReservasIds.remove(id);
                                    }
                                  });
                                },
                                title: Text('Reserva #$id'),
                                subtitle: Text(
                                  'Fecha: ${reserva['fecha'] ?? '-'} | Personas: ${reserva['num_personas'] ?? 1}',
                                ),
                                secondary: Text(
                                  'COP $precioStr',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 16),

                      // Total calculado
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total de la Venta:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'COP ${total.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 24),

                    // Submit button
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _submitting
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              'CREAR VENTA',
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
}
