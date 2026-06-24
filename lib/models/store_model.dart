  import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  final String id;
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
    required this.id,
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
      'id': id,
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
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ownerName: map['ownerName'] ?? '',
      logo: map['logo'] ?? '',
      coverImage: map['coverImage'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      openingHours: map['openingHours'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      followerCount: map['followerCount'] ?? 0,
      productCount: map['productCount'] ?? 0,
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      ownerName: json['ownerName'] ?? '',
      logo: json['logo'] ?? '',
      coverImage: json['coverImage'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      openingHours: json['openingHours'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      followerCount: json['followerCount'] ?? 0,
      productCount: json['productCount'] ?? 0,
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Store copyWith({
    String? id,
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
      id: id ?? this.id,
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
    return 'Store(id: $id, name: $name, rating: $rating)';
  }
}
