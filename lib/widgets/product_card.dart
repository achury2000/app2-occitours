import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/product-detail', arguments: product.id),
      child: Container(
        margin: EdgeInsets.symmetric(vertical:8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Color.fromRGBO(0,0,0,0.06), blurRadius: 8, offset: Offset(0,4))],
        ),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)), child: Image.network(product.imageUrl, width: 96, height:96, fit: BoxFit.cover, errorBuilder: (c,s,t)=>Container(width:96,height:96,color:Colors.grey[200],child: Icon(Icons.image_not_supported)))),
          Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal:12, vertical:10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height:6),
            Text('${product.category} • COP ${product.price.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[700])),
          ]))),
          Padding(padding: EdgeInsets.only(right:12), child: Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 18))
        ]),
      ),
    );
  }
}
