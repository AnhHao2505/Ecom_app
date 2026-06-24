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

  final RxList<CartItem> items = <CartItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxString syncError = ''.obs;

  StreamSubscription<User?>? _authSubscription;
  Future<void> _writeQueue = Future.value();
  String? _activeUserId;

  int get itemCount =>
      items.fold(0, (itemTotal, item) => itemTotal + item.quantity);
  double get subtotal =>
      items.fold(0, (priceTotal, item) => priceTotal + item.lineTotal);
  double get tax => subtotal * 0.1;

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

  void addProduct(Product product, {int quantity = 1}) {
    if (!product.isInStock || quantity <= 0) return;

    final existingIndex = items.indexWhere((item) => item.id == product.id);
    if (existingIndex == -1) {
      items.add(
        CartItem(
          product: product,
          quantity: quantity.clamp(1, product.stock).toInt(),
        ),
      );
    } else {
      final existingItem = items[existingIndex];
      final newQuantity = (existingItem.quantity + quantity)
          .clamp(1, product.stock)
          .toInt();
      items[existingIndex] = existingItem.copyWith(quantity: newQuantity);
    }

    _persistCart();
  }

  void updateQuantity(String productId, int quantity) {
    final index = items.indexWhere((item) => item.id == productId);
    if (index == -1) return;

    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      final item = items[index];
      items[index] = item.copyWith(
        quantity: quantity.clamp(1, item.product.stock).toInt(),
      );
    }

    _persistCart();
  }

  void removeProduct(String productId) {
    items.removeWhere((item) => item.id == productId);
    _persistCart();
  }

  void clear() {
    items.clear();
    _persistCart();
  }

  Future<void> _handleAuthStateChange(User? user) async {
    _activeUserId = user?.uid;
    syncError.value = '';

    if (user == null) {
      items.clear();
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
        items.clear();
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
          ),
        );
      }

      items.assignAll(restoredItems);
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

    final savedItems = items
        .map(
          (item) => {
            'product': item.product.toMap(),
            'quantity': item.quantity,
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
