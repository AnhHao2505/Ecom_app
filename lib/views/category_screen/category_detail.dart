import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/home_controller.dart';
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.4),
        title: title.text.fontFamily(bold).white.make(),
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [darkBg, darkBgGradientEnd]
                : [lightBg, lightBgGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: products.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
                    ),
                    16.heightBox,
                    Text(
                      'No products found',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 18,
                        fontFamily: bold,
                      ),
                    ),
                    8.heightBox,
                    Text(
                      'Check back later for new items in this category.',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        '${products.length} products found',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontFamily: semibold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 270,
                    ),
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
