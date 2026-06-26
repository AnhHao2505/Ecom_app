import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/models/cart_item_model.dart';
import 'package:e_mart/views/checkout_screen/checkout_screen.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:e_mart/widget_common/product_image.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
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
        title: cart.text.color(whiteColor).fontFamily(bold).size(20).make(),
        centerTitle: true,
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
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          return controller.cartItems.isEmpty
              ? _buildEmptyCart(context)
              : _buildCartBody(context, controller);
        }),
      ),
    );
  }

  Widget _buildCartBody(BuildContext context, CartController controller) {
    return Column(
      children: [
        if (controller.syncError.value.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: controller.syncError.value.text
                .color(warningColor)
                .fontFamily(semibold)
                .size(13)
                .make(),
          ),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: controller.cartItems.length,
            separatorBuilder: (_, _) => 12.heightBox,
            itemBuilder: (context, index) {
              return _buildCartItem(
                controller,
                controller.cartItems[index],
                context,
              );
            },
          ),
        ),
        _buildPriceSummary(context, controller),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              icCart,
              width: 100,
              height: 100,
              color: primaryColor,
            ),
          ),
          30.heightBox,
          "Your Cart is Empty".text
              .color(Theme.of(context).textTheme.bodyLarge?.color)
              .fontFamily(bold)
              .size(24)
              .make(),
          16.heightBox,
          "Looks like you haven't added anything yet.\nStart exploring our products!"
              .text
              .color(
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              )
              .fontFamily(regular)
              .size(16)
              .align(TextAlign.center)
              .make(),
          40.heightBox,
          SizedBox(
            width: 220,
            height: 54,
            child: ourButton(
              onPress: () {
                Get.find<HomeController>().currentNavIndex.value = 0;
              },
              color: primaryColor,
              title: "Start Shopping",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    CartController controller,
    CartItem item,
    BuildContext context,
  ) {
    final image = item.product.images.isEmpty ? '' : item.product.images.first;
    final options = [
      if (item.selectedColor != null) item.selectedColor!,
      if (item.selectedSize != null) 'Size ${item.selectedSize!}',
    ].join(' | ');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? darkDivider : lightDivider.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ProductImage(source: image, width: 100, height: 100),
              ),
              16.widthBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    item.product.name.text
                        .color(Theme.of(context).textTheme.bodyLarge?.color)
                        .fontFamily(semibold)
                        .size(16)
                        .maxLines(2)
                        .overflow(TextOverflow.ellipsis)
                        .make(),
                    6.heightBox,
                    if (options.isNotEmpty) ...[
                      options.text
                          .color(
                            Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          )
                          .fontFamily(semibold)
                          .size(13)
                          .make(),
                      6.heightBox,
                    ],
                    "\$${item.product.price.toStringAsFixed(2)}".text
                        .color(redColor)
                        .fontFamily(bold)
                        .size(18)
                        .make(),
                  ],
                ),
              ),
            ],
          ),
          16.heightBox,
          Divider(height: 1, color: isDark ? darkDivider : lightDivider),
          12.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        controller.updateQuantity(item.id, item.quantity - 1),
                    child: _quantityButton(
                      Icons.remove,
                      isDark ? darkDivider : textfieldGrey,
                      context,
                    ),
                  ),
                  16.widthBox,
                  "${item.quantity}".text
                      .color(Theme.of(context).textTheme.bodyLarge?.color)
                      .fontFamily(bold)
                      .size(16)
                      .make()
                      .box
                      .width(24)
                      .makeCentered(),
                  16.widthBox,
                  GestureDetector(
                    onTap: item.quantity < item.product.stock
                        ? () => controller.updateQuantity(
                            item.id,
                            item.quantity + 1,
                          )
                        : null,
                    child: _quantityButton(
                      Icons.add,
                      item.quantity < item.product.stock
                          ? primaryColor
                          : (isDark ? darkDivider : textfieldGrey),
                      context,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => controller.removeItem(item.id),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: redColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: redColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(
    IconData icon,
    Color borderColor,
    BuildContext context,
  ) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
      ),
      child: Icon(
        icon,
        size: 16,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildPriceSummary(BuildContext context, CartController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: context.screenWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summaryRow(
            "Subtotal",
            "\$${controller.subtotal.toStringAsFixed(2)}",
            context,
          ),
          12.heightBox,
          _summaryRow(
            "Tax (10%)",
            "\$${controller.tax.toStringAsFixed(2)}",
            context,
          ),
          12.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              "Shipping".text
                  .color(
                    Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  )
                  .fontFamily(semibold)
                  .size(16)
                  .make(),
              "FREE".text.color(successColor).fontFamily(bold).size(16).make(),
            ],
          ),
          20.heightBox,
          Divider(color: isDark ? darkDivider : lightDivider, height: 1),
          20.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              "Total".text
                  .color(Theme.of(context).textTheme.bodyLarge?.color)
                  .fontFamily(bold)
                  .size(18)
                  .make(),
              "\$${controller.total.toStringAsFixed(2)}".text
                  .color(redColor)
                  .fontFamily(bold)
                  .size(24)
                  .make(),
            ],
          ),
          24.heightBox,
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ourButton(
              onPress: () => Get.to(() => const CheckoutScreen()),
              title: "Checkout (${controller.totalQuantity})",
              color: primaryColor,
            ),
          ),
          SafeArea(child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label.text
            .color(
              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            )
            .fontFamily(semibold)
            .size(16)
            .make(),
        value.text
            .color(Theme.of(context).textTheme.bodyLarge?.color)
            .fontFamily(semibold)
            .size(16)
            .make(),
      ],
    );
  }
}
