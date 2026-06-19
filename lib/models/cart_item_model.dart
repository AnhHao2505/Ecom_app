import 'package:e_mart/models/product_model.dart';

class CartItem {
  final Product product;
  final String? selectedColor;
  final String? selectedSize;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
    this.selectedColor,
    this.selectedSize,
  });

  String get id {
    return '${product.id}_${selectedColor ?? ''}_${selectedSize ?? ''}';
  }

  double get lineTotal => product.price * quantity;

  bool hasSameOptions({
    required Product otherProduct,
    String? color,
    String? size,
  }) {
    return product.id == otherProduct.id &&
        selectedColor == color &&
        selectedSize == size;
  }
}
