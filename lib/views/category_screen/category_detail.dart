import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/views/item_detail_screen/item_detail.dart';
import 'package:get/get.dart';

class CategoryDetail extends StatelessWidget {
  final String title;

  const CategoryDetail({super.key, required this.title});

  String get _categoryKey {
    switch (title) {
      case womenClothing:
        return 'womenClothing';
      case menClothingFashion:
        return 'menClothingFashion';
      case compAccess:
        return 'compAccess';
      case automobile:
        return 'automobile';
      case kidtoys:
        return 'kidtoys';
      case sports:
        return 'sports';
      case jewelery:
        return 'jewelery';
      case cellphone:
        return 'cellphone';
      case furniture:
        return 'furniture';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = dummyProducts
        .where((product) => product.category == _categoryKey)
        .toList();

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: redColor,
        elevation: 0,
        title: title.text.fontFamily(bold).white.make(),
      ),
      body: Container(
        color: lightGrey,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              buildHeader(context, products.length),
              20.heightBox,
              if (products.isEmpty)
                buildEmptyItems()
              else
                buildItems(context, products),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: darkFontGrey.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                6.heightBox,
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: '$count',
                        style: TextStyle(color: Colors.green),
                      ),
                      const TextSpan(text: ' products available!'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 18, color: redColor),
                6.widthBox,
                "Filter".text.color(darkFontGrey).size(13).make(),
              ],
            ),
          ).onTap(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filter options coming soon!')),
            );
          }),
        ],
      ),
    );
  }

  Widget buildEmptyItems() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 60, color: textfieldGrey),
            12.heightBox,
            "No products available".text
                .color(Colors.black)
                .size(16)
                .semiBold
                .make(),
            8.heightBox,
            "Check another category or try again later.".text
                .color(Colors.black)
                .center
                .make(),
          ],
        ),
      ),
    );
  }

  Widget buildItems(BuildContext context, List<Product> products) {
    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 310,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => Get.to(() => ItemDetail(product: product)),
            child: Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: darkFontGrey.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      // image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                        child: Image.asset(
                          product.images.isNotEmpty ? product.images[0] : imgP5,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // discount tag
                      if (product.discountPercentage > 0)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: redColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                "${product.discountPercentage.toStringAsFixed(0)}% OFF"
                                    .text
                                    .size(10)
                                    .white
                                    .make(),
                          ),
                        ),
                    ],
                  ),
                  // details
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // product name
                        product.name.text
                            .fontFamily(bold)
                            .color(darkFontGrey)
                            .maxLines(2)
                            .overflow(TextOverflow.ellipsis)
                            .make(),
                        6.heightBox,
                        // star and qty
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 14,
                            ),
                            4.widthBox,
                            "${product.rating}".text
                                .size(11)
                                .color(Colors.black)
                                .make(),
                            6.widthBox,
                            "(${product.reviewCount})".text
                                .size(10)
                                .color(darkFontGrey)
                                .make(),
                          ],
                        ),
                        10.heightBox,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            "\$${product.price.toStringAsFixed(2)}".text
                                .color(redColor)
                                .fontFamily(bold)
                                .size(16)
                                .make(),
                            6.widthBox,
                            if (product.originalPrice > product.price)
                              "\$${product.originalPrice.toStringAsFixed(2)}"
                                  .text
                                  .color(darkFontGrey)
                                  .lineThrough
                                  .size(11)
                                  .make(),
                          ],
                        ),
                        10.heightBox,
                        Row(
                          children: [
                            Icon(
                              product.isInStock
                                  ? Icons.check_circle
                                  : Icons.remove_circle,
                              size: 14,
                              color: product.isInStock
                                  ? Colors.green
                                  : redColor,
                            ),
                            6.widthBox,
                            product.isInStock
                                ? 'In Stock'.text
                                      .size(11)
                                      .color(Colors.green)
                                      .make()
                                : 'Out of Stock'.text
                                      .size(11)
                                      .color(redColor)
                                      .make(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
