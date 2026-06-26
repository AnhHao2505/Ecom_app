import 'package:cloud_firestore/cloud_firestore.dart';

class BillingOrder {
  final String id;
  final String orderCode;
  final String status;
  final String paymentMethod;
  final bool isPaid;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final String buyerStreetAddress;
  final String buyerCity;
  final String billingAddress;
  final String deliveryType;
  final DateTime createdAt;
  final DateTime? paidAt;
  final List<BillingOrderItem> items;

  const BillingOrder({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.paymentMethod,
    required this.isPaid,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.buyerStreetAddress,
    required this.buyerCity,
    required this.billingAddress,
    required this.deliveryType,
    required this.createdAt,
    required this.paidAt,
    required this.items,
  });

  factory BillingOrder.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return BillingOrder.fromMap(snapshot.data() ?? {}, snapshot.id);
  }

  factory BillingOrder.fromMap(Map<String, dynamic> data, String documentId) {
    final delivery = _asMap(data['delivery']);
    final parsedItems = _parseItems(data['items']);
    final itemSubtotal = parsedItems
        .where((item) => !item.isFee)
        .fold<double>(0, (total, item) => total + item.lineTotal);
    final tax = _toDouble(data['tax'] ?? _feeAmount(parsedItems, 'tax'));
    final shipping = _toDouble(
      data['shipping'] ??
          delivery['price'] ??
          _feeAmount(parsedItems, 'shipping'),
    );
    final subtotal = _toDouble(data['subtotal']);
    final total = _toDouble(data['total'] ?? data['amount']);
    final status = data['status']?.toString() ?? 'PENDING';

    return BillingOrder(
      id: documentId,
      orderCode: data['orderCode']?.toString() ?? documentId,
      status: status,
      paymentMethod:
          data['paymentMethod']?.toString() ??
          (data['paymentLinkId'] == null ? 'Cash on delivery' : 'PayOS'),
      isPaid: data['isPaid'] == true || status.toUpperCase() == 'PAID',
      subtotal: subtotal == 0 ? itemSubtotal : subtotal,
      tax: tax,
      shipping: shipping,
      total: total == 0
          ? (subtotal == 0 ? itemSubtotal : subtotal) + tax + shipping
          : total,
      buyerName: data['buyerName']?.toString() ?? '',
      buyerEmail: data['buyerEmail']?.toString() ?? '',
      buyerPhone: data['buyerPhone']?.toString() ?? '',
      buyerStreetAddress: data['buyerStreetAddress']?.toString() ?? '',
      buyerCity: data['buyerCity']?.toString() ?? '',
      billingAddress: data['billingAddress']?.toString() ?? '',
      deliveryType: delivery['type']?.toString() ?? '',
      createdAt: _toDateTime(data['createdAt']) ?? DateTime.now(),
      paidAt: _toDateTime(data['paidAt']),
      items: parsedItems.where((item) => !item.isFee).toList(),
    );
  }

  String get deliveryAddress {
    final parts = [
      buyerStreetAddress,
      buyerCity,
    ].where((part) => part.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'Not provided' : parts.join(', ');
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'PAID':
        return 'Paid';
      case 'CANCELLED':
        return 'Cancelled';
      case 'FAILED':
      case 'PAYOS_FAILED':
        return 'Failed';
      case 'COD_PENDING':
        return 'Due on delivery';
      default:
        return 'Pending';
    }
  }

  static List<BillingOrderItem> _parseItems(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) => BillingOrderItem.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static double _feeAmount(List<BillingOrderItem> items, String feeName) {
    final normalizedFee = feeName.toLowerCase();
    return items
        .where((item) => item.name.toLowerCase() == normalizedFee)
        .fold<double>(0, (total, item) => total + item.lineTotal);
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}

class BillingOrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String image;
  final String category;
  final String? selectedColor;
  final String? selectedSize;

  const BillingOrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.image,
    required this.category,
    this.selectedColor,
    this.selectedSize,
  });

  factory BillingOrderItem.fromMap(Map<String, dynamic> data) {
    return BillingOrderItem(
      productId: data['productId']?.toString() ?? data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? 'Product',
      quantity: BillingOrder._toInt(data['quantity']).clamp(1, 999),
      price: BillingOrder._toDouble(data['price']),
      image: data['image']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      selectedColor: data['selectedColor']?.toString(),
      selectedSize: data['selectedSize']?.toString(),
    );
  }

  double get lineTotal => price * quantity;

  bool get isFee {
    final normalized = name.toLowerCase();
    return normalized == 'tax' || normalized == 'shipping';
  }

  String get optionLabel {
    final options = [
      if (selectedColor != null && selectedColor!.isNotEmpty) selectedColor!,
      if (selectedSize != null && selectedSize!.isNotEmpty)
        'Size $selectedSize',
    ];
    return options.join(' | ');
  }
}
