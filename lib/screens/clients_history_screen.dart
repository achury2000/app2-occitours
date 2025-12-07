// parte isa
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clients_provider.dart';
import '../providers/reservations_provider.dart';

class ClientsHistoryScreen extends StatefulWidget {
  static const routeName = '/clients/history';
  @override
  _ClientsHistoryScreenState createState() => _ClientsHistoryScreenState();
}

class _ClientsHistoryScreenState extends State<ClientsHistoryScreen> {
  String? _selectedClientId;

  @override
  Widget build(BuildContext context) {
    final clientsProv = Provider.of<ClientsProvider>(context);
    final resProv = Provider.of<ReservationsProvider>(context);
    if (clientsProv.loading || resProv.loading) return Scaffold(appBar: AppBar(title: Text('Historial del Cliente')), body: Center(child: CircularProgressIndicator()));
    final clients = clientsProv.clients;
    final selected = _selectedClientId == null ? null : clientsProv.getById(_selectedClientId!);

    final clientReservations = selected == null ? [] : resProv.reservations.where((r) => r['clientId'] == selected['id']).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Historial del Cliente')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children:[
          DropdownButtonFormField<String>(
            initialValue: _selectedClientId,
            items: clients.map((c) => DropdownMenuItem<String>(value: c['id'] as String, child: Text(c['name'] ?? c['email'] ?? '-'))).toList(),
            onChanged: (v) => setState(() => _selectedClientId = v),
            decoration: InputDecoration(labelText: 'Seleccionar cliente'),
          ),
          SizedBox(height:12),
          Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('Reservas', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height:8), if (clientReservations.isEmpty) Text('No hay reservas asociadas (si las reservas no tienen clientId, se mostrarán como vacías).') else ...clientReservations.map((r)=> ListTile(title: Text('${r['service'] ?? '-'}'), subtitle: Text('${r['date'] ?? '-'} • ${r['status'] ?? '-'}'))).toList()]))),
          SizedBox(height:12),
          Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('Pagos', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height:8), Text('Pagos y facturación (simulado)')]))) ,
          SizedBox(height:12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exportando (simulado)...'))),
                  child: Text('Exportar informe'),
                ),
              )
            ],
          )
        ])
      ),
    );
  }
}
