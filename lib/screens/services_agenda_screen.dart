// parte isa
// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/services_provider.dart';
import '../providers/reservations_provider.dart';

class ServicesAgendaScreen extends StatefulWidget {
  static const routeName = '/services/agenda';
  @override
  _ServicesAgendaScreenState createState() => _ServicesAgendaScreenState();
}

class _ServicesAgendaScreenState extends State<ServicesAgendaScreen> {
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final servicesProv = Provider.of<ServicesProvider>(context);
    final reservProv = Provider.of<ReservationsProvider>(context);
    final services = servicesProv.services;
    final todayStr = _date.toIso8601String().split('T').first;
    return Scaffold(
      appBar: AppBar(title: Text('Agenda de Servicios')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children:[
          Row(children:[
            IconButton(icon: Icon(Icons.chevron_left), onPressed: ()=> setState(()=> _date = _date.subtract(Duration(days:1)))),
            Expanded(child: Center(child: Text('${_date.toLocal().toIso8601String().split('T').first}'))),
            IconButton(icon: Icon(Icons.chevron_right), onPressed: ()=> setState(()=> _date = _date.add(Duration(days:1)))),
          ]),
          SizedBox(height:12),
          Expanded(child: ListView.separated(
            itemCount: services.length,
            separatorBuilder: (_,__)=> SizedBox(height:8),
            itemBuilder: (ctx,i){
              final s = services[i];
              final todays = reservProv.search(service: s.name, from: DateTime.parse(todayStr), to: DateTime.parse(todayStr));
              return Card(
                child: ListTile(
                  title: Text(s.name),
                  subtitle: Text('${s.durationMinutes} min • ${s.capacity} pax • ${todays.length} reservas hoy'),
                  onTap: () => showDialog(context: context, builder: (ctx) {
                    final items = todays.map((r) => ListTile(title: Text(r['time'] ?? ''), subtitle: Text('Cliente: ${r['clientId'] ?? ''}'))).toList();
                    return AlertDialog(
                      title: Text(s.name),
                      content: SizedBox(width: 300, child: Column(mainAxisSize: MainAxisSize.min, children: items)),
                      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cerrar'))],
                    );
                  }),
                ),
              );
            }
          ))
        ])
      ),
    );
  }
}
