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

  // Lắng nghe danh sách cuộc trò chuyện
  void listenToConversations() {
    print('💬 Lắng nghe conversations...');

    _convSubscription = _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          conversations.value = snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();

          print('📦 Conversations: ${conversations.length}');
        });
  }

  // Lắng nghe tin nhắn trong conversation
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

          print('💬 Messages: ${messages.length}');

          // Đánh dấu đã đọc
          _markAsRead(conversationId);
        });
  }

  // Gửi tin nhắn
  Future<void> sendMessage({
    required String conversationId,
    required String receiverId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;

    try {
      isLoading.value = true;

      // 1. Thêm tin nhắn
      await _firestore.collection('messages').add({
        'conversationId': conversationId,
        'senderId': currentUserId,
        'receiverId': receiverId,
        'content': content.trim(),
        'type': 'text',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Cập nhật conversation
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Đã gửi tin nhắn');
      isLoading.value = false;
    } catch (e) {
      print('❌ Lỗi gửi tin nhắn: $e');
      isLoading.value = false;
    }
  }

  // Đánh dấu đã đọc
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
        print('✅ Đã đánh dấu đọc ${unread.docs.length} tin nhắn');
      }
    } catch (e) {
      print('❌ Lỗi đánh dấu đọc: $e');
    }
  }

  // Tạo conversation mới
  Future<String> createConversation(String shopId) async {
    try {
      // Kiểm tra đã có conversation chưa
      final existing = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: currentUserId)
          .get();

      // Tìm conversation với shop này
      for (var doc in existing.docs) {
        final participants = List<String>.from(doc['participants'] ?? []);
        if (participants.contains(shopId)) {
          return doc.id; // Đã có, trả về id
        }
      }

      // Chưa có, tạo mới
      final docRef = await _firestore.collection('conversations').add({
        'participants': [currentUserId, shopId],
        'lastMessage': 'Bắt đầu trò chuyện',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Tạo conversation mới: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Lỗi tạo conversation: $e');
      return '';
    }
  }
}
