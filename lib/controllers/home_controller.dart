import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../consts/firebase_consts.dart';
import '../models/product.dart';

class HomeController extends GetxController {
  var currentNavIndex = 0.obs;
  final productsList = <Product>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductsData();
  }

  Future<void> fetchProductsData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final snapshot = await FirebaseFirestore.instance
          .collection(productCollection)
          .get();

      productsList.assignAll(
        snapshot.docs.map(
          (doc) => Product.fromMap(doc.data(), documentId: doc.id),
        ),
      );
    } catch (e) {
      errorMessage.value = 'Không thể tải danh sách sản phẩm.';
    } finally {
      isLoading.value = false;
    }
  }

  List<Product> productsForCategory(String? category) {
    if (category == null || category.isEmpty) return productsList;

    final normalizedCategory = category.toLowerCase();
    return productsList.where((product) {
      final subCategory = product.subCategory.toLowerCase();
      return subCategory.contains(normalizedCategory) ||
          normalizedCategory.contains(subCategory);
    }).toList();
  }

  List<Product> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return productsList;

    return productsList.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.subCategory.toLowerCase().contains(query) ||
          product.shop.toLowerCase().contains(query);
    }).toList();
  }
}
