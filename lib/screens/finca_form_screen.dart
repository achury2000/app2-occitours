// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/finca.dart';
import '../providers/fincas_provider.dart';
import '../providers/services_provider.dart';


class FincaFormScreen extends StatefulWidget {
  final Finca? finca;
  FincaFormScreen({this.finca});
  @override
  _FincaFormScreenState createState() => _FincaFormScreenState();
}

class _FincaFormScreenState extends State<FincaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _locCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _capacityCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _latCtrl;
  late TextEditingController _lngCtrl;
  List<String> _selectedServices = [];
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.finca?.code ?? '');
    _nameCtrl = TextEditingController(text: widget.finca?.name ?? '');
    _locCtrl = TextEditingController(text: widget.finca?.location ?? '');
    _priceCtrl = TextEditingController(text: widget.finca?.pricePerNight.toString() ?? '0');
    _capacityCtrl = TextEditingController(text: widget.finca?.capacity.toString() ?? '0');
    _descCtrl = TextEditingController(text: widget.finca?.description ?? '');
    _latCtrl = TextEditingController(text: widget.finca?.latitude?.toString() ?? '');
    _lngCtrl = TextEditingController(text: widget.finca?.longitude?.toString() ?? '');
    _selectedServices = List<String>.from(widget.finca?.serviceIds ?? []);
    _active = widget.finca?.active ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _locCtrl.dispose();
    _priceCtrl.dispose();
    _capacityCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(()=>_saving=true);
    final prov = Provider.of<FincasProvider>(context, listen: false);
    final id = widget.finca?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final f = Finca(
      id: id,
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locCtrl.text.trim(),
      capacity: int.tryParse(_capacityCtrl.text) ?? 0,
      pricePerNight: double.tryParse(_priceCtrl.text) ?? 0.0,
      latitude: double.tryParse(_latCtrl.text),
      longitude: double.tryParse(_lngCtrl.text),
      serviceIds: _selectedServices,
      active: _active,
    );
    try {
      if (widget.finca == null) await prov.addFinca(f, actor: {'id':'system'}); else await prov.updateFinca(f, actor: {'id':'system'});
      Navigator.of(context).pop();
    } catch (e) {
      await showDialog(context: context, builder: (ctx)=>AlertDialog(title: Text('Error'), content: Text(e.toString()), actions: [TextButton(onPressed: ()=>Navigator.of(ctx).pop(), child: Text('OK'))]));
    } finally { if (mounted) setState(()=>_saving=false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.finca == null ? 'Crear Finca' : 'Editar Finca')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            TextFormField(controller: _codeCtrl, decoration: InputDecoration(labelText: 'Código'), validator: (v)=> (v==null||v.trim().isEmpty)?'El código es obligatorio':null),
            SizedBox(height:8),
            TextFormField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Nombre'), validator: (v)=> (v==null||v.trim().isEmpty)?'El nombre es obligatorio':null),
            SizedBox(height:8),
            TextFormField(controller: _descCtrl, decoration: InputDecoration(labelText: 'Descripción'), maxLines: 3),
            SizedBox(height:8),
            TextFormField(controller: _locCtrl, decoration: InputDecoration(labelText: 'Ubicación')),
            SizedBox(height:8),
            Row(children: [Expanded(child: TextFormField(controller: _latCtrl, decoration: InputDecoration(labelText: 'Latitud'), keyboardType: TextInputType.number)), SizedBox(width:8), Expanded(child: TextFormField(controller: _lngCtrl, decoration: InputDecoration(labelText: 'Longitud'), keyboardType: TextInputType.number))]),
            SizedBox(height:8),
            TextFormField(controller: _capacityCtrl, decoration: InputDecoration(labelText: 'Capacidad'), keyboardType: TextInputType.number),
            SizedBox(height:8),
            TextFormField(controller: _priceCtrl, decoration: InputDecoration(labelText: 'Precio por noche'), keyboardType: TextInputType.number),
            SizedBox(height:12),
            Consumer<ServicesProvider>(builder: (ctx, sp, _) {
              final services = sp.search();
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Servicios disponibles'), SizedBox(height:6), Wrap(spacing:8, children: services.map((s) => FilterChip(label: Text(s.name), selected: _selectedServices.contains(s.id), onSelected: (sel){ setState((){ if (sel) _selectedServices.add(s.id); else _selectedServices.remove(s.id); }); })).toList())]);
            }),
            SizedBox(height:12),
            Row(children: [Text('Activo'), Switch(value: _active, onChanged: (v)=> setState(()=>_active = v)), Spacer(), ElevatedButton(onPressed: _saving?null:_save, child: _saving?CircularProgressIndicator(color: Colors.white):Text('Guardar'))]),
          ],),
        ),
      ),
    );
  }
}
