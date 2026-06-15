import 'package:e_mart/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Product.fromMap parses Firestore values safely', () {
    final product = Product.fromMap({
      'name': 'Phone',
      'price': 599,
      'colors': ['black', '#ffffff'],
      'description': 'A test phone',
      'image': 'https://example.com/phone.jpg',
      'quantity': 3.0,
      'rating': '4.5',
      'shop': 'Demo Shop',
      'sub_category': 'Cellphone & Tab',
    }, documentId: 'product-1');

    expect(product.id, 'product-1');
    expect(product.price, 599.0);
    expect(product.quantity, 3);
    expect(product.rating, 4.5);
    expect(product.colors, ['black', '#ffffff']);
  });
}
