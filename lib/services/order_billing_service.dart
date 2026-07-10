import 'package:e_mart/consts/firebase_consts.dart';
import 'package:e_mart/models/billing_order_model.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/models/order_receipt_model.dart';
import 'package:e_mart/models/cart_item_model.dart';

class OrderBillingService {
  Future<void> ensureItemsInStock(List<CartItem> items) async {
    if (items.isEmpty) return;

    final requiredQuantities = <String, int>{};
    for (final item in items) {
      requiredQuantities[item.product.id] =
          (requiredQuantities[item.product.id] ?? 0) + item.quantity;
    }

    final snapshots = await Future.wait(
      requiredQuantities.keys.map(
        (productId) =>
            firestore.collection(productCollection).doc(productId).get(),
      ),
    );

    for (final snapshot in snapshots) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw OrderBillingException(
          'One of your items is no longer available.',
        );
      }

      final product = Product.fromMap(data, snapshot.id);
      final requiredQuantity = requiredQuantities[product.id] ?? 0;
      if (product.stock < requiredQuantity) {
        throw OrderBillingException(
          '${product.name} only has ${product.stock} left in stock.',
        );
      }
    }
  }

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

  Stream<List<BillingOrder>> watchPaidOrdersForSeller(String sellerUserId) {
    if (sellerUserId.trim().isEmpty) return Stream.value(const []);

    return firestore
        .collection(paidOrdersCollection)
        .where('sellerUserIds', arrayContains: sellerUserId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((document) => BillingOrder.fromSnapshot(document))
              .toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  Stream<List<BillingOrder>> watchSellerOrders(String sellerUserId) {
    return watchPaidOrdersForSeller(sellerUserId);
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

    final sellerUserIds = receipt.items
        .map((item) => item.product.userId ?? item.product.storeId)
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();
    final now = DateTime.now().toIso8601String();
    final orderData = {
      'userId': user.uid,
      'sellerUserIds': sellerUserIds,
      'orderCode': receipt.orderNumber,
      'amount': receipt.total.round(),
      'subtotal': receipt.subtotal,
      'tax': receipt.tax,
      'shipping': receipt.shipping,
      'total': receipt.total,
      'status': 'COD_PENDING',
      'paymentMethod': 'Cash on delivery',
      'isPaid': false,
      'items': receipt.items.map(_cartItemToOrderItem).toList(),
      'buyerName': receipt.recipientName,
      'buyerEmail': user.email ?? '',
      'buyerPhone': buyerPhone,
      'buyerStreetAddress': buyerStreetAddress,
      'buyerCity': buyerCity,
      'billingAddress': receipt.billingAddress,
      'delivery': {'type': deliveryType, 'price': receipt.shipping},
      'createdAt': now,
      'updatedAt': now,
    };

    final userOrderRef = firestore
        .collection(usersCollection)
        .doc(user.uid)
        .collection('orders')
        .doc(receipt.orderNumber);
    final sellerOrderRef = firestore
        .collection(paidOrdersCollection)
        .doc('COD-${receipt.orderNumber}');

    final batch = firestore.batch();
    batch.set(userOrderRef, orderData);
    batch.set(sellerOrderRef, orderData);
    await batch.commit();
  }

  Future<void> savePaidPayosOrder({
    required OrderReceipt receipt,
    required int orderCode,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const OrderBillingException('Please sign in before checkout.');
    }

    final sellerUserIds = receipt.items
        .map((item) => item.product.userId ?? item.product.storeId)
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();
    final paidAt = DateTime.now().toIso8601String();
    final orderRef = firestore
        .collection(paidOrdersCollection)
        .doc('PO-$orderCode');

    final requiredQuantities = <String, int>{};
    for (final item in receipt.items) {
      requiredQuantities[item.product.id] =
          (requiredQuantities[item.product.id] ?? 0) + item.quantity;
    }

    await firestore.runTransaction((transaction) async {
      for (final entry in requiredQuantities.entries) {
        final productRef = firestore
            .collection(productCollection)
            .doc(entry.key);
        final snapshot = await transaction.get(productRef);
        final data = snapshot.data();
        if (!snapshot.exists || data == null) {
          throw OrderBillingException(
            'One of your items is no longer available.',
          );
        }

        final product = Product.fromMap(data, snapshot.id);
        if (product.stock < entry.value) {
          throw OrderBillingException(
            '${product.name} only has ${product.stock} left in stock.',
          );
        }

        transaction.update(productRef, {
          'stock': product.stock - entry.value,
          'updatedAt': DateTime.now(),
        });
      }

      transaction.set(orderRef, {
        'userId': user.uid,
        'sellerUserIds': sellerUserIds,
        'orderCode': 'PO-$orderCode',
        'amount': receipt.total.round(),
        'subtotal': receipt.subtotal,
        'tax': receipt.tax,
        'shipping': receipt.shipping,
        'total': receipt.total,
        'status': 'PAID',
        'paymentMethod': 'PayOS',
        'isPaid': true,
        'items': receipt.items.map(_cartItemToOrderItem).toList(),
        'buyerName': receipt.recipientName,
        'buyerEmail': receipt.buyerEmail,
        'buyerPhone': receipt.buyerPhone,
        'buyerStreetAddress': receipt.buyerStreetAddress,
        'buyerCity': receipt.buyerCity,
        'billingAddress': receipt.billingAddress,
        'delivery': {'type': 'Paid delivery', 'price': receipt.shipping},
        'paidAt': paidAt,
        'createdAt': receipt.createdAt.toIso8601String(),
        'updatedAt': paidAt,
      });
    });
  }

  Map<String, dynamic> _cartItemToOrderItem(CartItem item) {
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
  }
}

class OrderBillingException implements Exception {
  final String message;

  const OrderBillingException(this.message);

  @override
  String toString() => message;
}
