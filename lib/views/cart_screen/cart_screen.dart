import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/widget_common/our_button.dart';

// Dummy Cart Item Model
class CartItem {
  final String id;
  final String name;
  final String image;
  final double price;
  final String category;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    this.quantity = 1,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Dummy cart data
  late List<CartItem> cartItems = [
    CartItem(
      id: '1',
      name: 'Premium Wireless Headphones',
      image: imgP1,
      price: 79.99,
      category: 'Electronics',
      quantity: 1,
    ),
    CartItem(
      id: '2',
      name: 'Smart Watch Pro',
      image: imgP2,
      price: 199.99,
      category: 'Electronics',
      quantity: 2,
    ),
    CartItem(
      id: '3',
      name: 'Fashion Jacket',
      image: imgP3,
      price: 89.99,
      category: 'Clothing',
      quantity: 1,
    ),
    CartItem(
      id: '4',
      name: 'Designer Sunglasses',
      image: imgP4,
      price: 149.99,
      category: 'Accessories',
      quantity: 1,
    ),
  ];

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get tax {
    return subtotal * 0.1; // 10% tax
  }

  double get total {
    return subtotal + tax;
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        cartItems[index].quantity = newQuantity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        title: cart.text.color(darkFontGrey).fontFamily(bold).make(),
        centerTitle: false,
      ),
      body: cartItems.isEmpty ? _buildEmptyCart() : _buildCartBody(),
    );
  }

  Widget _buildCartBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                ...List.generate(
                  cartItems.length,
                  (index) => _buildCartItem(context, index),
                ),
              ],
            ),
          ),
        ),
        _buildPriceSummary(),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(icCart, width: 80, height: 80)
              .box
              .padding(const EdgeInsets.all(20))
              .make(),
          10.heightBox,
          "Your Cart is Empty"
              .text
              .color(darkFontGrey)
              .fontFamily(bold)
              .size(18)
              .make(),
          5.heightBox,
          "Start shopping to add items to your cart"
              .text
              .color(fontGrey)
              .fontFamily(semibold)
              .size(14)
              .make(),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, int index) {
    final item = cartItems[index];
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
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: lightGrey,
                ),
                child: Image.asset(item.image, fit: BoxFit.cover),
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
                    "\$${item.price.toStringAsFixed(2)}"
                        .text
                        .color(redColor)
                        .fontFamily(bold)
                        .size(16)
                        .make(),
                  ],
                ),
              ),
              Image.asset(icTrash, width: 20, height: 20)
                  .box
                  .padding(const EdgeInsets.all(8))
                  .make()
                  .onTap(() => removeItem(index)),
            ],
          ),
          12.heightBox,
          const Divider(height: 1),
          12.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              "Quantity:"
                  .text
                  .color(darkFontGrey)
                  .fontFamily(semibold)
                  .make(),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (item.quantity > 1) {
                        updateQuantity(index, item.quantity - 1);
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: textfieldGrey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset(icMinus, width: 16, height: 16)
                          .box
                          .makeCentered(),
                    ),
                  ),
                  12.widthBox,
                  "${item.quantity}"
                      .text
                      .color(darkFontGrey)
                      .fontFamily(bold)
                      .size(16)
                      .make()
                      .box
                      .width(30)
                      .makeCentered(),
                  12.widthBox,
                  GestureDetector(
                    onTap: () =>
                        updateQuantity(index, item.quantity + 1),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: redColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset(icPlus, width: 16, height: 16)
                          .box
                          .makeCentered(),
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

  Widget _buildPriceSummary() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
              "Price Summary"
                  .text
                  .color(darkFontGrey)
                  .fontFamily(bold)
                  .size(16)
                  .make(),
              16.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Subtotal:"
                      .text
                      .color(fontGrey)
                      .fontFamily(semibold)
                      .make(),
                  "\$${subtotal.toStringAsFixed(2)}"
                      .text
                      .color(darkFontGrey)
                      .fontFamily(semibold)
                      .make(),
                ],
              ),
              8.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Tax (10%):"
                      .text
                      .color(fontGrey)
                      .fontFamily(semibold)
                      .make(),
                  "\$${tax.toStringAsFixed(2)}"
                      .text
                      .color(darkFontGrey)
                      .fontFamily(semibold)
                      .make(),
                ],
              ),
              8.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Shipping:"
                      .text
                      .color(fontGrey)
                      .fontFamily(semibold)
                      .make(),
                  "FREE".text.color(redColor).fontFamily(bold).make(),
                ],
              ),
              12.heightBox,
              Divider(color: textfieldGrey, height: 1),
              12.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Total:"
                      .text
                      .color(darkFontGrey)
                      .fontFamily(bold)
                      .size(16)
                      .make(),
                  "\$${total.toStringAsFixed(2)}"
                      .text
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
                        content: "Proceeding to checkout"
                            .text
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
        ),
      ],
    );
  }
}
