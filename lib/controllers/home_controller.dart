import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final currentNavIndex = 0.obs;
  final searchQuery = ''.obs;
  final products = <Product>[...dummyProducts].obs;

  List<Product> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return products;

    return products.where((product) {
      return product.name.toLowerCase().contains(query);
    }).toList();
  }

  List<Product> get featuredProducts =>
      filteredProducts.where((product) => product.isFeatured).toList();

  List<Product> productsByCategory(String categoryKey) {
    return products
        .where(
          (product) =>
              product.category.toLowerCase() == categoryKey.toLowerCase(),
        )
        .toList();
  }
}
