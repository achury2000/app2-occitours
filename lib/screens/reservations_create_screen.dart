// parte isa
// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clients_provider.dart';
import '../providers/services_provider.dart';
import '../providers/fincas_provider.dart';
import '../services/api_service.dart';
import 'package:flutter/services.dart';

/// Pantalla/Formulario para crear una reserva.
///
/// Responsabilidades:
/// - Recolectar datos (finca, servicio, cliente, fecha/hora, número de personas y notas) y validar disponibilidad.
/// - Al confirmar, crea la reserva via backend API y muestra confirmación/copiado.
///
/// Herencia / Overrides:
/// - `StatefulWidget` con lógica en `_ReservationsCreateScreenState`, usa pickers de fecha y hora.
class ReservationsCreateScreen extends StatefulWidget {
  static const routeName = '/reservations/create';
  @override
  _ReservationsCreateScreenState createState() =>
      _ReservationsCreateScreenState();
}

class _ReservationsCreateScreenState extends State<ReservationsCreateScreen> {
  DateTime? _date;
  TimeOfDay? _time;
  int _people = 2;
  final _notesCtrl = TextEditingController();
  String? _selectedClientId;
  String? _selectedServiceId;
  String? _fincaId;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => _time = t);
  }

  Future<void> _confirm() async {
    // Validaciones básicas
    if (_date == null) {
      _showError('Por favor selecciona una fecha');
      return;
    }

    if (_time == null) {
      _showError('Por favor selecciona una hora');
      return;
    }

    if (_selectedClientId == null) {
      _showError('Por favor selecciona un cliente');
      return;
    }

    // Preparar fecha en formato ISO (YYYY-MM-DD HH:MM:SS)
    final dateStr = _date!.toLocal().toString().split(' ')[0];
    final timeStr =
        '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}:00';
    final fechaCompleta = '$dateStr $timeStr';

    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      // Llamar API para crear reserva
      final apiService = ApiService();
      final result = await apiService.createReserva(
        clienteId: int.parse(_selectedClientId!),
        fecha: fechaCompleta,
        fincaId: _fincaId != null ? int.tryParse(_fincaId!) : null,
        numeroPersonas: _people,
        estado: 'confirmada',
      );

      // Cerrar loading
      Navigator.of(context).pop();

      // Obtener número de reserva
      final reservaId = result['reserva']['id'].toString();

      // Mostrar confirmación
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Reserva Confirmada'),
          content: Text('Número de reserva: $reservaId'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true); // Regresar a lista
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: reservaId));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Número copiado')),
                );
              },
              child: Text('Copiar'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Cerrar loading si está abierto
      Navigator.of(context).pop();

      // Mostrar error
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showError(msg);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && (_fincaId == null || _fincaId != arg)) {
      _fincaId = arg;
    }
    return Scaffold(
      appBar: AppBar(title: Text('Crear Reserva')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            if (_fincaId != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Finca seleccionada',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 8),
                      Consumer<FincasProvider>(
                        builder: (ctx, fp, _) {
                          final f = fp.findById(_fincaId!);
                          if (f == null) return Text('Finca no encontrada');
                          return Text('${f.name} • ${f.location}');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Servicio',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Builder(
                      builder: (ctx) {
                        final sp = Provider.of<ServicesProvider>(ctx);
                        final fp = Provider.of<FincasProvider>(ctx);
                        List services;
                        if (_fincaId != null) {
                          try {
                            final f = fp.findById(_fincaId!);
                            if (f != null) {
                              services = f.serviceIds
                                  .map((id) => sp.getById(id))
                                  .where((s) => s != null)
                                  .map((s) => s!)
                                  .toList();
                            } else {
                              services = sp.search();
                            }
                          } catch (_) {
                            services = sp.search();
                          }
                        } else
                          services = sp.search();
                        final items = services
                            .map<DropdownMenuItem<String>>(
                              (s) => DropdownMenuItem(
                                  value: s.id, child: Text(s.name)),
                            )
                            .toList();
                        return DropdownButtonFormField<String>(
                          value: _selectedServiceId,
                          items: [
                            DropdownMenuItem(
                                value: '', child: Text('Seleccionar servicio')),
                            ...items
                          ],
                          onChanged: (v) => setState(() => _selectedServiceId =
                              (v != null && v.isNotEmpty) ? v : null),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cliente',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Builder(
                      builder: (ctx) {
                        final prov = Provider.of<ClientsProvider>(ctx);
                        if (prov.loading)
                          return SizedBox(
                            height: 48,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        final items = prov.clients
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c['id'] as String,
                                child:
                                    Text('${c['name']} (${c['email'] ?? ''})'),
                              ),
                            )
                            .toList();
                        return DropdownButtonFormField<String>(
                          value: _selectedClientId,
                          items: [
                            DropdownMenuItem<String>(
                                value: '', child: Text('Seleccionar cliente')),
                            ...items
                          ],
                          onChanged: (v) => setState(() => _selectedClientId =
                              (v != null && v.isNotEmpty) ? v : null),
                          decoration: InputDecoration(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selecciona fecha y hora',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: Icon(Icons.calendar_today),
                            label: Text(_date == null
                                ? 'Elegir fecha'
                                : _date!.toLocal().toString().split(' ')[0]),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickTime,
                            icon: Icon(Icons.access_time),
                            label: Text(_time == null
                                ? 'Elegir hora'
                                : _time!.format(context)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text('Número de personas',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 6),
                    DropdownButton<int>(
                      value: _people,
                      items: [1, 2, 3, 4, 5, 6, 8, 10]
                          .map(
                            (n) =>
                                DropdownMenuItem(value: n, child: Text('$n')),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _people = v ?? 2),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration:
                          InputDecoration(labelText: 'Notas / Requerimientos'),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                'Validación de disponibilidad se realizará al confirmar')),
                      ],
                    ),
                    SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirm,
                        child: Text('Confirmar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
