import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart/models/notification_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _primaryCol = 'notifications ';
  static const String _fallbackCol = 'notifications';

  String _activeCol = _primaryCol;
  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;
  var isLoading = false.obs;
  var selectedFilter = 'all'.obs;
  StreamSubscription<QuerySnapshot>? _subscription;
  bool _checkedFallback = false;

  @override
  void onInit() {
    super.onInit();
    listenToNotifications();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void listenToNotifications() {
    _subscribeToCollection(_activeCol);
  }

  void _subscribeToCollection(String collectionName) {
    _subscription?.cancel();
    isLoading.value = true;

    _subscription = _firestore
        .collection(collectionName)
        .orderBy('createdAt', descending: true) 
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final list = snapshot.docs
                  .map((doc) => NotificationModel.fromFirestore(doc))
                  .toList();

              if (!_checkedFallback &&
                  list.isEmpty &&
                  collectionName == _primaryCol) {
                _checkedFallback = true;
                _activeCol = _fallbackCol;
                _subscribeToCollection(_activeCol);
                return;
              }

              notifications.value = list;
              unreadCount.value = list.where((n) => !n.isRead).length;
            } catch (error) {
              print('❌ Notification parse error: $error');
            } finally {
              isLoading.value = false;
            }
          },
          onError: (error) {
            print('❌ Stream error: $error');
            if (!_checkedFallback && collectionName == _primaryCol) {
              _checkedFallback = true;
              _activeCol = _fallbackCol;
              _subscribeToCollection(_activeCol);
              return;
            }
            isLoading.value = false;
          },
        );
  }

  List<NotificationModel> get filteredNotifications {
    final list = notifications.toList(); 
    if (selectedFilter.value == 'all') return list;
    return list.where((n) => n.type == selectedFilter.value).toList();
  }

  Future<void> markAsRead(String id) async {
    await _firestore.collection(_activeCol).doc(id).update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final batch = _firestore.batch();
    final docs = await _firestore
        .collection(_activeCol)
        .where('isRead', isEqualTo: false)
        .get();
    for (var doc in docs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
    unreadCount.value = 0;
  }

  Future<void> deleteNotification(String id) async {
    await _firestore.collection(_activeCol).doc(id).delete();
  }

  Future<void> deleteAllNotifications() async {
    final docs = await _firestore.collection(_activeCol).get();
    final batch = _firestore.batch();
    for (var doc in docs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    notifications.clear();
    unreadCount.value = 0;
  }
}