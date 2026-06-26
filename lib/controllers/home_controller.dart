import 'package:e_mart/consts/firebase_consts.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final currentNavIndex = 0.obs;
  final searchQuery = ''.obs;
  final products = <Product>[].obs;
  final isLoading = true.obs;

  // Sort & Filter states
  final sortOption = 'popular'.obs; // popular, newest, price_asc, price_desc, rating
  final filterMinPrice = 0.0.obs;
  final filterMaxPrice = 2000.0.obs; // set high default
  final filterMinRating = 0.0.obs;
  final filterInStockOnly = false.obs;
  final filterBrands = <String>[].obs;
  final availableBrands = <String>[].obs;

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
      _extractBrands(fetchedProducts);
      isLoading.value = false;
    });
  }

  void _extractBrands(List<Product> items) {
    final Set<String> brands = {};
    for (var p in items) {
      if (p.attributes.containsKey('brand')) {
        brands.add(p.attributes['brand'].toString());
      }
    }
    availableBrands.value = brands.toList()..sort();
  }

  bool get hasActiveFilters {
    return filterMinPrice.value > 0 ||
        filterMaxPrice.value < 2000.0 ||
        filterMinRating.value > 0 ||
        filterInStockOnly.value ||
        filterBrands.isNotEmpty;
  }

  int get activeFilterCount {
    int count = 0;
    if (filterMinPrice.value > 0 || filterMaxPrice.value < 2000.0) count++;
    if (filterMinRating.value > 0) count++;
    if (filterInStockOnly.value) count++;
    if (filterBrands.isNotEmpty) count++;
    return count;
  }

  void resetFilters() {
    filterMinPrice.value = 0.0;
    filterMaxPrice.value = 2000.0;
    filterMinRating.value = 0.0;
    filterInStockOnly.value = false;
    filterBrands.clear();
  }

  List<Product> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();
    
    // 1. Search & Filter
    var result = products.where((product) {
      // Search
      if (query.isNotEmpty && !product.name.toLowerCase().contains(query)) {
        return false;
      }
      
      // Price
      if (product.price < filterMinPrice.value || product.price > filterMaxPrice.value) {
        return false;
      }
      
      // Rating
      if (product.rating < filterMinRating.value) {
        return false;
      }
      
      // In Stock
      if (filterInStockOnly.value && !product.isInStock) {
        return false;
      }
      
      // Brand
      if (filterBrands.isNotEmpty) {
        final brand = product.attributes['brand']?.toString() ?? '';
        if (!filterBrands.contains(brand)) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    // 2. Sort
    result.sort((a, b) {
      switch (sortOption.value) {
        case 'newest':
          return b.createdAt.compareTo(a.createdAt);
        case 'price_asc':
          return a.price.compareTo(b.price);
        case 'price_desc':
          return b.price.compareTo(a.price);
        case 'rating':
          return b.rating.compareTo(a.rating);
        case 'popular':
        default:
          return b.reviewCount.compareTo(a.reviewCount);
      }
    });

    return result;
  }

  List<Product> get featuredProducts =>
      products.where((product) => product.isFeatured).toList();

  List<Product> get trendingProducts {
    var list = products.toList();
    list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return list.take(8).toList();
  }

  List<Product> get newArrivals {
    var list = products.where((p) => DateTime.now().difference(p.createdAt).inDays <= 14).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
  
  List<Product> get flashSaleProducts {
    return products.where((p) => p.discountPercentage >= 30).toList();
  }

  List<Product> productsByCategory(String categoryKey) {
    return products
        .where(
          (product) =>
              product.category.toLowerCase() == categoryKey.toLowerCase(),
        )
        .toList();
  }
}
