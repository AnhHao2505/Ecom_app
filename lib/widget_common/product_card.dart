import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/views/item_detail_screen/item_detail.dart';
import 'package:e_mart/widget_common/product_image.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double imageHeight;

  const ProductCard({super.key, required this.product, this.imageHeight = 160});

  @override
  Widget build(BuildContext context) {
    final image = product.images.isEmpty ? '' : product.images.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? darkDivider : lightDivider.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.to(() => ItemDetail(product: product)),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ProductImage(
                  source: image,
                  width: double.infinity,
                  height: imageHeight,
                ),
                if (product.discountPercentage > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: redColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: redColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '-${product.discountPercentage.round()}%',
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 10,
                          fontFamily: bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    if (product.originalPrice > product.price)
                      Text(
                        '\$${product.originalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5) ?? fontGrey,
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '\$',
                          style: TextStyle(
                            color: redColor,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          product.price.toStringAsFixed(2),
                          style: const TextStyle(
                            color: redColor,
                            fontSize: 16,
                            fontFamily: semibold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: golden, size: 14),
                                  4.widthBox,
                                  Text(
                                    '${product.rating}',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? fontGrey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  8.widthBox,
                                  Expanded(
                                    child: Text(
                                      'Đã bán ${product.reviewCount}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? fontGrey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_shopping_cart, size: 16, color: whiteColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
