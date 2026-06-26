import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var conversations = <Map<String, dynamic>>[].obs;
  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedConversationId = ''.obs;

  StreamSubscription<QuerySnapshot>? _convSubscription;
  StreamSubscription<QuerySnapshot>? _msgSubscription;

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    if (currentUserId.isNotEmpty) {
      listenToConversations();
    }
  }

  @override
  void onClose() {
    _disposeSubscriptions();
    super.onClose();
  }

  void _disposeSubscriptions() {
    _convSubscription?.cancel();
    _convSubscription = null;
    _msgSubscription?.cancel();
    _msgSubscription = null;
  }

  void listenToConversations() {
    _convSubscription?.cancel();
    
    _convSubscription = _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            conversations.value = snapshot.docs.map((doc) {
              return {'id': doc.id, ...doc.data()};
            }).toList();
          },
          onError: (error) {
            print('Lỗi lắng nghe conversations: $error');
          },
        );
  }

  void listenToMessages(String conversationId) {
    if (selectedConversationId.value == conversationId && _msgSubscription != null) {
      return;
    }

    selectedConversationId.value = conversationId;

    _msgSubscription?.cancel();
    _msgSubscription = null;

    messages.clear();

    _msgSubscription = _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen(
          (snapshot) {
            messages.value = snapshot.docs.map((doc) {
              return {'id': doc.id, ...doc.data()};
            }).toList();

            _markAsRead(conversationId);
          },
          onError: (error) {
            print('Lỗi lắng nghe messages: $error');
          },
        );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String receiverId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;

    try {
      isLoading.value = true;

      await _firestore.collection('messages').add({
        'conversationId': conversationId,
        'senderId': currentUserId,
        'receiverId': receiverId,
        'content': content.trim(),
        'type': 'text',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> _markAsRead(String conversationId) async {
    try {
      final unread = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unread.docs) {
        await doc.reference.update({'isRead': true});
      }

      if (unread.docs.isNotEmpty) {}
    } catch (e) {
      print(' Lỗi đánh dấu đọc: $e');
    }
  }

Future<String> createConversation(String shopId) async {
  try {
    final existing = await _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in existing.docs) {
      final participants = List<String>.from(doc['participants'] ?? []);
      if (participants.contains(shopId)) {
        return doc.id;
      }
    }

    String shopName = 'Shop';
    try {
      final storeDoc = await _firestore.collection('stores').doc(shopId).get();
      if (storeDoc.exists) {
        shopName = storeDoc.data()?['name'] ?? 'Shop';
      }
    } catch (e) {
      print('Lỗi lấy tên shop: $e');
    }

    final docRef = await _firestore.collection('conversations').add({
      'participants': [currentUserId, shopId],
      'lastMessage': 'Bắt đầu trò chuyện với $shopName',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'shopName': shopName, 
    });

    return docRef.id;
  } catch (e) {
    print('Lỗi tạo conversation: $e');
    return '';
  }
}
}
