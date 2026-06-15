class Product {
  final String id;
  final String name;
  final double price;
  final List<String> colors;
  final String description;
  final String image;
  final int quantity;
  final double rating;
  final String shop;
  final String subCategory;

  Product({
    this.id = '',
    required this.name,
    required this.price,
    required this.colors,
    required this.description,
    required this.image,
    required this.quantity,
    required this.rating,
    required this.shop,
    required this.subCategory,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'colors': colors,
      'description': description,
      'image': image,
      'quantity': quantity,
      'rating': rating,
      'shop': shop,
      'sub_category': subCategory,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Product(
      id: documentId ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      price: _toDouble(map['price']),
      colors: _toStringList(map['colors']),
      description: map['description']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      quantity: _toInt(map['quantity']),
      rating: _toDouble(map['rating']),
      shop: map['shop']?.toString() ?? '',
      subCategory: map['sub_category']?.toString() ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! Iterable) return const [];
    return value.map((item) => item.toString()).toList();
  }
}
