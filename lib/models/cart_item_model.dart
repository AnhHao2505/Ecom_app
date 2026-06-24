import 'package:e_mart/models/product_model.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  String get id => product.id;
  String get name => product.name;
  String get image => product.images.isNotEmpty ? product.images.first : '';
  String get category => product.category;
  double get price => product.price;
  double get lineTotal => price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
