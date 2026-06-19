import 'package:e_mart/models/cart_item_model.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final cartItems = <CartItem>[].obs;

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + item.lineTotal);
  }

  double get tax => subtotal * 0.1;

  double get total => subtotal + tax;

  int get totalQuantity {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  void addToCart({
    required Product product,
    required int quantity,
    String? selectedColor,
    String? selectedSize,
  }) {
    if (!product.isInStock || quantity <= 0) return;

    final safeQuantity = quantity.clamp(1, product.stock).toInt();
    final index = cartItems.indexWhere(
      (item) => item.hasSameOptions(
        otherProduct: product,
        color: selectedColor,
        size: selectedSize,
      ),
    );

    if (index == -1) {
      cartItems.add(
        CartItem(
          product: product,
          quantity: safeQuantity,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
        ),
      );
      return;
    }

    final item = cartItems[index];
    item.quantity = (item.quantity + safeQuantity).clamp(1, product.stock);
    cartItems.refresh();
  }

  void removeItem(String itemId) {
    cartItems.removeWhere((item) => item.id == itemId);
  }

  void updateQuantity(String itemId, int quantity) {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final item = cartItems[index];
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    item.quantity = quantity.clamp(1, item.product.stock);
    cartItems.refresh();
  }

  void clearCart() {
    cartItems.clear();
  }
}
