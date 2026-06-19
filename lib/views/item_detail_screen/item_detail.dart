import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/controllers/cart_controller.dart';
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
  bool isFavorite = false;

  Product get product => widget.product;

  @override
  void initState() {
    super.initState();
    if (!product.isInStock) quantity = 0;
  }

  @override
  Widget build(BuildContext context) {
    final images = product.images.isEmpty ? [''] : product.images;
    final relatedProducts = dummyProducts
        .where(
          (item) => item.category == product.category && item.id != product.id,
        )
        .toList();

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: darkFontGrey, fontFamily: bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _showMessage('Sharing will be available soon.'),
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () => setState(() => isFavorite = !isFavorite),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_outline,
              color: isFavorite ? redColor : darkFontGrey,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
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
                    style: const TextStyle(
                      color: darkFontGrey,
                      fontFamily: bold,
                      fontSize: 19,
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
                          size: 22,
                        ),
                      ),
                      8.widthBox,
                      Text(
                        '${product.rating} (${product.reviewCount} reviews)',
                        style: const TextStyle(color: fontGrey),
                      ),
                    ],
                  ),
                  10.heightBox,
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: redColor,
                          fontFamily: bold,
                          fontSize: 21,
                        ),
                      ),
                      if (product.originalPrice > product.price)
                        Text(
                          '\$${product.originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: fontGrey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (product.discountPercentage > 0)
                        Text(
                          '${product.discountPercentage.round()}% off',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontFamily: bold,
                          ),
                        ),
                    ],
                  ),
                  14.heightBox,
                  Container(
                    height: 66,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: textfieldGrey,
                    child: const Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Seller'),
                              SizedBox(height: 5),
                              Text(
                                'E-Mart Store',
                                style: TextStyle(
                                  color: darkFontGrey,
                                  fontFamily: semibold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: whiteColor,
                          child: Icon(
                            Icons.message_rounded,
                            color: darkFontGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  12.heightBox,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: whiteColor,
                    child: Column(
                      children: [
                        if (product.colors.isNotEmpty)
                          _optionRow(
                            label: 'Color:',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
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
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color,
                                        border: Border.all(
                                          width: 3,
                                          color: selectedColorIndex == index
                                              ? redColor
                                              : textfieldGrey,
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
                          12.heightBox,
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
                                  selectedColor: redColor,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? whiteColor
                                        : darkFontGrey,
                                  ),
                                  onSelected: (_) =>
                                      setState(() => selectedSizeIndex = index),
                                );
                              }),
                            ),
                          ),
                        ],
                        8.heightBox,
                        _optionRow(
                          label: 'Quantity:',
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: quantity > 1
                                    ? () => setState(() => quantity--)
                                    : null,
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(
                                  color: darkFontGrey,
                                  fontFamily: bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                onPressed: quantity < product.stock
                                    ? () => setState(() => quantity++)
                                    : null,
                                icon: const Icon(Icons.add),
                              ),
                              Flexible(
                                child: Text(
                                  '(${product.stock} available)',
                                  style: const TextStyle(color: fontGrey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _optionRow(
                          label: 'Total:',
                          child: Text(
                            '\$${(product.price * quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: redColor,
                              fontFamily: bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  18.heightBox,
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: darkFontGrey,
                      fontFamily: semibold,
                      fontSize: 16,
                    ),
                  ),
                  8.heightBox,
                  Text(
                    product.description,
                    style: const TextStyle(color: darkFontGrey, height: 1.5),
                  ),
                  if (product.attributes.isNotEmpty) ...[
                    18.heightBox,
                    const Text(
                      'Product information',
                      style: TextStyle(
                        color: darkFontGrey,
                        fontFamily: semibold,
                        fontSize: 16,
                      ),
                    ),
                    8.heightBox,
                    ...product.attributes.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(color: darkFontGrey),
                        ),
                      ),
                    ),
                  ],
                  if (relatedProducts.isNotEmpty) ...[
                    22.heightBox,
                    productsYouMayLike.text
                        .fontFamily(bold)
                        .size(16)
                        .color(darkFontGrey)
                        .make(),
                    10.heightBox,
                    SizedBox(
                      height: 275,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        separatorBuilder: (_, _) => 10.widthBox,
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
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ourButton(
              onPress: product.isInStock ? _addToCart : null,
              title: product.isInStock ? 'Add To Cart' : 'Out of Stock',
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
          width: 90,
          child: Text(label, style: const TextStyle(color: fontGrey)),
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
