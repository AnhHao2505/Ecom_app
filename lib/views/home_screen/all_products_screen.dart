import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/widget_common/product_card.dart';
import 'package:e_mart/widget_common/sort_chips.dart';
import 'package:get/get.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? darkBg : lightBg,
      appBar: AppBar(
        title: Text(allProducts, style: TextStyle(fontFamily: bold, color: isDark ? whiteColor : darkFontGrey)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? whiteColor : darkFontGrey),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                onChanged: (value) => controller.searchQuery.value = value,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  hintText: searchAnything,
                  hintStyle: TextStyle(color: textfieldGrey.withOpacity(0.8)),
                ),
              ),
            ),
          ),
          
          // Sort & Filter Bar
          const SortChips(),
          
          16.heightBox,
          
          // Result Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Obx(() {
              final count = controller.filteredProducts.length;
              return Row(
                children: [
                  Text(
                    '$count Products Found',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontFamily: semibold,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }),
          ),
          
          12.heightBox,
          
          // Grid
          Expanded(
            child: Obx(() {
              final products = controller.filteredProducts;
              
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3)),
                      16.heightBox,
                      Text(
                        'No products match your criteria.',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
                      ),
                      16.heightBox,
                      TextButton(
                        onPressed: () {
                          controller.searchQuery.value = '';
                          controller.resetFilters();
                        },
                        child: const Text('Clear Filters', style: TextStyle(color: primaryColor, fontFamily: bold)),
                      ),
                    ],
                  ),
                );
              }
              
              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 320,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
