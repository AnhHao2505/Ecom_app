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

  late StreamSubscription<QuerySnapshot> _convSubscription;
  late StreamSubscription<QuerySnapshot> _msgSubscription;

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
    _convSubscription.cancel();
    _msgSubscription.cancel();
    super.onClose();
  }

  void listenToConversations() {

    _convSubscription = _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          conversations.value = snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();

        });
  }

  void listenToMessages(String conversationId) {
    selectedConversationId.value = conversationId;

    _msgSubscription = _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
          messages.value = snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();

          _markAsRead(conversationId);
        });
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

      if (unread.docs.isNotEmpty) {
      }
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

      final docRef = await _firestore.collection('conversations').add({
        'participants': [currentUserId, shopId],
        'lastMessage': 'Bắt đầu trò chuyện',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      return '';
    }
  }
}
