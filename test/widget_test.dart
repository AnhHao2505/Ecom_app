import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/models/product_model.dart';
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

  test('Product.fromJson parses common API value types safely', () {
    final product = Product.fromJson({
      'id': 'product-1',
      'name': 'Test phone',
      'description': 'Description',
      'category': 'cellphone',
      'price': 599,
      'originalPrice': '699.5',
      'images': ['assets/images/p1.jpeg'],
      'storeId': 'emart-central',
      'rating': '4.5',
      'reviewCount': 12.0,
      'stock': '3',
      'colors': ['Black', 'White'],
      'createdAt': '2026-06-15T00:00:00.000',
      'updatedAt': '2026-06-15T00:00:00.000',
    });

    expect(product.price, 599.0);
    expect(product.originalPrice, 699.5);
    expect(product.storeId, 'emart-central');
    expect(product.rating, 4.5);
    expect(product.reviewCount, 12);
    expect(product.stock, 3);
    expect(product.isInStock, isTrue);
  });

  test('cart merges matching products and respects stock limits', () {
    final cart = CartController(seedWithDemoItems: false);
    final product = dummyProducts.first;

    cart.addProduct(product, quantity: 2);
    cart.addProduct(product, quantity: product.stock);

    expect(cart.cartItems, hasLength(1));
    expect(cart.cartItems.single.quantity, product.stock);
    expect(cart.subtotal, product.price * product.stock);

    cart.updateQuantity(cart.cartItems.single.id, 0);
    expect(cart.cartItems, isEmpty);
  });

  test('cart keeps different product options as separate lines', () {
    final cart = CartController(seedWithDemoItems: false);
    final product = dummyProducts.first;

    cart.addToCart(
      product: product,
      quantity: 1,
      selectedColor: 'Black',
      selectedSize: 'M',
    );
    cart.addToCart(
      product: product,
      quantity: 1,
      selectedColor: 'White',
      selectedSize: 'M',
    );

    expect(cart.cartItems, hasLength(2));
  });
}
