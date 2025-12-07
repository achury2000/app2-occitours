// parte isa
// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';

class ReservationsListScreen extends StatefulWidget {
  static const routeName = '/reservations';
  @override
  _ReservationsListScreenState createState() => _ReservationsListScreenState();
}

class _ReservationsListScreenState extends State<ReservationsListScreen> {
  String _filter = 'Todas';
  String _search = '';
  Timer? _debounce;
  List<dynamic> _reservas = [];
  bool _loading = true;

  @override
  void dispose() {
    try {
      _debounce?.cancel();
    } catch (_) {}
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadReservas();
  }

  Future<void> _loadReservas() async {
    setState(() => _loading = true);
    try {
      final apiService = ApiService();
      final data = await apiService.getReservas();
      setState(() {
        _reservas = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar reservas: $e')),
      );
    }
  }

  List<dynamic> _filteredReservas() {
    var filtered = _reservas;

    // Filtrar por estado
    if (_filter != 'Todas') {
      filtered = filtered
          .where(
              (r) => (r['estado'] ?? '').toLowerCase() == _filter.toLowerCase())
          .toList();
    }

    // Filtrar por búsqueda
    if (_search.isNotEmpty) {
      final query = _search.toLowerCase();
      filtered = filtered.where((r) {
        final id = r['id'].toString().toLowerCase();
        final fecha = (r['fecha'] ?? '').toString().toLowerCase();
        final estado = (r['estado'] ?? '').toString().toLowerCase();
        final clienteNombre =
            (r['cliente_nombre'] ?? '').toString().toLowerCase();
        final fincaNombre = (r['finca_nombre'] ?? '').toString().toLowerCase();
        return id.contains(query) ||
            fecha.contains(query) ||
            estado.contains(query) ||
            clienteNombre.contains(query) ||
            fincaNombre.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReservas();

    return Scaffold(
      appBar: AppBar(
        title: Text('Reservas'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReservas,
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
                    initialValue: _filter,
                    items: ['Todas', 'Confirmada', 'Completada', 'Cancelada']
                        .map((s) => DropdownMenuItem(child: Text(s), value: s))
                        .toList(),
                    onChanged: (v) => setState(() => _filter = v ?? 'Todas'),
                    decoration:
                        InputDecoration(labelText: 'Filtrar por estado'),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context)
                        .pushNamed('/reservations/create');
                    if (result == true) {
                      _loadReservas(); // Recargar después de crear
                    }
                  },
                  child: Text('Crear'),
                ),
              ],
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por ID, cliente, fecha, finca...',
              ),
              onChanged: (v) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(Duration(milliseconds: 400), () {
                  setState(() => _search = v.trim());
                });
              },
            ),
            SizedBox(height: 12),
            if (_loading)
              Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Text('No se encontraron reservas'),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final r = filtered[i];
                    final fecha = r['fecha']?.toString().split('T')[0] ?? '';
                    final clienteNombre = r['cliente_nombre'] ?? 'Sin cliente';
                    final fincaNombre = r['finca_nombre'] ?? 'Sin finca';
                    final estado = r['estado'] ?? '';
                    final personas = r['numero_personas'] ?? 0;

                    return Card(
                      child: ListTile(
                        title: Text('Reserva #${r['id']} - $clienteNombre'),
                        subtitle: Text(
                          '$fecha • $fincaNombre • $personas persona(s) • Estado: $estado',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _cancelarReserva(r['id']),
                        ),
                        onTap: () {
                          // Navegar a detalle si existe la ruta
                          // Navigator.of(context).pushNamed('/reservations/detail', arguments: r);
                        },
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

  Future<void> _cancelarReserva(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Cancelar Reserva'),
        content: Text('¿Estás seguro de cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sí'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final apiService = ApiService();
      await apiService.deleteReserva(id.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reserva cancelada')),
      );
      _loadReservas(); // Recargar lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cancelar reserva: $e')),
      );
    }
  }
}
