import 'package:e_mart/models/cart_item_model.dart';

class OrderReceipt {
  final String orderNumber;
  final List<CartItem> items;
  final String recipientName;
  final String buyerEmail;
  final String buyerPhone;
  final String buyerStreetAddress;
  final String buyerCity;
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
    this.buyerEmail = '',
    this.buyerPhone = '',
    this.buyerStreetAddress = '',
    this.buyerCity = '',
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
    String? buyerEmail,
    String? buyerPhone,
    String? buyerStreetAddress,
    String? buyerCity,
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
      buyerEmail: buyerEmail ?? this.buyerEmail,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      buyerStreetAddress: buyerStreetAddress ?? this.buyerStreetAddress,
      buyerCity: buyerCity ?? this.buyerCity,
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
