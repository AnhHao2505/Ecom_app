import 'package:e_mart/models/product_model.dart';

class CartItem {
  final Product product;
  final String? selectedColor;
  final String? selectedSize;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedColor,
    this.selectedSize,
  });

  String get id {
    return '${product.id}_${selectedColor ?? ''}_${selectedSize ?? ''}';
  }

  String get name => product.name;
  String get image => product.images.isNotEmpty ? product.images.first : '';
  String get category => product.category;
  double get price => product.price;
  double get lineTotal => price * quantity;

  bool hasSameOptions({
    required Product otherProduct,
    String? color,
    String? size,
  }) {
    return product.id == otherProduct.id &&
        selectedColor == color &&
        selectedSize == size;
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? selectedColor,
    String? selectedSize,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }
}
