import 'package:e_mart/consts/firebase_consts.dart';
import 'package:e_mart/models/product_model.dart';
import 'dart:convert' as dart_convert;
import 'package:get/get.dart';

class HomeController extends GetxController {
  final currentNavIndex = 0.obs;
  final searchQuery = ''.obs;
  final products = <Product>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchProducts();
  }

  void _fetchProducts() {
    firestore.collection(productCollection).snapshots().listen((snapshot) {
      final List<Product> fetchedProducts = snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
      products.value = fetchedProducts;
      isLoading.value = false;
    });
  }

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
