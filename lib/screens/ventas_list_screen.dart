import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VentasListScreen extends StatefulWidget {
  static const routeName = '/ventas';

  @override
  _VentasListScreenState createState() => _VentasListScreenState();
}

class _VentasListScreenState extends State<VentasListScreen> {
  final _apiService = ApiService();
  List<dynamic> _ventas = [];
  bool _loading = true;
  String _filter = 'Todas';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadVentas();
  }

  Future<void> _loadVentas() async {
    setState(() => _loading = true);
    try {
      final ventas = await _apiService.getVentas();
      setState(() {
        _ventas = ventas;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar ventas: $e')),
      );
    }
  }

  List<dynamic> _filteredVentas() {
    var filtered = _ventas;

    if (_filter != 'Todas') {
      filtered = filtered
          .where(
              (v) => (v['estado'] ?? '').toLowerCase() == _filter.toLowerCase())
          .toList();
    }

    if (_search.isNotEmpty) {
      final query = _search.toLowerCase();
      filtered = filtered.where((v) {
        final id = v['id'].toString().toLowerCase();
        final clienteNombre =
            (v['cliente_nombre'] ?? '').toString().toLowerCase();
        final asesorNombre =
            (v['asesor_nombre'] ?? '').toString().toLowerCase();
        return id.contains(query) ||
            clienteNombre.contains(query) ||
            asesorNombre.contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> _deleteVenta(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar esta venta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteVenta(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Venta eliminada exitosamente')),
        );
        _loadVentas();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar venta: $e')),
        );
      }
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
    final filtered = _filteredVentas();

    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadVentas,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filter,
                    items: ['Todas', 'Pendiente', 'Completada', 'Cancelada']
                        .map((s) => DropdownMenuItem(child: Text(s), value: s))
                        .toList(),
                    onChanged: (v) => setState(() => _filter = v ?? 'Todas'),
                    decoration:
                        InputDecoration(labelText: 'Filtrar por estado'),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text('Nueva Venta',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () async {
                    final result =
                        await Navigator.of(context).pushNamed('/ventas/create');
                    if (result == true) {
                      _loadVentas();
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No hay ventas',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final venta = filtered[i];
                            final estado =
                                (venta['estado'] ?? 'pendiente').toString();
                            final total = (venta['total'] ?? 0);
                            final numReservas = (venta['num_reservas'] ?? 0);

                            return Card(
                              margin: EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getEstadoColor(estado),
                                  child: Icon(Icons.shopping_bag,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  'Venta #${venta['id']} - ${venta['cliente_nombre'] ?? 'Sin cliente'}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Fecha: ${venta['fecha'] ?? '-'}'),
                                    Text('Reservas: $numReservas'),
                                    Row(
                                      children: [
                                        Text('Estado: '),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getEstadoColor(estado)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            estado.toUpperCase(),
                                            style: TextStyle(
                                              color: _getEstadoColor(estado),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'COP',
                                          style: TextStyle(
                                              fontSize: 10, color: Colors.grey),
                                        ),
                                        Text(
                                          total is String
                                              ? double.parse(total)
                                                  .toStringAsFixed(0)
                                              : (total as num)
                                                  .toStringAsFixed(0),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.teal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 8),
                                    PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'view',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility, size: 20),
                                              SizedBox(width: 8),
                                              Text('Ver detalles'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  size: 20, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Eliminar',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'view') {
                                          Navigator.of(context).pushNamed(
                                            '/ventas/detail',
                                            arguments: venta['id'].toString(),
                                          );
                                        } else if (value == 'delete') {
                                          _deleteVenta(venta['id'].toString());
                                        }
                                      },
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
      ),
    );
  }
}
