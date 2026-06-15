import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/models/product.dart';
import 'package:e_mart/views/category_screen/item_detail.dart';
import 'package:e_mart/widget_common/product_image.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double imageHeight;

  const ProductCard({super.key, required this.product, this.imageHeight = 160});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => Get.to(() => ItemDetail(product: product)),
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(
              source: product.image,
              width: double.infinity,
              height: imageHeight,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: semibold,
                        color: darkFontGrey,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: redColor,
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
