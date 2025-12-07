// parte isa
// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter/services.dart';

/// Pantalla/Formulario para crear una reserva con integración directa al backend.
class ReservationsCreateScreen extends StatefulWidget {
  static const routeName = '/reservations/create';

  @override
  _ReservationsCreateScreenState createState() =>
      _ReservationsCreateScreenState();
}

class _ReservationsCreateScreenState extends State<ReservationsCreateScreen> {
  final ApiService _apiService = ApiService();

  DateTime? _date;
  TimeOfDay? _time;
  int _people = 2;
  final _notesCtrl = TextEditingController();

  String? _selectedClientId;
  String? _selectedServiceId;
  String? _selectedFincaId;
  String? _selectedRutaId;
  String? _selectedProgramacionId;

  List<dynamic> _clientes = [];
  List<dynamic> _fincas = [];
  List<dynamic> _servicios = [];
  List<dynamic> _rutas = [];
  List<dynamic> _programaciones = [];

  bool _loadingClientes = true;
  bool _loadingFincas = true;
  bool _loadingServicios = true;
  bool _loadingRutas = true;
  bool _loadingProgramaciones = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final results = await Future.wait([
        _apiService.getClientes(),
        _apiService.getFincas(),
        _apiService.getServicios(),
        _apiService.getRutas(),
        _apiService.getProgramaciones(),
      ]);

      setState(() {
        _clientes = results[0];
        _fincas = results[1];
        _servicios = results[2];
        _rutas = results[3];
        _programaciones = results[4];
        _loadingClientes = false;
        _loadingFincas = false;
        _loadingServicios = false;
        _loadingRutas = false;
        _loadingProgramaciones = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() {
        _loadingClientes = false;
        _loadingFincas = false;
        _loadingServicios = false;
        _loadingRutas = false;
        _loadingProgramaciones = false;
      });
      _showError('Error cargando datos: ${e.toString()}');
    }
  }

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

    final dateStr = _date!.toLocal().toString().split(' ')[0];
    final timeStr =
        '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}:00';
    final fechaCompleta = '$dateStr $timeStr';

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      final result = await _apiService.createReserva(
        clienteId: int.parse(_selectedClientId!),
        fecha: fechaCompleta,
        fincaId:
            _selectedFincaId != null ? int.tryParse(_selectedFincaId!) : null,
        programacionId: _selectedProgramacionId != null
            ? int.tryParse(_selectedProgramacionId!)
            : null,
        numeroPersonas: _people,
        estado: 'confirmada',
      );

      Navigator.of(context).pop();

      final reservaId = result['reserva']['id'].toString();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Reserva Confirmada'),
          content: Text('Número de reserva: $reservaId'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
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
      Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(title: Text('Crear Reserva')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // FINCA
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Finca',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    _loadingFincas
                        ? CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            initialValue: _selectedFincaId,
                            items: [
                              DropdownMenuItem(
                                  value: '', child: Text('Seleccionar finca')),
                              ..._fincas.map((f) => DropdownMenuItem(
                                    value: f['id'].toString(),
                                    child: Text(
                                        '${f['nombre']} (Cap: ${f['capacidad']})'),
                                  )),
                            ],
                            onChanged: (v) => setState(() => _selectedFincaId =
                                (v != null && v.isNotEmpty) ? v : null),
                          ),
                  ],
                ),
              ),
            ),

            // RUTA
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ruta', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    _loadingRutas
                        ? CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            initialValue: _selectedRutaId,
                            items: [
                              DropdownMenuItem(
                                  value: '',
                                  child: Text('Seleccionar ruta (opcional)')),
                              ..._rutas.map((r) => DropdownMenuItem(
                                    value: r['id'].toString(),
                                    child: Text(
                                        '${r['nombre']} (${r['duracion_horas']}h)'),
                                  )),
                            ],
                            onChanged: (v) => setState(() => _selectedRutaId =
                                (v != null && v.isNotEmpty) ? v : null),
                          ),
                  ],
                ),
              ),
            ),

            // PROGRAMACIÓN
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Programación',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    _loadingProgramaciones
                        ? CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            initialValue: _selectedProgramacionId,
                            items: [
                              DropdownMenuItem(
                                  value: '',
                                  child: Text(
                                      'Seleccionar programación (opcional)')),
                              ..._programaciones.map((p) => DropdownMenuItem(
                                    value: p['id'].toString(),
                                    child: Text(
                                        '${p['fecha']} - ${p['hora']} (Guía: ${p['guia_nombre'] ?? 'N/A'})'),
                                  )),
                            ],
                            onChanged: (v) => setState(() =>
                                _selectedProgramacionId =
                                    (v != null && v.isNotEmpty) ? v : null),
                          ),
                  ],
                ),
              ),
            ),

            // SERVICIO
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Servicio',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    _loadingServicios
                        ? CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            initialValue: _selectedServiceId,
                            items: [
                              DropdownMenuItem(
                                  value: '',
                                  child:
                                      Text('Seleccionar servicio (opcional)')),
                              ..._servicios.map((s) => DropdownMenuItem(
                                    value: s['id'].toString(),
                                    child: Text(
                                        '${s['nombre']} - \$${s['precio']}'),
                                  )),
                            ],
                            onChanged: (v) => setState(() =>
                                _selectedServiceId =
                                    (v != null && v.isNotEmpty) ? v : null),
                          ),
                  ],
                ),
              ),
            ),

            // CLIENTE
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cliente',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    _loadingClientes
                        ? CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            initialValue: _selectedClientId,
                            items: [
                              DropdownMenuItem(
                                  value: '',
                                  child: Text('Seleccionar cliente')),
                              ..._clientes.map((c) => DropdownMenuItem(
                                    value: c['id'].toString(),
                                    child: Text(
                                        '${c['nombre']} (${c['email'] ?? c['cedula'] ?? ''})'),
                                  )),
                            ],
                            onChanged: (v) => setState(() => _selectedClientId =
                                (v != null && v.isNotEmpty) ? v : null),
                          ),
                  ],
                ),
              ),
            ),

            // FECHA, HORA, PERSONAS
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
                          .map((n) =>
                              DropdownMenuItem(value: n, child: Text('$n')))
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
                        child: Text('Confirmar Reserva'),
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
