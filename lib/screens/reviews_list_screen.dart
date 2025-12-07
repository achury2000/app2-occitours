// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reviews_provider.dart';

class ReviewsListScreen extends StatelessWidget {
  static const routeName = '/reviews';
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ReviewsProvider>(context);
    final items = prov.items;
    return Scaffold(
      appBar: AppBar(title: Text('Reseñas')),
      body: prov.loading ? Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: items.length,
        itemBuilder: (ctx, i){
          final r = items[i];
          return ListTile(
            title: Text('${r.rating} ★ — ${r.comment ?? ''}'),
            subtitle: Text('${r.targetType}: ${r.targetId} • ${r.authorId}'),
            onTap: () => Navigator.of(context).pushNamed('/reviews/detail', arguments: r.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed('/reviews/create'),
      ),
    );
  }
}
