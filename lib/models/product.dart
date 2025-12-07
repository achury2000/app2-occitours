import 'dart:convert';

class Product {
  final String id;
  final String code;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final List<String> variants; // e.g., sizes/colors
  final double popularity; // simple score

  Product({required this.id, required this.code, required this.name, required this.description, required this.price, required this.imageUrl, required this.category, required this.stock, this.variants = const [], this.popularity = 0});

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'stock': stock,
        'variants': variants,
        'popularity': popularity,
      };

  factory Product.fromJson(Map<String, dynamic> map) => Product(
        id: map['id'] as String,
        code: map['code'] as String? ?? '',
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        price: (map['price'] is int) ? (map['price'] as int).toDouble() : (map['price'] as double? ?? 0.0),
        imageUrl: map['imageUrl'] as String? ?? '',
        category: map['category'] as String? ?? '',
        stock: map['stock'] is int ? map['stock'] as int : int.tryParse('${map['stock']}') ?? 0,
        variants: (map['variants'] as List?)?.map((e) => e as String).toList() ?? [],
        popularity: (map['popularity'] is int) ? (map['popularity'] as int).toDouble() : (map['popularity'] as double? ?? 0.0),
      );

  static String encodeList(List<Product> items) => json.encode(items.map((e) => e.toJson()).toList());

  static List<Product> decodeList(String source) {
    final list = json.decode(source) as List<dynamic>;
    return list.map((m) => Product.fromJson(m as Map<String, dynamic>)).toList();
  }
}
