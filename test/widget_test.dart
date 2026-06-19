import 'package:e_mart/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Product.fromJson parses common API value types safely', () {
    final product = Product.fromJson({
      'id': 'product-1',
      'name': 'Test phone',
      'description': 'Description',
      'category': 'cellphone',
      'price': 599,
      'originalPrice': '699.5',
      'images': ['assets/images/p1.jpeg'],
      'rating': '4.5',
      'reviewCount': 12.0,
      'stock': '3',
      'colors': ['Black', 'White'],
      'createdAt': '2026-06-15T00:00:00.000',
      'updatedAt': '2026-06-15T00:00:00.000',
    });

    expect(product.price, 599.0);
    expect(product.originalPrice, 699.5);
    expect(product.rating, 4.5);
    expect(product.reviewCount, 12);
    expect(product.stock, 3);
    expect(product.isInStock, isTrue);
  });
}
