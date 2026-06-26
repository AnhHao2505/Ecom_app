import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final double originalPrice;
  final List<String> images; // Cloudinary URLs
  final String storeId;
  final String? userId;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isFeatured;
  final bool isNew;
  final List<String> sizes;
  final List<String> colors;
  final Map<String, dynamic> attributes; // For flexible product attributes
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.images,
    this.storeId = 'emart-central',
    this.userId,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.stock,
    this.isFeatured = false,
    this.isNew = false,
    this.sizes = const [],
    this.colors = const [],
    this.attributes = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  // Discount percentage calculation
  double get discountPercentage {
    if (originalPrice == 0) return 0;
    return ((originalPrice - price) / originalPrice * 100);
  }

  // Check if product is in stock
  bool get isInStock => stock > 0;

  // Convert Product to JSON for Firestore
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'images': images,
      'storeId': storeId,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'isFeatured': isFeatured,
      'isNew': isNew,
      'sizes': sizes,
      'colors': colors,
      'attributes': attributes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
    if (userId != null && userId!.isNotEmpty) {
      data['userId'] = userId;
    }
    return data;
  }

  // Convert JSON from Firestore to Product
  factory Product.fromMap(Map<String, dynamic> map, String docId) {
    return Product(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: _toDouble(map['price']),
      originalPrice: _toDouble(map['originalPrice']),
      images: _toStringList(map['images']),
      storeId: map['storeId']?.toString() ?? 'emart-central',
      userId: _nullableString(map['userId']),
      rating: _toDouble(map['rating']),
      reviewCount: _toInt(map['reviewCount']),
      stock: _toInt(map['stock']),
      isFeatured: map['isFeatured'] ?? false,
      isNew: map['isNew'] ?? false,
      sizes: _toStringList(map['sizes']),
      colors: _toStringList(map['colors']),
      attributes: Map<String, dynamic>.from(map['attributes'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Product to JSON for API calls or local storage
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'images': images,
      'storeId': storeId,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'isFeatured': isFeatured,
      'isNew': isNew,
      'sizes': sizes,
      'colors': colors,
      'attributes': attributes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    if (userId != null && userId!.isNotEmpty) {
      data['userId'] = userId;
    }
    return data;
  }

  // Convert JSON to Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: _toDouble(json['price']),
      originalPrice: _toDouble(json['originalPrice']),
      images: _toStringList(json['images']),
      storeId: json['storeId']?.toString() ?? 'emart-central',
      userId: _nullableString(json['userId']),
      rating: _toDouble(json['rating']),
      reviewCount: _toInt(json['reviewCount']),
      stock: _toInt(json['stock']),
      isFeatured: json['isFeatured'] ?? false,
      isNew: json['isNew'] ?? false,
      sizes: _toStringList(json['sizes']),
      colors: _toStringList(json['colors']),
      attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Copy with method for creating modified instances
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    double? originalPrice,
    List<String>? images,
    String? storeId,
    String? userId,
    double? rating,
    int? reviewCount,
    int? stock,
    bool? isFeatured,
    bool? isNew,
    List<String>? sizes,
    List<String>? colors,
    Map<String, dynamic>? attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      images: images ?? this.images,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      attributes: attributes ?? this.attributes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category)';
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

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
