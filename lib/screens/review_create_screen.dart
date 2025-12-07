// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/reviews_provider.dart';
import '../models/review.dart';

class ReviewCreateScreen extends StatefulWidget {
  static const routeName = '/reviews/create';
  @override
  _ReviewCreateScreenState createState() => _ReviewCreateScreenState();
}

class _ReviewCreateScreenState extends State<ReviewCreateScreen> {
  final _form = GlobalKey<FormState>();
  String _targetId = '';
  String _targetType = 'finca';
  String _authorId = '';
  int _rating = 5;
  String _comment = '';
  bool _loading = false;

  void _save() async {
    final valid = _form.currentState?.validate() ?? false;
    if (!valid) return;
    _form.currentState?.save();
    setState(()=> _loading = true);
    final id = Uuid().v4();
    final review = Review(id: id, targetId: _targetId, targetType: _targetType, authorId: _authorId, rating: _rating, comment: _comment);
    try{
      await Provider.of<ReviewsProvider>(context, listen:false).addReview(review);
      Navigator.of(context).pop(true);
    }catch(e){
      showDialog(context: context, builder: (_)=> AlertDialog(title: Text('Error'), content: Text(e.toString()), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cerrar'))]));
    }
    setState(()=> _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Crear Reseña')),
      body: Padding(padding: EdgeInsets.all(12), child: Form(key: _form, child: ListView(children:[
        TextFormField(decoration: InputDecoration(labelText: 'Target ID (finca/servicio)'), validator: (v) => (v==null||v.trim().isEmpty)? 'Requerido' : null, onSaved: (v)=> _targetId = v!.trim()),
            DropdownButtonFormField<String>(initialValue: _targetType, items: ['finca','service'].map((t)=> DropdownMenuItem(child: Text(t), value: t)).toList(), onChanged: (v)=> setState(()=> _targetType = v ?? _targetType), decoration: InputDecoration(labelText: 'Tipo')),
        TextFormField(decoration: InputDecoration(labelText: 'Autor ID'), validator: (v) => (v==null||v.trim().isEmpty)? 'Requerido' : null, onSaved: (v)=> _authorId = v!.trim()),
            DropdownButtonFormField<int>(initialValue: _rating, items: [5,4,3,2,1].map((n)=> DropdownMenuItem(child: Text('$n'), value: n)).toList(), onChanged: (v)=> setState(()=> _rating = v ?? _rating), decoration: InputDecoration(labelText: 'Puntuación')),
        TextFormField(decoration: InputDecoration(labelText: 'Comentario (opcional)'), maxLines: 3, onSaved: (v)=> _comment = v?.trim() ?? ''),
        SizedBox(height:12),
        _loading ? Center(child: CircularProgressIndicator()) : ElevatedButton(child: Text('Guardar'), onPressed: _save)
      ]))),
    );
  }
}
