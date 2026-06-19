import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/views/item_detail_screen/item_detail.dart';
import 'package:e_mart/widget_common/product_image.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double imageHeight;

  const ProductCard({super.key, required this.product, this.imageHeight = 150});

  @override
  Widget build(BuildContext context) {
    final image = product.images.isEmpty ? '' : product.images.first;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Get.to(() => ItemDetail(product: product)),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
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
                if (product.isNew)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _badge('NEW', Colors.green),
                  ),
                if (product.discountPercentage > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _badge(
                      '-${product.discountPercentage.round()}%',
                      redColor,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkFontGrey,
                        fontFamily: semibold,
                      ),
                    ),
                    6.heightBox,
                    Row(
                      children: [
                        const Icon(Icons.star, color: golden, size: 16),
                        4.widthBox,
                        Text(
                          '${product.rating} (${product.reviewCount})',
                          style: const TextStyle(color: fontGrey, fontSize: 11),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (product.originalPrice > product.price)
                      Text(
                        '\$${product.originalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: fontGrey,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: redColor,
                        fontSize: 16,
                        fontFamily: bold,
                      ),
                    ),
                    Text(
                      product.isInStock ? 'In stock' : 'Out of stock',
                      style: TextStyle(
                        color: product.isInStock ? Colors.green : redColor,
                        fontSize: 11,
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

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: whiteColor,
          fontSize: 10,
          fontFamily: bold,
        ),
      ),
    );
  }
}
