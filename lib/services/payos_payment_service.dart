import 'dart:convert';
import 'dart:io';

import 'package:e_mart/consts/firebase_consts.dart';
import 'package:e_mart/consts/payment_consts.dart';
import 'package:e_mart/models/cart_item_model.dart';

class PayosPaymentRequest {
  final int amount;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final String buyerStreetAddress;
  final String buyerCity;
  final String billingAddress;
  final String deliveryType;
  final double deliveryPrice;
  final List<CartItem> items;
  final double tax;
  final double shipping;

  const PayosPaymentRequest({
    required this.amount,
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.buyerStreetAddress,
    required this.buyerCity,
    required this.billingAddress,
    required this.deliveryType,
    required this.deliveryPrice,
    required this.items,
    required this.tax,
    required this.shipping,
  });

  Map<String, dynamic> toJson() {
    final subtotal = items.fold<double>(
      0,
      (total, item) => total + item.lineTotal,
    );
    final paymentItems = items
        .map(
          (item) => {
            'name': item.name,
            'quantity': item.quantity,
            'price': item.price.round(),
          },
        )
        .toList();
    final purchasedItems = items
        .map(
          (item) => {
            'productId': item.product.id,
            'name': item.name,
            'quantity': item.quantity,
            'price': item.price,
            'image': item.image,
            'category': item.category,
            'selectedColor': item.selectedColor,
            'selectedSize': item.selectedSize,
          },
        )
        .toList();

    if (tax > 0) {
      paymentItems.add({'name': 'Tax', 'quantity': 1, 'price': tax.round()});
    }

    if (shipping > 0) {
      paymentItems.add({
        'name': 'Shipping',
        'quantity': 1,
        'price': shipping.round(),
      });
    }

    return {
      'amount': amount,
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': amount,
      'buyerName': buyerName,
      'buyerEmail': buyerEmail,
      'buyerPhone': buyerPhone,
      'buyerStreetAddress': buyerStreetAddress,
      'buyerCity': buyerCity,
      'billingAddress': billingAddress,
      'deliveryType': deliveryType,
      'deliveryPrice': deliveryPrice.round(),
      'purchasedItems': purchasedItems,
      'items': paymentItems,
    };
  }
}

class PayosPaymentResponse {
  final String orderId;
  final int orderCode;
  final String checkoutUrl;
  final String? qrCode;
  final String? status;

  const PayosPaymentResponse({
    required this.orderId,
    required this.orderCode,
    required this.checkoutUrl,
    this.qrCode,
    this.status,
  });

  factory PayosPaymentResponse.fromJson(Map<String, dynamic> json) {
    return PayosPaymentResponse(
      orderId: json['orderId']?.toString() ?? '',
      orderCode: int.tryParse(json['orderCode']?.toString() ?? '') ?? 0,
      checkoutUrl: json['checkoutUrl']?.toString() ?? '',
      qrCode: json['qrCode']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class PayosPaymentService {
  Future<PayosPaymentResponse> createPayment(
    PayosPaymentRequest paymentRequest,
  ) async {
    final decoded = await _postAuthorizedJson(
      '/create-payment',
      paymentRequest.toJson(),
    );

    final payment = PayosPaymentResponse.fromJson(decoded);
    if (payment.checkoutUrl.isEmpty) {
      throw const PayosPaymentException('PayOS did not return a checkout URL.');
    }

    return payment;
  }

  Future<void> cancelPayment(int orderCode) async {
    await _postAuthorizedJson('/cancel-payment', {'orderCode': orderCode});
  }

  Future<Map<String, dynamic>> _postAuthorizedJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final baseUrl = payosWorkerBaseUrl.trim();
    if (baseUrl.isEmpty) {
      throw const PayosPaymentException(
        'PAYOS_WORKER_URL is not configured. Run Flutter with '
        '--dart-define=PAYOS_WORKER_URL=https://your-worker.workers.dev',
      );
    }

    final user = auth.currentUser;
    if (user == null) {
      throw const PayosPaymentException('Please sign in before checkout.');
    }

    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw const PayosPaymentException(
        'Could not verify your Firebase login.',
      );
    }

    final uri = Uri.parse('${_trimTrailingSlash(baseUrl)}$path');
    final client = HttpClient();

    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $idToken');
      request.write(jsonEncode(body));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = responseBody.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw PayosPaymentException(
          decoded['error']?.toString() ?? 'PayOS Worker request failed.',
        );
      }

      return decoded;
    } on SocketException {
      throw const PayosPaymentException(
        'Could not connect to the PayOS Worker.',
      );
    } on FormatException {
      throw const PayosPaymentException(
        'The PayOS Worker returned an invalid response.',
      );
    } finally {
      client.close(force: true);
    }
  }

  static String _trimTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}

class PayosPaymentException implements Exception {
  final String message;

  const PayosPaymentException(this.message);

  @override
  String toString() => message;
}
