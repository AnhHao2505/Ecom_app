import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart/consts/images.dart';

class Store {
  final String userId;
  final String name;
  final String description;
  final String ownerName;
  final String logo;
  final String coverImage;
  final String phone;
  final String email;
  final String address;
  final String openingHours;
  final double rating;
  final int followerCount;
  final int productCount;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Store({
    required this.userId,
    required this.name,
    required this.description,
    required this.ownerName,
    required this.logo,
    required this.coverImage,
    required this.phone,
    required this.email,
    required this.address,
    required this.openingHours,
    this.rating = 0.0,
    this.followerCount = 0,
    this.productCount = 0,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  String get coordinateLabel {
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'ownerName': ownerName,
      'logo': logo,
      'coverImage': coverImage,
      'phone': phone,
      'email': email,
      'address': address,
      'openingHours': openingHours,
      'rating': rating,
      'followerCount': followerCount,
      'productCount': productCount,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Store.fromMap(Map<String, dynamic> map, String docId) {
    return Store(
      userId: _nonEmptyString(map['userId'], docId),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      ownerName: map['ownerName']?.toString() ?? '',
      logo: _nonEmptyString(map['logo'], icShop),
      coverImage: _nonEmptyString(map['coverImage'], imgSlider1),
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      openingHours: map['openingHours']?.toString() ?? '',
      rating: _toDouble(map['rating']),
      followerCount: _toInt(map['followerCount']),
      productCount: _toInt(map['productCount']),
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'ownerName': ownerName,
      'logo': logo,
      'coverImage': coverImage,
      'phone': phone,
      'email': email,
      'address': address,
      'openingHours': openingHours,
      'rating': rating,
      'followerCount': followerCount,
      'productCount': productCount,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      userId: _nonEmptyString(json['userId'], ''),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      ownerName: json['ownerName']?.toString() ?? '',
      logo: _nonEmptyString(json['logo'], icShop),
      coverImage: _nonEmptyString(json['coverImage'], imgSlider1),
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      openingHours: json['openingHours']?.toString() ?? '',
      rating: _toDouble(json['rating']),
      followerCount: _toInt(json['followerCount']),
      productCount: _toInt(json['productCount']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Store copyWith({
    String? userId,
    String? name,
    String? description,
    String? ownerName,
    String? logo,
    String? coverImage,
    String? phone,
    String? email,
    String? address,
    String? openingHours,
    double? rating,
    int? followerCount,
    int? productCount,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerName: ownerName ?? this.ownerName,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
      followerCount: followerCount ?? this.followerCount,
      productCount: productCount ?? this.productCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Store(userId: $userId, name: $name, rating: $rating)';
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _nonEmptyString(dynamic value, String fallback) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }
}
