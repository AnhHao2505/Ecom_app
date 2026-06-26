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

  OrderReceipt copyWith({
    String? orderNumber,
    List<CartItem>? items,
    String? recipientName,
    String? deliveryAddress,
    String? billingAddress,
    String? paymentMethod,
    bool? isPaid,
    double? subtotal,
    double? tax,
    double? shipping,
    DateTime? createdAt,
  }) {
    return OrderReceipt(
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      recipientName: recipientName ?? this.recipientName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
