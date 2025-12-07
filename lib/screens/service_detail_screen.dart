// parte isa
// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/services_provider.dart';

class ServiceDetailScreen extends StatefulWidget {
  static const routeName = '/services/detail';
  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '60');
  final _capacityCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController(text: '0');
  bool _active = true;
  String? _serviceId;

  @override
  void dispose(){
    _nameCtrl.dispose(); _descCtrl.dispose(); _durationCtrl.dispose(); _capacityCtrl.dispose(); _priceCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && _serviceId == null) {
      _serviceId = arg;
      final prov = Provider.of<ServicesProvider>(context, listen: false);
      final s = prov.getById(_serviceId!);
      if (s != null){
        _nameCtrl.text = s.name;
        _descCtrl.text = s.description;
        _durationCtrl.text = s.durationMinutes.toString();
        _capacityCtrl.text = s.capacity.toString();
        _priceCtrl.text = s.price.toString();
        _active = s.active;
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(()=> _saving = true);
    final prov = Provider.of<ServicesProvider>(context, listen: false);
    final data = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'durationMinutes': int.tryParse(_durationCtrl.text) ?? 60,
      'capacity': int.tryParse(_capacityCtrl.text) ?? 1,
      'price': double.tryParse(_priceCtrl.text) ?? 0.0,
      'active': _active,
    };
    try{
      if (_serviceId == null) {
        await prov.addService(data);
      } else {
        await prov.updateService(_serviceId!, data);
      }
      Navigator.of(context).pop();
    } catch (e) {
      await showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Error'), content: Text(e.toString()), actions: [TextButton(onPressed: ()=> Navigator.of(ctx).pop(), child: Text('OK'))]));
    } finally {
      if (mounted) setState(()=> _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _serviceId == null ? 'Crear Servicio' : 'Editar Servicio';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(children:[
            TextFormField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Nombre'), validator: (v) => (v==null||v.trim().isEmpty)? 'Nombre obligatorio' : null),
            SizedBox(height:8),
            TextFormField(controller: _descCtrl, decoration: InputDecoration(labelText: 'Descripción'), maxLines:3),
            SizedBox(height:8),
            TextFormField(controller: _durationCtrl, decoration: InputDecoration(labelText: 'Duración (min)'), keyboardType: TextInputType.number),
            SizedBox(height:8),
            TextFormField(controller: _capacityCtrl, decoration: InputDecoration(labelText: 'Capacidad'), keyboardType: TextInputType.number),
            SizedBox(height:8),
            TextFormField(controller: _priceCtrl, decoration: InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
            SizedBox(height:8),
            SwitchListTile(value: _active, onChanged: (v)=> setState(()=> _active = v), title: Text('Activo')),
            SizedBox(height:12),
            ElevatedButton(onPressed: _saving ? null : _save, child: _saving ? SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2, color: Colors.white)) : Text('Guardar'))
          ])
        )
      ),
    );
  }
}
