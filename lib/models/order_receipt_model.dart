import 'package:e_mart/models/cart_item_model.dart';

class OrderReceipt {
  final String orderNumber;
  final List<CartItem> items;
  final String recipientName;
  final String deliveryAddress;
  final String billingAddress;
  final String paymentMethod;
  final bool isPaid;
  final double subtotal;
  final double tax;
  final double shipping;
  final DateTime createdAt;

  const OrderReceipt({
    required this.orderNumber,
    required this.items,
    required this.recipientName,
    required this.deliveryAddress,
    required this.billingAddress,
    required this.paymentMethod,
    required this.isPaid,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.createdAt,
  });

  double get total => subtotal + tax + shipping;
}
