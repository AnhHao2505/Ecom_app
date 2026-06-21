import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RecentViewController extends GetxController {
  final _storage = GetStorage();
  final recentIds = <String>[].obs;
  
  final int _maxItems = 10;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    List<dynamic>? savedIds = _storage.read<List<dynamic>>('recent_views');
    if (savedIds != null) {
      recentIds.assignAll(savedIds.cast<String>());
    }
  }

  void _saveToStorage() {
    _storage.write('recent_views', recentIds.toList());
  }

  void addView(String productId) {
    if (recentIds.contains(productId)) {
      recentIds.remove(productId);
    }
    recentIds.insert(0, productId);
    
    if (recentIds.length > _maxItems) {
      recentIds.removeLast();
    }
    
    _saveToStorage();
  }

  List<Product> get recentProducts {
    final homeController = Get.find<HomeController>();
    List<Product> products = [];
    for (String id in recentIds) {
      final idx = homeController.products.indexWhere((p) => p.id == id);
      if (idx != -1) {
        products.add(homeController.products[idx]);
      }
    }
    return products;
  }
}
