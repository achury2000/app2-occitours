// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reviews_provider.dart';

class ReviewDetailScreen extends StatelessWidget {
  static const routeName = '/reviews/detail';
  final String reviewId;
  ReviewDetailScreen({required this.reviewId});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ReviewsProvider>(context);
    final r = prov.findById(reviewId);
    if (r == null) return Scaffold(appBar: AppBar(title: Text('Reseña')), body: Center(child: Text('No encontrada')));
    return Scaffold(appBar: AppBar(title: Text('Reseña ${r.id}')),
      body: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text('Target: ${r.targetType} • ${r.targetId}'), SizedBox(height:8), Text('Autor: ${r.authorId}'), SizedBox(height:8), Text('Puntuación: ${r.rating}'), SizedBox(height:8), Text('Comentario:'), SizedBox(height:4), Text(r.comment ?? '-'), SizedBox(height:12),
        ElevatedButton(child: Text('Eliminar'), onPressed: () async { final ok = await showDialog<bool>(context: context, builder: (_)=> AlertDialog(title: Text('Confirmar'), content: Text('Eliminar reseña?'), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(false), child: Text('Cancelar')), TextButton(onPressed: ()=> Navigator.of(context).pop(true), child: Text('Eliminar'))])); if (ok==true) { await prov.deleteReview(r.id); Navigator.of(context).pop(); } })
      ])),
    );
  }
}
