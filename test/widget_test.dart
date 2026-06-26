import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/models/billing_order_model.dart';
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
    expect(product.userId, isNull);
    expect(product.rating, 4.5);
    expect(product.reviewCount, 12);
    expect(product.stock, 3);
    expect(product.isInStock, isTrue);
  });

  test('Product.fromJson preserves seller user id when present', () {
    final product = Product.fromJson({
      'id': 'seller-product-1',
      'name': 'Seller item',
      'description': 'Seller owned product',
      'category': 'cellphone',
      'price': 99,
      'originalPrice': 120,
      'images': ['https://example.com/product.jpg'],
      'storeId': 'seller-uid-1',
      'userId': 'seller-uid-1',
      'stock': 5,
      'createdAt': '2026-06-15T00:00:00.000',
      'updatedAt': '2026-06-15T00:00:00.000',
    });

    expect(product.userId, 'seller-uid-1');
    expect(product.toJson()['userId'], 'seller-uid-1');
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

  test('billing order parses saved purchase and delivery details', () {
    final order = BillingOrder.fromMap({
      'orderCode': 'EM-123',
      'status': 'COD_PENDING',
      'paymentMethod': 'Cash on delivery',
      'subtotal': 100.0,
      'tax': 10.0,
      'shipping': 12.0,
      'total': 122.0,
      'buyerName': 'Test User',
      'buyerPhone': '0900000000',
      'buyerStreetAddress': '123 Test Street',
      'buyerCity': 'Ho Chi Minh City',
      'billingAddress': '123 Test Street, Ho Chi Minh City',
      'delivery': {'type': 'Express delivery', 'price': 12.0},
      'createdAt': '2026-06-15T10:30:00.000',
      'items': [
        {
          'productId': 'product-1',
          'name': 'Test phone',
          'quantity': 2,
          'price': 50.0,
          'selectedColor': 'Black',
          'selectedSize': 'M',
        },
      ],
    }, 'EM-123');

    expect(order.total, 122.0);
    expect(order.statusLabel, 'Due on delivery');
    expect(order.deliveryType, 'Express delivery');
    expect(order.deliveryAddress, '123 Test Street, Ho Chi Minh City');
    expect(order.items.single.optionLabel, 'Black | Size M');
  });
}
