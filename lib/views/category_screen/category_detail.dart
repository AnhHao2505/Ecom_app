import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/widget_common/bg_widget.dart';
import 'package:e_mart/widget_common/product_card.dart';
import 'package:get/get.dart';

class CategoryDetail extends StatelessWidget {
  final String? title;

  const CategoryDetail({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return bgWidget(
      child: Scaffold(
        appBar: AppBar(
          title: (title ?? categories).text.fontFamily(bold).white.make(),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: redColor),
            );
          }

          if (controller.errorMessage.isNotEmpty) {
            return _MessageState(
              message: controller.errorMessage.value,
              onRetry: controller.fetchProductsData,
            );
          }

          final products = controller.productsForCategory(title);
          if (products.isEmpty) {
            return const _MessageState(
              message: 'Chưa có sản phẩm trong danh mục này.',
            );
          }

          return RefreshIndicator(
            color: redColor,
            onRefresh: controller.fetchProductsData,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              physics: const BouncingScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 270,
              ),
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            ),
          );
        }),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;

  const _MessageState({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            12.heightBox,
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ],
      ),
    );
  }
}
