// parte isa
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reservations_provider.dart';
import '../providers/clients_provider.dart';
import '../providers/auth_provider.dart';

class ReservationsEditScreen extends StatefulWidget {
  static const routeName = '/reservations/edit';
  @override
  _ReservationsEditScreenState createState() => _ReservationsEditScreenState();
}

class _ReservationsEditScreenState extends State<ReservationsEditScreen> {
  DateTime? _date;
  TimeOfDay? _time;
  final _detailsCtrl = TextEditingController();
  String? _selectedClientId;

  @override
  void dispose(){ _detailsCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(Duration(days:365)), lastDate: DateTime.now().add(Duration(days: 365)));
    if (d != null) setState(()=> _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(()=> _time = t);
  }

  void _save(){
    final args = ModalRoute.of(context)?.settings.arguments;
    final prov = Provider.of<ReservationsProvider>(context, listen: false);
    if (args is String){
      prov.updateReservation(args, {
        'date': _date?.toLocal().toString().split(' ')[0],
        'time': _time?.format(context),
        'details': _detailsCtrl.text,
        if (_selectedClientId != null && _selectedClientId!.isNotEmpty) 'clientId': _selectedClientId
      }).then((_){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cambios guardados')));
        Navigator.of(context).pop();
      }).catchError((e){
        final msg = e.toString().replaceFirst('Exception: ', '');
        showDialog(context: context, builder: (_)=> AlertDialog(title: Text('Error'), content: Text(msg), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('OK'))]));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (args is String){
      final prov = Provider.of<ReservationsProvider>(context);
      final existing = prov.getById(args);
      if (existing != null){
        _date = DateTime.tryParse(existing['date'] ?? '') ?? _date;
        if (existing['time'] != null) {
          try{
            final parts = (existing['time'] as String).split(':');
            final h = int.tryParse(parts[0]) ?? TimeOfDay.now().hour;
            final m = int.tryParse(parts[1]) ?? TimeOfDay.now().minute;
            _time = TimeOfDay(hour: h, minute: m);
          }catch(_){ }
        }
        _detailsCtrl.text = existing['details'] ?? existing['notes'] ?? '';
        if (_selectedClientId == null && existing['clientId'] != null) {
          _selectedClientId = existing['clientId'] as String;
        }
      }
    }

    // If args is id and current user is a client, ensure they are the owner
    if (args is String) {
      final prov = Provider.of<ReservationsProvider>(context, listen: false);
      final existing = prov.getById(args);
      if (auth.user != null && ((auth.user?.role ?? '').toLowerCase() == 'cliente' || (auth.user?.role ?? '').toLowerCase() == 'client')) {
        if (existing != null && (existing['clientId'] ?? '') != (auth.user?.id ?? '')) {
          return Scaffold(appBar: AppBar(title: Text('Editar Reserva')), body: Center(child: Text('Acceso denegado: esta reserva no pertenece a tu cuenta.')));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Editar Reserva')),
      body: Padding(padding: EdgeInsets.all(16), child: ListView(children:[
        // Mini calendario que muestra días/horas ocupadas en rojo para clientes
        Builder(builder: (ctx){
          final prov = Provider.of<ReservationsProvider>(ctx);
          return Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text('Calendario (días ocupados en rojo)', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height:8),
            _miniCalendar(prov.reservations)
          ])));
        }),

        Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text('Editar reserva', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height:8),
          Row(children:[Expanded(child: OutlinedButton(onPressed: _pickDate, child: Text(_date==null? 'Seleccionar fecha' : _date!.toLocal().toString().split(' ')[0]))), SizedBox(width:8), Expanded(child: OutlinedButton(onPressed: _pickTime, child: Text(_time==null? 'Seleccionar hora' : _time!.format(context))))]),
          SizedBox(height:8),
          Builder(builder: (ctx){ final cp = Provider.of<ClientsProvider>(ctx); final items = cp.clients.map((c)=> DropdownMenuItem<String>(value: c['id'] as String, child: Text(c['name'] ?? c['email'] ?? '-'))).toList(); return DropdownButtonFormField<String>(initialValue: _selectedClientId, items: [DropdownMenuItem<String>(value: '', child: Text('Cliente no asignado')), ...items], onChanged: (v)=> setState(()=> _selectedClientId = (v!=null && v.isNotEmpty)? v : null), decoration: InputDecoration(labelText: 'Cliente')); }),
          SizedBox(height:8),
          TextFormField(controller: _detailsCtrl, maxLines:3, decoration: InputDecoration(labelText: 'Detalles adicionales')),
          SizedBox(height:12),
          Row(children:[Expanded(child: ElevatedButton(onPressed: _save, child: Text('Guardar'))), SizedBox(width:8), OutlinedButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cancelar'))])
        ])))
      ]))
    );
  }

  Widget _miniCalendar(List<Map<String,dynamic>> reservations){
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final first = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month+1, 0).day;

    final Map<int, List<Map<String,dynamic>>> dayRes = {};
    for (var r in reservations){
      final dStr = r['date'] as String?;
      if (dStr == null) continue;
      try{
        final d = DateTime.parse(dStr);
        if (d.year == year && d.month == month){
          // exclude cancelled
          if ((r['status'] ?? '').toString().toLowerCase() == 'cancelada') continue;
          dayRes[d.day] = [...(dayRes[d.day] ?? []), r];
        }
      } catch(_){ }
    }

    final weekdayOffset = first.weekday % 7;
    List<Widget> cells = [];
    for (int i=0;i<weekdayOffset;i++) cells.add(Container());
    for (int d=1; d<=daysInMonth; d++){
      final list = dayRes[d] ?? [];
      final occupied = list.isNotEmpty;
      cells.add(GestureDetector(
        onTap: (){
          if (occupied) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Día ocupado. Horas: ${list.map((r)=> r['time']).join(', ')}')));
          } else {
            setState(()=> _date = DateTime(year, month, d));
          }
        },
        child: Container(
          margin: EdgeInsets.all(4), padding: EdgeInsets.all(6), decoration: BoxDecoration(color: occupied ? Color.fromRGBO(244,67,54,0.18) : Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: occupied ? Colors.red : Colors.grey.shade300)),
          child: Column(children:[ Align(alignment: Alignment.topLeft, child: Text('$d', style: TextStyle(fontWeight: FontWeight.w600))), if (occupied) SizedBox(height:6), if (occupied) Wrap(spacing:4, children: list.take(3).map((r)=> Container(padding: EdgeInsets.symmetric(horizontal:6, vertical:4), decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(6)), child: Text('${r['time'] ?? '-'}', style: TextStyle(color: Colors.white, fontSize:11)))).toList()) ])
        )
      ));
    }

    return Column(children:[ GridView.count(crossAxisCount:7, shrinkWrap: true, physics: NeverScrollableScrollPhysics(), childAspectRatio: 1.1, children: [ for (var wd in ['D','L','M','M','J','V','S']) Center(child: Text(wd, style: TextStyle(fontWeight: FontWeight.w600, fontSize:12))), ...cells ]) ]);
  }
}
