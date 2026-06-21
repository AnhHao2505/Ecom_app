import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WishlistController extends GetxController {
  final _storage = GetStorage();
  final wishlistIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    List<dynamic>? savedIds = _storage.read<List<dynamic>>('wishlist');
    if (savedIds != null) {
      wishlistIds.addAll(savedIds.cast<String>());
    }
  }

  void _saveToStorage() {
    _storage.write('wishlist', wishlistIds.toList());
  }

  bool isWishlisted(String productId) {
    return wishlistIds.contains(productId);
  }

  void toggle(String productId) {
    if (wishlistIds.contains(productId)) {
      wishlistIds.remove(productId);
    } else {
      wishlistIds.add(productId);
    }
    _saveToStorage();
  }

  int get count => wishlistIds.length;

  List<Product> get wishlistProducts {
    final homeController = Get.find<HomeController>();
    return homeController.products
        .where((product) => wishlistIds.contains(product.id))
        .toList();
  }
}
