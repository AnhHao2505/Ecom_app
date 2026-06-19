import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/widget_common/bg_widget.dart';
import 'package:e_mart/widget_common/product_card.dart';
import 'package:get/get.dart';

class CategoryDetail extends StatelessWidget {
  final String categoryKey;
  final String title;

  const CategoryDetail({
    super.key,
    required this.categoryKey,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final products = controller.productsByCategory(categoryKey);

    return bgWidget(
      child: Scaffold(
        appBar: AppBar(title: title.text.fontFamily(bold).white.make()),
        body: products.isEmpty
            ? const Center(
                child: Text(
                  'No products found in this category.',
                  style: TextStyle(color: darkFontGrey),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                physics: const BouncingScrollPhysics(),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 290,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index]);
                },
              ),
      ),
    );
  }
}
