// models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // order, promotion, system, payment
  final bool isRead;
  final DateTime createdAt;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  
  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.imageUrl,
    this.data,
  });
  
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAtValue = data['createdAt'];
    DateTime createdAt;

    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else {
      createdAt = DateTime.now();
    }

    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'system',
      isRead: data['isRead'] ?? false,
      createdAt: createdAt,
      imageUrl: data['imageUrl'] ?? '',
      data: data['data'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'data': data,
    };
  }
}