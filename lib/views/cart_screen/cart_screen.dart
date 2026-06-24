import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/models/cart_item_model.dart';
import 'package:e_mart/views/checkout_screen/checkout_screen.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  CartController get _cartController => Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        title: cart.text.color(darkFontGrey).fontFamily(bold).make(),
      ),
      body: Obx(() {
        if (_cartController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: redColor),
          );
        }

        return _cartController.items.isEmpty
            ? _buildEmptyCart(context)
            : _buildCartBody(context);
      }),
    );
  }

  Widget _buildCartBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _cartController.items.length,
            itemBuilder: (context, index) {
              return _buildCartItem(_cartController.items[index]);
            },
          ),
        ),
        _buildPriceSummary(context),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, color: fontGrey, size: 72),
          16.heightBox,
          'Your cart is empty'.text
              .color(darkFontGrey)
              .fontFamily(bold)
              .size(18)
              .make(),
          6.heightBox,
          'Add products to place an order.'.text
              .color(fontGrey)
              .fontFamily(semibold)
              .size(14)
              .make(),
          20.heightBox,
          SizedBox(
            width: 180,
            child: ourButton(
              title: 'Continue Shopping',
              onPress: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: darkFontGrey.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 88,
                height: 88,
                color: lightGrey,
                child: item.image.isEmpty
                    ? const Icon(Icons.image_not_supported_outlined)
                    : Image.asset(item.image, fit: BoxFit.cover),
              ),
              12.widthBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    item.name.text
                        .color(darkFontGrey)
                        .fontFamily(semibold)
                        .size(14)
                        .maxLines(2)
                        .overflow(TextOverflow.ellipsis)
                        .make(),
                    5.heightBox,
                    item.category.text
                        .color(fontGrey)
                        .fontFamily(semibold)
                        .size(12)
                        .make(),
                    8.heightBox,
                    '\$${item.price.toStringAsFixed(2)}'.text
                        .color(redColor)
                        .fontFamily(bold)
                        .size(16)
                        .make(),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove item',
                onPressed: () => _cartController.removeProduct(item.id),
                icon: const Icon(Icons.delete_outline, color: fontGrey),
              ),
            ],
          ),
          12.heightBox,
          const Divider(height: 1),
          8.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              'Quantity'.text.color(darkFontGrey).fontFamily(semibold).make(),
              Row(
                children: [
                  _quantityButton(
                    icon: Icons.remove,
                    onPressed: item.quantity > 1
                        ? () => _cartController.updateQuantity(
                            item.id,
                            item.quantity - 1,
                          )
                        : null,
                  ),
                  SizedBox(
                    width: 38,
                    child: '${item.quantity}'.text
                        .color(darkFontGrey)
                        .fontFamily(bold)
                        .size(16)
                        .makeCentered(),
                  ),
                  _quantityButton(
                    icon: Icons.add,
                    onPressed: item.quantity < item.product.stock
                        ? () => _cartController.updateQuantity(
                            item.id,
                            item.quantity + 1,
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({required IconData icon, VoidCallback? onPressed}) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: textfieldGrey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _buildPriceSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: darkFontGrey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow('Subtotal', _cartController.subtotal),
            8.heightBox,
            _summaryRow('Estimated tax', _cartController.tax),
            10.heightBox,
            const Divider(height: 1),
            12.heightBox,
            _summaryRow(
              'Total',
              _cartController.subtotal + _cartController.tax,
              emphasis: true,
            ),
            14.heightBox,
            SizedBox(
              width: double.infinity,
              child: ourButton(
                title: 'Checkout (${_cartController.itemCount})',
                onPress: () => Get.to(() => const CheckoutScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool emphasis = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label.text
            .color(emphasis ? darkFontGrey : fontGrey)
            .fontFamily(emphasis ? bold : semibold)
            .size(emphasis ? 16 : 14)
            .make(),
        '\$${amount.toStringAsFixed(2)}'.text
            .color(emphasis ? redColor : darkFontGrey)
            .fontFamily(emphasis ? bold : semibold)
            .size(emphasis ? 18 : 14)
            .make(),
      ],
    );
  }
}
