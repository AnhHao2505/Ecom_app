import 'package:e_mart/consts/firebase_consts.dart';
import 'package:e_mart/models/billing_order_model.dart';
import 'package:e_mart/models/order_receipt_model.dart';

class OrderBillingService {
  Stream<List<BillingOrder>> watchCurrentUserOrders() {
    final user = auth.currentUser;
    if (user == null) return Stream.value(const []);

    return firestore
        .collection(usersCollection)
        .doc(user.uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((document) => BillingOrder.fromSnapshot(document))
              .toList(),
        );
  }

  Future<void> saveCashOnDeliveryOrder({
    required OrderReceipt receipt,
    required String buyerPhone,
    required String buyerStreetAddress,
    required String buyerCity,
    required String deliveryType,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const OrderBillingException('Please sign in before checkout.');
    }

    final now = DateTime.now().toIso8601String();
    await firestore
        .collection(usersCollection)
        .doc(user.uid)
        .collection('orders')
        .doc(receipt.orderNumber)
        .set({
          'userId': user.uid,
          'orderCode': receipt.orderNumber,
          'amount': receipt.total.round(),
          'subtotal': receipt.subtotal,
          'tax': receipt.tax,
          'shipping': receipt.shipping,
          'total': receipt.total,
          'status': 'COD_PENDING',
          'paymentMethod': 'Cash on delivery',
          'isPaid': false,
          'items': receipt.items.map((item) {
            return {
              'productId': item.product.id,
              'name': item.name,
              'quantity': item.quantity,
              'price': item.price,
              'image': item.image,
              'category': item.category,
              'selectedColor': item.selectedColor,
              'selectedSize': item.selectedSize,
            };
          }).toList(),
          'buyerName': receipt.recipientName,
          'buyerEmail': user.email ?? '',
          'buyerPhone': buyerPhone,
          'buyerStreetAddress': buyerStreetAddress,
          'buyerCity': buyerCity,
          'billingAddress': receipt.billingAddress,
          'delivery': {'type': deliveryType, 'price': receipt.shipping},
          'createdAt': now,
          'updatedAt': now,
        });
  }
}

class OrderBillingException implements Exception {
  final String message;

  const OrderBillingException(this.message);

  @override
  String toString() => message;
}
