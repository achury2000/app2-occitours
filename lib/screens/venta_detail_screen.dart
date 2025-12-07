import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VentaDetailScreen extends StatefulWidget {
  static const routeName = '/ventas/detail';

  @override
  _VentaDetailScreenState createState() => _VentaDetailScreenState();
}

class _VentaDetailScreenState extends State<VentaDetailScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _venta;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ventaId = ModalRoute.of(context)?.settings.arguments as String?;
    if (ventaId != null) {
      _loadVenta(ventaId);
    }
  }

  Future<void> _loadVenta(String id) async {
    setState(() => _loading = true);
    try {
      final venta = await _apiService.getVenta(id);
      setState(() {
        _venta = venta;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar venta: $e')),
      );
    }
  }

  Future<void> _addAbono() async {
    final montoController = TextEditingController();
    final fechaController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0],
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Agregar Abono'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: montoController,
              decoration: InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            TextField(
              controller: fechaController,
              decoration: InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, true);
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final monto = double.parse(montoController.text);
        await _apiService.addAbonoToVenta(
          _venta!['id'].toString(),
          monto: monto,
          fecha: fechaController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abono agregado exitosamente')),
        );
        _loadVenta(_venta!['id'].toString());
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar abono: $e')),
        );
      }
    }
  }

  Future<void> _updateEstado(String nuevoEstado) async {
    try {
      await _apiService.updateVenta(
        _venta!['id'].toString(),
        estado: nuevoEstado,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado exitosamente')),
      );
      _loadVenta(_venta!['id'].toString());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar estado: $e')),
      );
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_venta == null ? 'Cargando...' : 'Venta #${_venta!['id']}'),
        backgroundColor: Colors.teal,
        actions: [
          if (_venta != null)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => _loadVenta(_venta!['id'].toString()),
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _venta == null
              ? Center(child: Text('No se encontró la venta'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info general
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Información General',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getEstadoColor(
                                              _venta!['estado'] ?? 'pendiente')
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      (_venta!['estado'] ?? 'PENDIENTE')
                                          .toString()
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: _getEstadoColor(
                                            _venta!['estado'] ?? 'pendiente'),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              _buildInfoRow(
                                  'Cliente', _venta!['cliente_nombre'] ?? '-'),
                              _buildInfoRow(
                                  'Asesor', _venta!['asesor_nombre'] ?? '-'),
                              _buildInfoRow('Fecha', _venta!['fecha'] ?? '-'),
                              _buildInfoRow(
                                'Total',
                                'COP ${(_venta!['total'] ?? 0).toString()}',
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Cambiar estado
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cambiar Estado',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildEstadoButton('pendiente'),
                                  SizedBox(width: 8),
                                  _buildEstadoButton('completada'),
                                  SizedBox(width: 8),
                                  _buildEstadoButton('cancelada'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Reservas
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reservas Asociadas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              SizedBox(height: 8),
                              if (_venta!['reservas'] == null ||
                                  (_venta!['reservas'] as List).isEmpty)
                                Text('No hay reservas asociadas',
                                    style: TextStyle(color: Colors.grey))
                              else
                                ..._venta!['reservas'].map<Widget>((r) {
                                  return ListTile(
                                    leading: Icon(Icons.calendar_today,
                                        color: Colors.teal),
                                    title: Text('Reserva #${r['id']}'),
                                    subtitle: Text(
                                      'Fecha: ${r['fecha'] ?? '-'} | Estado: ${r['estado'] ?? '-'}',
                                    ),
                                    trailing: Text(
                                      'COP ${(r['precio_total'] ?? 0).toString()}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Abonos
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Abonos',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    icon: Icon(Icons.add, color: Colors.white),
                                    label: Text('Agregar Abono',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                    ),
                                    onPressed: _addAbono,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              if (_venta!['abonos'] == null ||
                                  (_venta!['abonos'] as List).isEmpty)
                                Text('No hay abonos registrados',
                                    style: TextStyle(color: Colors.grey))
                              else
                                ..._venta!['abonos'].map<Widget>((a) {
                                  return ListTile(
                                    leading: Icon(Icons.payment,
                                        color: Colors.green),
                                    title: Text(
                                        'COP ${(a['monto'] ?? 0).toString()}'),
                                    subtitle:
                                        Text('Fecha: ${a['fecha'] ?? '-'}'),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoButton(String estado) {
    final isActive = (_venta!['estado'] ?? '').toLowerCase() == estado;
    return ElevatedButton(
      onPressed: isActive ? null : () => _updateEstado(estado),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? _getEstadoColor(estado) : Colors.grey[300],
        foregroundColor: isActive ? Colors.white : Colors.black,
      ),
      child: Text(estado.toUpperCase()),
    );
  }
}
