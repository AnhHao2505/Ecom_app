import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/models/store_model.dart';

class SellerService {
  String? get currentUserId => auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> storeDocument(String userId) {
    return firestore.collection(storesCollection).doc(userId);
  }

  Stream<Store?> watchStore(String userId) {
    return storeDocument(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return Store.fromMap(data, snapshot.id);
    });
  }

  Stream<Store?> watchCurrentSellerStore() {
    final userId = currentUserId;
    if (userId == null) return Stream.value(null);
    return watchStore(userId);
  }

  Future<Store?> fetchCurrentSellerStore() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final snapshot = await storeDocument(userId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return Store.fromMap(data, snapshot.id);
  }

  Future<void> saveCurrentSellerStore(Store store) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('You must be logged in as a seller.');

    final now = DateTime.now();
    final existing = await storeDocument(user.uid).get();
    final savedStore = store.copyWith(
      userId: user.uid,
      email: store.email.isEmpty ? user.email ?? '' : store.email,
      createdAt: existing.exists ? store.createdAt : now,
      updatedAt: now,
    );

    final storeData = savedStore.toMap()
      ..['id'] = FieldValue.delete()
      ..['ownerId'] = FieldValue.delete()
      ..['ownerUserId'] = FieldValue.delete();

    await storeDocument(user.uid).set(storeData, SetOptions(merge: true));
    await firestore.collection(usersCollection).doc(user.uid).set({
      'role': 'Seller',
      'shopSetupComplete': true,
      'shopId': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<Product>> watchCurrentSellerProducts() {
    final userId = currentUserId;
    if (userId == null) return Stream.value(const []);

    return firestore
        .collection(productCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final products = snapshot.docs
              .map((doc) => Product.fromMap(doc.data(), doc.id))
              .toList();
          products.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return products;
        });
  }

  Future<void> saveProduct(Product product) async {
    final userId = currentUserId;
    if (userId == null) throw StateError('You must be logged in as a seller.');

    final now = DateTime.now();
    final isNew = product.id.isEmpty;
    final document = isNew
        ? firestore.collection(productCollection).doc()
        : firestore.collection(productCollection).doc(product.id);
    final savedProduct = product.copyWith(
      id: document.id,
      userId: userId,
      storeId: userId,
      createdAt: isNew ? now : product.createdAt,
      updatedAt: now,
    );

    await document.set(savedProduct.toMap(), SetOptions(merge: !isNew));
  }

  Future<void> deleteProduct(Product product) async {
    final userId = currentUserId;
    if (userId == null || product.userId != userId) {
      throw StateError('You can only delete your own products.');
    }

    await firestore.collection(productCollection).doc(product.id).delete();
  }
}
