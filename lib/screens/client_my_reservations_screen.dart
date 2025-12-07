import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ClientMyReservationsScreen extends StatefulWidget {
  static const routeName = '/client/my-reservations';

  @override
  _ClientMyReservationsScreenState createState() =>
      _ClientMyReservationsScreenState();
}

class _ClientMyReservationsScreenState
    extends State<ClientMyReservationsScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _reservas = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _apiService.setToken(auth.token);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Obtener el cliente_id usando la cédula del usuario
      int clienteId;
      if (auth.user?.cedula != null) {
        final clienteData =
            await _apiService.getClienteByCedula(auth.user!.cedula!);
        clienteId = clienteData['id'];
      } else {
        throw 'No se pudo obtener la cédula del usuario';
      }

      final data = await _apiService.getReservas();
      // Filtrar solo las reservas del cliente actual
      setState(() {
        _reservas = data.where((r) => r['cliente_id'] == clienteId).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar reservas: $e';
        _isLoading = false;
      });
    }
  }

  Color _getEstadoColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'confirmada':
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
        title: Text('Mis Reservas'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(_error!, textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReservations,
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _isLoading
              ? Center(child: CircularProgressIndicator())
              : _reservas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 100,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No tienes reservas',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                                context, '/client/new-reservation'),
                            icon: Icon(Icons.add),
                            label: Text('Crear Reserva'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadReservations,
                      child: ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: _reservas.length,
                        itemBuilder: (ctx, i) {
                          final reserva = _reservas[i];
                          final estado = reserva['estado'] ?? 'pendiente';

                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Encabezado con ID y estado
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.confirmation_number,
                                              color: Colors.blue, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Reserva #${reserva['id']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getEstadoColor(estado)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _getEstadoColor(estado),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(
                                          estado.toUpperCase(),
                                          style: TextStyle(
                                            color: _getEstadoColor(estado),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(height: 24),

                                  // Información de la reserva
                                  _buildInfoRow(
                                    Icons.calendar_today,
                                    'Fecha',
                                    reserva['fecha'] ?? 'No especificada',
                                  ),
                                  SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.people,
                                    'Personas',
                                    '${reserva['numero_personas'] ?? 1}',
                                  ),
                                  if (reserva['precio_total'] != null) ...[
                                    SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.attach_money,
                                      'Precio Total',
                                      '\$${reserva['precio_total']}',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: _reservas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, '/client/new-reservation'),
              icon: Icon(Icons.add),
              label: Text('Nueva Reserva'),
              backgroundColor: Colors.blue.shade700,
            )
          : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
