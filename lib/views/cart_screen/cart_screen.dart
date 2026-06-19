import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/models/cart_item_model.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:e_mart/widget_common/product_image.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        title: cart.text.color(darkFontGrey).fontFamily(bold).make(),
        centerTitle: false,
      ),
      body: Obx(
        () => controller.cartItems.isEmpty
            ? _buildEmptyCart()
            : _buildCartBody(context, controller),
      ),
    );
  }

  Widget _buildCartBody(BuildContext context, CartController controller) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.cartItems.length,
            separatorBuilder: (_, _) => 4.heightBox,
            itemBuilder: (context, index) {
              return _buildCartItem(controller, controller.cartItems[index]);
            },
          ),
        ),
        _buildPriceSummary(context, controller),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icCart,
            width: 80,
            height: 80,
          ).box.padding(const EdgeInsets.all(20)).make(),
          10.heightBox,
          "Your Cart is Empty".text
              .color(darkFontGrey)
              .fontFamily(bold)
              .size(18)
              .make(),
          5.heightBox,
          "Start shopping to add items to your cart".text
              .color(fontGrey)
              .fontFamily(semibold)
              .size(14)
              .make(),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartController controller, CartItem item) {
    final image = item.product.images.isEmpty ? '' : item.product.images.first;
    final options = [
      if (item.selectedColor != null) item.selectedColor!,
      if (item.selectedSize != null) 'Size ${item.selectedSize!}',
    ].join(' | ');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: darkFontGrey.withValues(alpha: 0.1),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ProductImage(source: image, width: 100, height: 100),
              ),
              12.widthBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    item.product.name.text
                        .color(darkFontGrey)
                        .fontFamily(semibold)
                        .size(14)
                        .maxLines(2)
                        .overflow(TextOverflow.ellipsis)
                        .make(),
                    5.heightBox,
                    item.product.category.text
                        .color(fontGrey)
                        .fontFamily(semibold)
                        .size(12)
                        .make(),
                    if (options.isNotEmpty) ...[
                      5.heightBox,
                      options.text
                          .color(fontGrey)
                          .fontFamily(semibold)
                          .size(12)
                          .make(),
                    ],
                    8.heightBox,
                    "\$${item.product.price.toStringAsFixed(2)}".text
                        .color(redColor)
                        .fontFamily(bold)
                        .size(16)
                        .make(),
                  ],
                ),
              ),
              Image.asset(icTrash, width: 20, height: 20).box
                  .padding(const EdgeInsets.all(8))
                  .make()
                  .onTap(() => controller.removeItem(item.id)),
            ],
          ),
          12.heightBox,
          const Divider(height: 1),
          12.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              "Quantity:".text.color(darkFontGrey).fontFamily(semibold).make(),
              Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        controller.updateQuantity(item.id, item.quantity - 1),
                    child: _quantityButton(icMinus, textfieldGrey),
                  ),
                  12.widthBox,
                  "${item.quantity}".text
                      .color(darkFontGrey)
                      .fontFamily(bold)
                      .size(16)
                      .make()
                      .box
                      .width(30)
                      .makeCentered(),
                  12.widthBox,
                  GestureDetector(
                    onTap: item.quantity < item.product.stock
                        ? () => controller.updateQuantity(
                            item.id,
                            item.quantity + 1,
                          )
                        : null,
                    child: _quantityButton(
                      icPlus,
                      item.quantity < item.product.stock
                          ? redColor
                          : textfieldGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(String icon, Color borderColor) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Image.asset(icon, width: 16, height: 16).box.makeCentered(),
    );
  }

  Widget _buildPriceSummary(BuildContext context, CartController controller) {
    return Container(
      width: context.screenWidth,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: darkFontGrey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          "Price Summary".text
              .color(darkFontGrey)
              .fontFamily(bold)
              .size(16)
              .make(),
          16.heightBox,
          _summaryRow(
            "Subtotal:",
            "\$${controller.subtotal.toStringAsFixed(2)}",
          ),
          8.heightBox,
          _summaryRow("Tax (10%):", "\$${controller.tax.toStringAsFixed(2)}"),
          8.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              "Shipping:".text.color(fontGrey).fontFamily(semibold).make(),
              "FREE".text.color(redColor).fontFamily(bold).make(),
            ],
          ),
          12.heightBox,
          Divider(color: textfieldGrey, height: 1),
          12.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              "Total:".text
                  .color(darkFontGrey)
                  .fontFamily(bold)
                  .size(16)
                  .make(),
              "\$${controller.total.toStringAsFixed(2)}".text
                  .color(redColor)
                  .fontFamily(bold)
                  .size(18)
                  .make(),
            ],
          ),
          16.heightBox,
          SizedBox(
            width: double.infinity,
            child: ourButton(
              onPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: "Proceeding to checkout".text
                        .color(whiteColor)
                        .fontFamily(semibold)
                        .make(),
                    backgroundColor: redColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              title: "Proceed to Checkout",
              color: redColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label.text.color(fontGrey).fontFamily(semibold).make(),
        value.text.color(darkFontGrey).fontFamily(semibold).make(),
      ],
    );
  }
}
