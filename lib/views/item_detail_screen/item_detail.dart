import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/controllers/wishlist_controller.dart';
import 'package:e_mart/controllers/recent_view_controller.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:e_mart/widget_common/product_card.dart';
import 'package:e_mart/widget_common/product_image.dart';
import 'package:get/get.dart';

class ItemDetail extends StatefulWidget {
  final Product product;

  const ItemDetail({super.key, required this.product});

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  final CartController cartController = Get.find<CartController>();
  int quantity = 1;
  int selectedColorIndex = 0;
  int selectedSizeIndex = 0;

  Product get product => widget.product;

  @override
  void initState() {
    super.initState();
    if (!product.isInStock) quantity = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Get.find<RecentViewController>().addView(product.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = product.images.isEmpty ? [''] : product.images;
    final homeController = Get.find<HomeController>();
    final relatedProducts = homeController.products
        .where(
          (item) => item.category == product.category && item.id != product.id,
        )
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontFamily: bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _showMessage('Sharing will be available soon.'),
            icon: Icon(Icons.share, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          Obx(() {
            final isWishlisted = Get.find<WishlistController>().isWishlisted(product.id);
            return IconButton(
              onPressed: () => Get.find<WishlistController>().toggle(product.id),
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_outline,
                color: isWishlisted ? redColor : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: VxSwiper.builder(
                      autoPlay: images.length > 1,
                      height: 350,
                      aspectRatio: 16 / 9,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return ProductImage(
                          source: images[index],
                          width: double.infinity,
                          height: 350,
                        );
                      },
                    ),
                  ),
                  16.heightBox,
                  Text(
                    product.name,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: bold,
                      fontSize: 20,
                    ),
                  ),
                  10.heightBox,
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < product.rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: golden,
                          size: 20,
                        ),
                      ),
                      8.widthBox,
                      Text(
                        '${product.rating} (${product.reviewCount} reviews)',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
                      ),
                    ],
                  ),
                  16.heightBox,
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: primaryColor,
                          fontFamily: bold,
                          fontSize: 24,
                        ),
                      ),
                      if (product.originalPrice > product.price)
                        Text(
                          '\$${product.originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                            decoration: TextDecoration.lineThrough,
                            fontSize: 16,
                          ),
                        ),
                      if (product.discountPercentage > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Save ${product.discountPercentage.round()}%',
                            style: const TextStyle(
                              color: warningColor,
                              fontFamily: bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  20.heightBox,
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: primaryColor,
                          child: Icon(
                            Icons.store,
                            color: whiteColor,
                          ),
                        ),
                        16.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'E-Mart Store',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                  fontFamily: semibold,
                                  fontSize: 16,
                                ),
                              ),
                              4.heightBox,
                              Text('Official Seller', style: TextStyle(color: successColor, fontSize: 12, fontFamily: semibold)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_outline, color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                  20.heightBox,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (product.colors.isNotEmpty)
                          _optionRow(
                            label: 'Color:',
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: List.generate(product.colors.length, (
                                index,
                              ) {
                                final color = _colorFromName(
                                  product.colors[index],
                                );
                                return Tooltip(
                                  message: product.colors[index],
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => selectedColorIndex = index,
                                    ),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color,
                                        border: Border.all(
                                          width: selectedColorIndex == index ? 3 : 1,
                                          color: selectedColorIndex == index
                                              ? primaryColor
                                              : Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      child: selectedColorIndex == index
                                          ? Icon(
                                              Icons.check,
                                              size: 20,
                                              color:
                                                  color.computeLuminance() > 0.5
                                                  ? Colors.black
                                                  : Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        if (product.sizes.isNotEmpty) ...[
                          16.heightBox,
                          _optionRow(
                            label: 'Size:',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(product.sizes.length, (
                                index,
                              ) {
                                final isSelected = selectedSizeIndex == index;
                                return ChoiceChip(
                                  label: Text(product.sizes[index]),
                                  selected: isSelected,
                                  selectedColor: primaryColor,
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? whiteColor
                                        : Theme.of(context).textTheme.bodyMedium?.color,
                                    fontFamily: isSelected ? bold : regular,
                                  ),
                                  onSelected: (_) =>
                                      setState(() => selectedSizeIndex = index),
                                );
                              }),
                            ),
                          ),
                        ],
                        16.heightBox,
                        _optionRow(
                          label: 'Quantity:',
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).dividerColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: quantity > 1
                                          ? () => setState(() => quantity--)
                                          : null,
                                      icon: const Icon(Icons.remove, size: 16),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                    ),
                                    Text(
                                      '$quantity',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        fontFamily: bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: quantity < product.stock
                                          ? () => setState(() => quantity++)
                                          : null,
                                      icon: const Icon(Icons.add, size: 16),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                    ),
                                  ],
                                ),
                              ),
                              12.widthBox,
                              Flexible(
                                child: Text(
                                  '(${product.stock} available)',
                                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        16.heightBox,
                        const Divider(),
                        16.heightBox,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Price:',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontFamily: semibold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '\$${(product.price * quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: primaryColor,
                                fontFamily: bold,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  24.heightBox,
                  Text(
                    'Description',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: bold,
                      fontSize: 18,
                    ),
                  ),
                  12.heightBox,
                  Text(
                    product.description,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.6),
                  ),
                  if (product.attributes.isNotEmpty) ...[
                    24.heightBox,
                    Text(
                      'Product Information',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: bold,
                        fontSize: 18,
                      ),
                    ),
                    12.heightBox,
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: product.attributes.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    entry.value.toString(),
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontFamily: semibold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  if (relatedProducts.isNotEmpty) ...[
                    30.heightBox,
                    Row(
                      children: [
                        Container(width: 4, height: 24, color: primaryColor),
                        8.widthBox,
                        Text(
                          productsYouMayLike,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    16.heightBox,
                    SizedBox(
                      height: 290,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        separatorBuilder: (_, _) => 16.widthBox,
                        itemBuilder: (context, index) => SizedBox(
                          width: 170,
                          child: ProductCard(
                            product: relatedProducts[index],
                            imageHeight: 145,
                          ),
                        ),
                      ),
                    ),
                  ],
                  30.heightBox,
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ourButton(
                  color: product.isInStock ? primaryColor : Theme.of(context).disabledColor,
                  onPress: product.isInStock ? _addToCart : null,
                  title: product.isInStock ? 'Add To Cart' : 'Out of Stock',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label, 
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontFamily: semibold,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addToCart() {
    final selectedColor = product.colors.isEmpty
        ? null
        : product.colors[selectedColorIndex];
    final selectedSize = product.sizes.isEmpty
        ? null
        : product.sizes[selectedSizeIndex];

    cartController.addToCart(
      product: product,
      quantity: quantity,
      selectedColor: selectedColor,
      selectedSize: selectedSize,
    );

    _showMessage('Added ${product.name} x$quantity to cart.');
  }

  Color _colorFromName(String value) {
    const colors = {
      'black': Colors.black,
      'white': Colors.white,
      'red': Colors.red,
      'blue': Colors.blue,
      'pink': Colors.pink,
      'purple': Colors.purple,
      'gold': Colors.amber,
      'silver': Colors.grey,
      'brown': Colors.brown,
      'grey': Colors.grey,
      'dark blue': Color(0xff0d47a1),
      'light blue': Color(0xff90caf9),
    };
    return colors[value.toLowerCase()] ?? darkFontGrey;
  }
}
