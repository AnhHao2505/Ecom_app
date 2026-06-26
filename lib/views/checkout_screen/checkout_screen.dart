import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/models/order_receipt_model.dart';
import 'package:e_mart/services/order_billing_service.dart';
import 'package:e_mart/services/payos_payment_service.dart';
import 'package:e_mart/views/checkout_screen/order_confirmation_screen.dart';
import 'package:e_mart/views/checkout_screen/payos_checkout_screen.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:get/get.dart';

enum DeliveryOption { standard, express }

enum PaymentMethod { payos, cashOnDelivery }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _billingAddressController = TextEditingController();

  DeliveryOption _deliveryOption = DeliveryOption.standard;
  PaymentMethod _paymentMethod = PaymentMethod.payos;
  bool _billingMatchesDelivery = true;
  bool _isSubmitting = false;

  CartController get _cartController => Get.find<CartController>();
  final OrderBillingService _orderBillingService = OrderBillingService();
  final PayosPaymentService _payosPaymentService = PayosPaymentService();

  double get _shippingCost {
    return _deliveryOption == DeliveryOption.express ? 12.99 : 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _billingAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        title: 'Checkout'.text.white.fontFamily(bold).size(20).make(),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [darkBg, darkBgGradientEnd]
                : [lightBg, lightBgGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _buildSection(
                      context: context,
                      title: 'Delivery details',
                      icon: Icons.local_shipping_outlined,
                      child: Column(
                        children: [
                          _inputField(
                            context: context,
                            controller: _nameController,
                            label: 'Full name',
                            hint: 'Enter recipient name',
                            textCapitalization: TextCapitalization.words,
                          ),
                          12.heightBox,
                          _inputField(
                            context: context,
                            controller: _phoneController,
                            label: 'Phone number',
                            hint: 'Enter phone number',
                            keyboardType: TextInputType.phone,
                          ),
                          12.heightBox,
                          _inputField(
                            context: context,
                            controller: _addressController,
                            label: 'Street address',
                            hint: 'House number, street, ward',
                            textCapitalization: TextCapitalization.words,
                          ),
                          12.heightBox,
                          _inputField(
                            context: context,
                            controller: _cityController,
                            label: 'City',
                            hint: 'City or province',
                            textCapitalization: TextCapitalization.words,
                          ),
                        ],
                      ),
                    ),
                    14.heightBox,
                    _buildSection(
                      context: context,
                      title: 'Delivery option',
                      icon: Icons.delivery_dining_outlined,
                      child: Column(
                        children: [
                          _optionTile(
                            context: context,
                            title: 'Standard delivery',
                            subtitle: 'Arrives in 2-4 business days',
                            trailing: 'Free',
                            selected:
                                _deliveryOption == DeliveryOption.standard,
                            onTap: () => setState(
                              () => _deliveryOption = DeliveryOption.standard,
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: Theme.of(context).dividerColor,
                          ),
                          _optionTile(
                            context: context,
                            title: 'Express delivery',
                            subtitle: 'Arrives in 1 business day',
                            trailing: '\$12.99',
                            selected: _deliveryOption == DeliveryOption.express,
                            onTap: () => setState(
                              () => _deliveryOption = DeliveryOption.express,
                            ),
                          ),
                        ],
                      ),
                    ),
                    14.heightBox,
                    _buildSection(
                      context: context,
                      title: 'Payment method',
                      icon: Icons.account_balance_wallet_outlined,
                      child: Column(
                        children: [
                          _paymentOption(
                            context: context,
                            method: PaymentMethod.payos,
                            title: 'PayOS',
                            subtitle:
                                'Pay by bank transfer, QR, or supported PayOS options',
                            icon: Icons.qr_code_2_outlined,
                          ),
                          Divider(
                            height: 1,
                            color: Theme.of(context).dividerColor,
                          ),
                          _paymentOption(
                            context: context,
                            method: PaymentMethod.cashOnDelivery,
                            title: 'Cash on delivery',
                            subtitle: 'Pay when your order arrives',
                            icon: Icons.payments_outlined,
                          ),
                        ],
                      ),
                    ),
                    14.heightBox,
                    _buildSection(
                      context: context,
                      title: 'Billing address',
                      icon: Icons.receipt_long_outlined,
                      child: Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: 'Same as delivery address'.text
                                  .color(
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  )
                                  .fontFamily(semibold)
                                  .make(),
                              value: _billingMatchesDelivery,
                              activeThumbColor: primaryColor,
                              activeTrackColor: primaryColor.withValues(
                                alpha: 0.35,
                              ),
                              onChanged: (value) {
                                setState(() => _billingMatchesDelivery = value);
                              },
                            ),
                          ),
                          if (!_billingMatchesDelivery) ...[
                            8.heightBox,
                            _inputField(
                              context: context,
                              controller: _billingAddressController,
                              label: 'Billing address',
                              hint: 'Street, city, and postal code',
                              textCapitalization: TextCapitalization.words,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildOrderBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.transparent
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              10.widthBox,
              title.text
                  .color(Theme.of(context).textTheme.bodyLarge?.color)
                  .fontFamily(bold)
                  .size(16)
                  .make(),
            ],
          ),
          16.heightBox,
          child,
        ],
      ),
    );
  }

  Widget _inputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      validator: validator ?? _validateRequired,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        hintStyle: TextStyle(
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
        ),
        isDense: true,
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
      ),
    );
  }

  Widget _optionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String trailing,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? primaryColor
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            12.widthBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title.text
                      .color(Theme.of(context).textTheme.bodyLarge?.color)
                      .fontFamily(semibold)
                      .make(),
                  3.heightBox,
                  subtitle.text
                      .color(Theme.of(context).textTheme.bodyMedium?.color)
                      .size(12)
                      .make(),
                ],
              ),
            ),
            trailing.text
                .color(
                  selected
                      ? primaryColor
                      : Theme.of(context).textTheme.bodyLarge?.color,
                )
                .fontFamily(semibold)
                .make(),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption({
    required BuildContext context,
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _paymentMethod == method;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = method),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? primaryColor
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            12.widthBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title.text
                      .color(Theme.of(context).textTheme.bodyLarge?.color)
                      .fontFamily(semibold)
                      .make(),
                  3.heightBox,
                  subtitle.text
                      .color(Theme.of(context).textTheme.bodyMedium?.color)
                      .size(12)
                      .make(),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? primaryColor
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderBar(BuildContext context) {
    final total =
        _cartController.subtotal + _cartController.tax + _shippingCost;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                '${_cartController.itemCount} items'.text
                    .color(Theme.of(context).textTheme.bodyMedium?.color)
                    .fontFamily(semibold)
                    .make(),
                '\$${total.toStringAsFixed(2)}'.text
                    .color(primaryColor)
                    .fontFamily(bold)
                    .size(22)
                    .make(),
              ],
            ),
            12.heightBox,
            SizedBox(
              width: double.infinity,
              child: ourButton(
                color: primaryColor,
                title: _paymentMethod == PaymentMethod.cashOnDelivery
                    ? 'Place order'
                    : _isSubmitting
                    ? 'Creating PayOS link...'
                    : 'Pay \$${total.toStringAsFixed(2)}',
                onPress: _isSubmitting ? () {} : _placeOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_cartController.items.isEmpty) {
      Get.back();
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final deliveryAddress =
        '${_addressController.text.trim()}, ${_cityController.text.trim()}';
    final receipt = OrderReceipt(
      orderNumber:
          'EM-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      items: List.unmodifiable(_cartController.items),
      recipientName: _nameController.text.trim(),
      deliveryAddress: deliveryAddress,
      billingAddress: _billingMatchesDelivery
          ? deliveryAddress
          : _billingAddressController.text.trim(),
      paymentMethod: _paymentMethodLabel,
      isPaid: _paymentMethod != PaymentMethod.cashOnDelivery,
      subtotal: _cartController.subtotal,
      tax: _cartController.tax,
      shipping: _shippingCost,
      createdAt: DateTime.now(),
    );

    if (_paymentMethod == PaymentMethod.payos) {
      await _startPayosPayment(receipt);
      return;
    }

    await _placeCashOnDeliveryOrder(receipt);
  }

  Future<void> _placeCashOnDeliveryOrder(OrderReceipt receipt) async {
    setState(() => _isSubmitting = true);

    try {
      await _orderBillingService.saveCashOnDeliveryOrder(
        receipt: receipt,
        buyerPhone: _phoneController.text.trim(),
        buyerStreetAddress: _addressController.text.trim(),
        buyerCity: _cityController.text.trim(),
        deliveryType: _deliveryOptionLabel,
      );

      if (!mounted) return;
      _cartController.clear();
      Get.off(() => OrderConfirmationScreen(receipt: receipt));
    } on OrderBillingException catch (error) {
      Get.snackbar(
        'Order failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Order failed',
        'Please try again in a moment.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _startPayosPayment(OrderReceipt receipt) async {
    setState(() => _isSubmitting = true);

    try {
      final payment = await _payosPaymentService.createPayment(
        PayosPaymentRequest(
          amount: receipt.total.round(),
          buyerName: receipt.recipientName,
          buyerEmail: auth.currentUser?.email ?? '',
          buyerPhone: _phoneController.text.trim(),
          buyerStreetAddress: _addressController.text.trim(),
          buyerCity: _cityController.text.trim(),
          billingAddress: receipt.billingAddress,
          deliveryType: _deliveryOptionLabel,
          deliveryPrice: receipt.shipping,
          items: receipt.items,
          tax: receipt.tax,
          shipping: receipt.shipping,
        ),
      );

      if (!mounted) return;
      Get.to(
        () => PayosCheckoutScreen(
          checkoutUrl: payment.checkoutUrl,
          orderCode: payment.orderCode,
          receipt: receipt.copyWith(orderNumber: 'PO-${payment.orderCode}'),
        ),
      );
    } on PayosPaymentException catch (error) {
      Get.snackbar(
        'PayOS checkout failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'PayOS checkout failed',
        'Please try again in a moment.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String get _paymentMethodLabel {
    switch (_paymentMethod) {
      case PaymentMethod.payos:
        return 'PayOS';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on delivery';
    }
  }

  String get _deliveryOptionLabel {
    switch (_deliveryOption) {
      case DeliveryOption.standard:
        return 'Standard delivery';
      case DeliveryOption.express:
        return 'Express delivery';
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }
}
