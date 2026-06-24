import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('products are mapped to their store details', () {
    final product = dummyProducts.first;
    final store = storeById(product.storeId);
    final storeProducts = productsByStore(store.id);

    expect(store.name, 'E-Mart Central');
    expect(store.address, isNotEmpty);
    expect(store.latitude, isNonZero);
    expect(store.longitude, isNonZero);
    expect(storeProducts, contains(product));
  });

  test('cart merges matching products and respects stock limits', () {
    final cart = CartController(seedWithDemoItems: false);
    final product = dummyProducts.first;

    cart.addProduct(product, quantity: 2);
    cart.addProduct(product, quantity: product.stock);

    expect(cart.items, hasLength(1));
    expect(cart.items.single.quantity, product.stock);
    expect(cart.subtotal, product.price * product.stock);

    cart.updateQuantity(product.id, 0);
    expect(cart.items, isEmpty);
  });
}
