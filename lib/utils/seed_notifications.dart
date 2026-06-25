import 'package:cloud_firestore/cloud_firestore.dart';

void seedNotifications() async {
  final firestore = FirebaseFirestore.instance;
  
  final mockData = [
    {
      'title': '🎉 Khuyến mãi mùa hè',
      'body': 'Giảm giá lên đến 50% cho tất cả sản phẩm thời trang',
      'type': 'promotion',
      'isRead': false,
      'imageUrl': 'https://example.com/promotion.jpg',
      'createdAt': FieldValue.serverTimestamp(),
      'data': {'discount': '50%'},
    },
    {
      'title': '📦 Đơn hàng đã giao thành công',
      'body': 'Đơn hàng #12345 đã được giao đến bạn',
      'type': 'order',
      'isRead': false,
      'imageUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'data': {'orderId': '12345'},
    },
    {
      'title': '💳 Thanh toán thành công',
      'body': 'Bạn đã thanh toán thành công đơn hàng #12346',
      'type': 'payment',
      'isRead': false,
      'imageUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'data': {'orderId': '12346'},
    },
    {
      'title': '🔔 Cập nhật hệ thống',
      'body': 'Hệ thống sẽ được bảo trì vào lúc 2:00 AM ngày mai',
      'type': 'system',
      'isRead': false,
      'imageUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'data': {},
    },
  ];
  
  for (var data in mockData) {
    await firestore.collection('notifications').add(data);
  }
}