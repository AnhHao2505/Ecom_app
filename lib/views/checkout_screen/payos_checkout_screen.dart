import 'dart:async';

import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/models/order_receipt_model.dart';
import 'package:e_mart/services/payos_payment_service.dart';
import 'package:e_mart/views/checkout_screen/order_confirmation_screen.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayosCheckoutScreen extends StatefulWidget {
  final String checkoutUrl;
  final int orderCode;
  final OrderReceipt receipt;

  const PayosCheckoutScreen({
    super.key,
    required this.checkoutUrl,
    required this.orderCode,
    required this.receipt,
  });

  @override
  State<PayosCheckoutScreen> createState() => _PayosCheckoutScreenState();
}

class _PayosCheckoutScreenState extends State<PayosCheckoutScreen> {
  final WebViewController _controller = WebViewController();
  final PayosPaymentService _payosPaymentService = PayosPaymentService();
  var _progress = 0;
  var _isFinishing = false;

  @override
  void initState() {
    super.initState();
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => setState(() => _progress = progress),
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            final path = uri?.path ?? '';

            if (path.endsWith('/payment-return')) {
              unawaited(_finishPayment(success: true));
              return NavigationDecision.prevent;
            }

            if (path.endsWith('/payment-cancel')) {
              unawaited(_finishPayment(success: false));
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFinishing,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          title: 'PayOS checkout'.text
              .color(darkFontGrey)
              .fontFamily(bold)
              .make(),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_progress < 100)
              LinearProgressIndicator(
                value: _progress / 100,
                color: redColor,
                backgroundColor: lightGrey,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishPayment({required bool success}) async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);

    if (!success) {
      try {
        await _payosPaymentService.cancelPayment(widget.orderCode);
      } on PayosPaymentException catch (error) {
        Get.snackbar(
          'Cancel sync failed',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      if (!mounted) return;
      Get.back();
      Get.snackbar(
        'Payment cancelled',
        'Your cart is still saved. You can try again when ready.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.find<CartController>().clear();
    Get.off(
      () => OrderConfirmationScreen(
        receipt: widget.receipt.copyWith(isPaid: true, paymentMethod: 'PayOS'),
      ),
    );
  }
}
