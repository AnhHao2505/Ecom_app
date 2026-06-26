import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart/consts/firebase_consts.dart';
import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/models/cart_item_model.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  CartController({bool seedWithDemoItems = false}) {
    if (seedWithDemoItems) {
      _addDemoItems();
    }
  }

  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxString syncError = ''.obs;

  StreamSubscription<User?>? _authSubscription;
  Future<void> _writeQueue = Future.value();
  String? _activeUserId;

  RxList<CartItem> get items => cartItems;
  int get itemCount => totalQuantity;
  double get subtotal =>
      cartItems.fold(0, (runningTotal, item) => runningTotal + item.lineTotal);
  double get tax => subtotal * 0.1;
  double get total => subtotal + tax;
  int get totalQuantity =>
      cartItems.fold(0, (runningTotal, item) => runningTotal + item.quantity);

  @override
  void onInit() {
    super.onInit();
    _authSubscription = auth.authStateChanges().listen(_handleAuthStateChange);
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  void addToCart({
    required Product product,
    required int quantity,
    String? selectedColor,
    String? selectedSize,
  }) {
    if (!product.isInStock || quantity <= 0) return;

    final safeQuantity = quantity.clamp(1, product.stock).toInt();
    final index = cartItems.indexWhere(
      (item) => item.hasSameOptions(
        otherProduct: product,
        color: selectedColor,
        size: selectedSize,
      ),
    );

    if (index == -1) {
      cartItems.add(
        CartItem(
          product: product,
          quantity: safeQuantity,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
        ),
      );
    } else {
      final item = cartItems[index];
      item.quantity = (item.quantity + safeQuantity)
          .clamp(1, product.stock)
          .toInt();
      cartItems.refresh();
    }

    _persistCart();
  }

  void addProduct(Product product, {int quantity = 1}) {
    addToCart(product: product, quantity: quantity);
  }

  void removeItem(String itemId) {
    cartItems.removeWhere((item) => item.id == itemId);
    _persistCart();
  }

  void removeProduct(String itemId) {
    removeItem(itemId);
  }

  void updateQuantity(String itemId, int quantity) {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final item = cartItems[index];
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    item.quantity = quantity.clamp(1, item.product.stock).toInt();
    cartItems.refresh();
    _persistCart();
  }

  void clearCart() {
    cartItems.clear();
    _persistCart();
  }

  void clear() {
    clearCart();
  }

  Future<void> _handleAuthStateChange(User? user) async {
    _activeUserId = user?.uid;
    syncError.value = '';

    if (user == null) {
      cartItems.clear();
      isLoading.value = false;
      return;
    }

    await _loadCart(user.uid);
  }

  Future<void> _loadCart(String userId) async {
    isLoading.value = true;
    try {
      final snapshot = await _cartDocument(userId).get();
      if (_activeUserId != userId) return;

      final rawItems = snapshot.data()?['items'];
      if (rawItems is! List) {
        cartItems.clear();
        return;
      }

      final restoredItems = <CartItem>[];
      for (final rawItem in rawItems) {
        if (rawItem is! Map) continue;

        final itemData = Map<String, dynamic>.from(rawItem);
        final rawProduct = itemData['product'];
        if (rawProduct is! Map) continue;

        final productData = Map<String, dynamic>.from(rawProduct);
        final productId = productData['id']?.toString() ?? '';
        if (productId.isEmpty) continue;

        final product = Product.fromMap(productData, productId);
        if (!product.isInStock) continue;

        final rawQuantity = itemData['quantity'];
        final quantity = rawQuantity is num ? rawQuantity.toInt() : 1;
        restoredItems.add(
          CartItem(
            product: product,
            quantity: quantity.clamp(1, product.stock).toInt(),
            selectedColor: itemData['selectedColor']?.toString(),
            selectedSize: itemData['selectedSize']?.toString(),
          ),
        );
      }

      cartItems.assignAll(restoredItems);
    } on FirebaseException {
      syncError.value = 'Unable to load your saved cart.';
    } finally {
      if (_activeUserId == userId) {
        isLoading.value = false;
      }
    }
  }

  void _persistCart() {
    final userId = _activeUserId;
    if (userId == null) return;

    final savedItems = cartItems
        .map(
          (item) => {
            'product': item.product.toMap(),
            'quantity': item.quantity,
            'selectedColor': item.selectedColor,
            'selectedSize': item.selectedSize,
          },
        )
        .toList(growable: false);

    _writeQueue = _writeQueue.then((_) async {
      try {
        await _cartDocument(
          userId,
        ).set({'items': savedItems, 'updatedAt': FieldValue.serverTimestamp()});
        if (_activeUserId == userId) {
          syncError.value = '';
        }
      } on FirebaseException {
        if (_activeUserId == userId) {
          syncError.value = 'Unable to save your cart changes.';
        }
      }
    });
  }

  DocumentReference<Map<String, dynamic>> _cartDocument(String userId) {
    return firestore
        .collection(usersCollection)
        .doc(userId)
        .collection('cart')
        .doc('active');
  }

  void _addDemoItems() {
    const quantities = [1, 2, 1, 1];
    for (var index = 0; index < 4; index++) {
      addProduct(dummyProducts[index], quantity: quantities[index]);
    }
  }
}
