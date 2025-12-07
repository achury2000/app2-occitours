import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  String? selectedVariant;

  CartItem({required this.product, this.quantity = 1, this.selectedVariant});
}
