import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/widget_common/product_image.dart';
import 'package:get/get.dart';

class QuickAddSheet extends StatefulWidget {
  final Product product;
  const QuickAddSheet({super.key, required this.product});

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  String? selectedColor;
  String? selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.product.colors.isNotEmpty) selectedColor = widget.product.colors.first;
    if (widget.product.sizes.isNotEmpty) selectedSize = widget.product.sizes.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? darkDivider : lightDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProductImage(
                    source: widget.product.images.isNotEmpty ? widget.product.images.first : '',
                    width: 60,
                    height: 60,
                  ),
                ),
                12.widthBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.heightBox,
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: redColor,
                          fontFamily: bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ],
            ),
            const Divider().paddingSymmetric(vertical: 16),
            
            if (widget.product.colors.isNotEmpty) ...[
              Text(
                chooseColor,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: bold,
                  fontSize: 16,
                ),
              ),
              8.heightBox,
              Wrap(
                spacing: 8,
                children: widget.product.colors.map((c) {
                  final isSelected = selectedColor == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => selectedColor = c);
                    },
                    selectedColor: primaryColor,
                    backgroundColor: Theme.of(context).cardColor,
                    labelStyle: TextStyle(
                      color: isSelected ? whiteColor : Theme.of(context).textTheme.bodyMedium?.color,
                      fontFamily: isSelected ? bold : semibold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : (isDark ? darkDivider : lightDivider),
                      ),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              16.heightBox,
            ],

            if (widget.product.sizes.isNotEmpty) ...[
              Text(
                chooseSize,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: bold,
                  fontSize: 16,
                ),
              ),
              8.heightBox,
              Wrap(
                spacing: 8,
                children: widget.product.sizes.map((s) {
                  final isSelected = selectedSize == s;
                  return ChoiceChip(
                    label: Text(s),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => selectedSize = s);
                    },
                    selectedColor: primaryColor,
                    backgroundColor: Theme.of(context).cardColor,
                    labelStyle: TextStyle(
                      color: isSelected ? whiteColor : Theme.of(context).textTheme.bodyMedium?.color,
                      fontFamily: isSelected ? bold : semibold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : (isDark ? darkDivider : lightDivider),
                      ),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              16.heightBox,
            ],

            24.heightBox,
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  Get.find<CartController>().addToCart(
                    product: widget.product,
                    quantity: 1,
                    selectedColor: selectedColor,
                    selectedSize: selectedSize,
                  );
                  Get.back();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: whiteColor),
                          8.widthBox,
                          const Text(addedToCart, style: TextStyle(fontFamily: semibold)),
                        ],
                      ),
                      action: SnackBarAction(
                        label: viewCart,
                        textColor: whiteColor,
                        onPressed: () => Get.find<HomeController>().currentNavIndex.value = 2,
                      ),
                      backgroundColor: successColor,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, color: whiteColor, size: 20),
                    8.widthBox,
                    const Text(
                      'Add to Cart',
                      style: TextStyle(
                        color: whiteColor,
                        fontFamily: bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
