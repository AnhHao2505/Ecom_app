import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/wishlist_controller.dart';
import 'package:e_mart/widget_common/product_card.dart';
import 'package:get/get.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WishlistController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? darkBg : lightBg,
      appBar: AppBar(
        title: Text(wishList, style: TextStyle(fontFamily: bold, color: isDark ? whiteColor : darkFontGrey)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? whiteColor : darkFontGrey),
      ),
      body: Obx(() {
        final products = controller.wishlistProducts;
        
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3)),
                16.heightBox,
                Text(
                  'Your wishlist is empty',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
                ),
                16.heightBox,
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Get.back(); // Go back to profile or home
                  },
                  child: const Text('Start Shopping', style: TextStyle(color: whiteColor, fontFamily: bold)),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
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
    );
  }
}
