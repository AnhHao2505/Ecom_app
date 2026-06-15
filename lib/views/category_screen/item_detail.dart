import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/models/product.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:e_mart/widget_common/product_image.dart';

class ItemDetail extends StatefulWidget {
  final Product product;

  const ItemDetail({super.key, required this.product});

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  int quantity = 1;
  int selectedColor = 0;
  bool isFavorite = false;

  Product get product => widget.product;

  @override
  Widget build(BuildContext context) {
    final availableQuantity = product.quantity;
    final total = product.price * quantity;

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: Text(
          product.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: darkFontGrey, fontFamily: bold),
        ),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tính năng chia sẻ đang được cập nhật.'),
              ),
            ),
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
                    borderRadius: BorderRadius.circular(8),
                    child: ProductImage(
                      source: product.image,
                      width: double.infinity,
                      height: 350,
                    ),
                  ),
                  16.heightBox,
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      color: darkFontGrey,
                      fontFamily: bold,
                    ),
                  ),
                  10.heightBox,
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < product.rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: golden,
                          size: 24,
                        );
                      }),
                      8.widthBox,
                      Text(product.rating.toStringAsFixed(1)),
                    ],
                  ),
                  10.heightBox,
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: redColor,
                      fontSize: 20,
                      fontFamily: bold,
                    ),
                  ),
                  14.heightBox,
                  Container(
                    height: 68,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: textfieldGrey,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Seller'),
                              5.heightBox,
                              Text(
                                product.shop.isEmpty ? 'eMart' : product.shop,
                                style: const TextStyle(
                                  fontFamily: semibold,
                                  color: darkFontGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const CircleAvatar(
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
                    color: whiteColor,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        if (product.colors.isNotEmpty)
                          _optionRow(
                            label: 'Color:',
                            child: Wrap(
                              spacing: 8,
                              children: List.generate(product.colors.length, (
                                index,
                              ) {
                                final color = _parseColor(
                                  product.colors[index],
                                );
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => selectedColor = index),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selectedColor == index
                                            ? darkFontGrey
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    child: selectedColor == index
                                        ? Icon(
                                            Icons.check,
                                            color:
                                                color.computeLuminance() > 0.5
                                                ? Colors.black
                                                : Colors.white,
                                          )
                                        : null,
                                  ),
                                );
                              }),
                            ),
                          ),
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
                                availableQuantity == 0 ? '0' : '$quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: bold,
                                ),
                              ),
                              IconButton(
                                onPressed: quantity < availableQuantity
                                    ? () => setState(() => quantity++)
                                    : null,
                                icon: const Icon(Icons.add),
                              ),
                              Flexible(
                                child: Text(
                                  '($availableQuantity available)',
                                  style: const TextStyle(color: fontGrey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _optionRow(
                          label: 'Total:',
                          child: Text(
                            '\$${availableQuantity == 0 ? '0.00' : total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: redColor,
                              fontSize: 16,
                              fontFamily: bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  18.heightBox,
                  const Text(
                    'Description',
                    style: TextStyle(color: darkFontGrey, fontFamily: semibold),
                  ),
                  10.heightBox,
                  Text(
                    product.description.isEmpty
                        ? 'No description available.'
                        : product.description,
                    style: const TextStyle(color: darkFontGrey, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ourButton(
              onPress: availableQuantity == 0
                  ? null
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$quantity ${product.name} added to cart.',
                        ),
                      ),
                    ),
              title: availableQuantity == 0 ? 'Out of stock' : 'Add To Cart',
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionRow({required String label, required Widget child}) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(color: fontGrey)),
        ),
        Expanded(child: child),
      ],
    );
  }

  Color _parseColor(String value) {
    const namedColors = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'black': Colors.black,
      'white': Colors.white,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'grey': Colors.grey,
      'gray': Colors.grey,
    };

    final normalized = value.trim().toLowerCase();
    if (namedColors.containsKey(normalized)) return namedColors[normalized]!;

    final hex = normalized.replaceFirst('#', '');
    if (hex.length == 6 || hex.length == 8) {
      final colorValue = int.tryParse(
        hex.length == 6 ? 'ff$hex' : hex,
        radix: 16,
      );
      if (colorValue != null) return Color(colorValue);
    }
    return darkFontGrey;
  }
}
