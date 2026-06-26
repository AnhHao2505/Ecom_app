import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/auth_controller.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/models/store_model.dart';
import 'package:e_mart/services/seller_service.dart';
import 'package:e_mart/views/auth_screen/login_screen.dart';
import 'package:e_mart/views/seller_screen/seller_product_form_screen.dart';
import 'package:e_mart/views/seller_screen/seller_shop_setup_screen.dart';
import 'package:e_mart/widget_common/product_image.dart';
import 'package:get/get.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerService = SellerService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seller Center',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontFamily: bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit shop',
            onPressed: () =>
                Get.to(() => const SellerShopSetupScreen(allowBack: true)),
            icon: const Icon(Icons.storefront_outlined),
          ),
          IconButton(
            tooltip: logout,
            onPressed: () async {
              final authController = Get.isRegistered<AuthController>()
                  ? Get.find<AuthController>()
                  : Get.put(AuthController());
              await authController.signoutMethod(context);
              Get.offAll(() => const LoginScreen());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const SellerProductFormScreen()),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        icon: const Icon(Icons.add),
        label: const Text('Product'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [darkBg, darkBgGradientEnd]
                : [lightBg, lightBgGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            StreamBuilder<Store?>(
              stream: sellerService.watchCurrentSellerStore(),
              builder: (context, snapshot) {
                final store = snapshot.data;
                if (store == null) {
                  return _SetupNotice(
                    onTap: () =>
                        Get.offAll(() => const SellerShopSetupScreen()),
                  );
                }
                return _StoreSummary(store: store);
              },
            ),
            20.heightBox,
            Row(
              children: [
                Text(
                  'Your Products',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      Get.to(() => const SellerProductFormScreen()),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            8.heightBox,
            StreamBuilder<List<Product>>(
              stream: sellerService.watchCurrentSellerProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final products = snapshot.data ?? const <Product>[];
                if (products.isEmpty) {
                  return _EmptyProducts(
                    onTap: () => Get.to(() => const SellerProductFormScreen()),
                  );
                }

                return Column(
                  children: products
                      .map(
                        (product) => _SellerProductTile(
                          product: product,
                          onEdit: () => Get.to(
                            () => SellerProductFormScreen(product: product),
                          ),
                          onDelete: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete product?'),
                                content: Text(
                                  'Remove ${product.name} from your shop.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (shouldDelete != true) return;
                            await sellerService.deleteProduct(product);
                          },
                        ),
                      )
                      .toList(),
                );
              },
            ),
            88.heightBox,
          ],
        ),
      ),
    );
  }
}

class _StoreSummary extends StatelessWidget {
  final Store store;

  const _StoreSummary({required this.store});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? darkDivider : lightDivider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ProductImage(
              source: store.logo,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
            ),
          ),
          14.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: bold,
                    fontSize: 17,
                  ),
                ),
                4.heightBox,
                Text(
                  store.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                Get.to(() => const SellerShopSetupScreen(allowBack: true)),
            icon: const Icon(Icons.edit_outlined, color: primaryColor),
          ),
        ],
      ),
    );
  }
}

class _SetupNotice extends StatelessWidget {
  final VoidCallback onTap;

  const _SetupNotice({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.storefront, color: primaryColor, size: 34),
          10.heightBox,
          Text(
            'Finish setting up your shop',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: bold,
              fontSize: 17,
            ),
          ),
          6.heightBox,
          Text(
            'Your store information is shown on product detail pages.',
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          14.heightBox,
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Set up shop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyProducts({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, color: primaryColor, size: 44),
          10.heightBox,
          Text(
            'No products yet',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: bold,
            ),
          ),
          6.heightBox,
          Text(
            'Create your first product for customers to see.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          14.heightBox,
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add),
            label: const Text('Add product'),
          ),
        ],
      ),
    );
  }
}

class _SellerProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SellerProductTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? darkDivider : lightDivider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ProductImage(
              source: product.images.isEmpty ? '' : product.images.first,
              width: 72,
              height: 72,
            ),
          ),
          12.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: semibold,
                  ),
                ),
                4.heightBox,
                Text(
                  product.category,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                6.heightBox,
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: primaryColor,
                    fontFamily: bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: primaryColor),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: redColor),
          ),
        ],
      ),
    );
  }
}
