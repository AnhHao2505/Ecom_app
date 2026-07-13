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

Future<String> createConversation(String otherUserId, {bool isSeller = false}) async {
  try {
    if (currentUserId.isEmpty) {
      return '';
    }

    if (otherUserId.isEmpty) {
      return '';
    }

    if (currentUserId == otherUserId) {
      return '';
    }

    // Tìm conversation đã tồn tại
    final existing = await _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in existing.docs) {
      final participants = List<String>.from(doc['participants'] ?? []);
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    String customerName = '';
    String sellerName = '';
    String customerId = '';
    String sellerId = '';
    
    try {
      // Lấy thông tin current user
      final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      String currentUserName = '';
      if (currentUserDoc.exists) {
        final data = currentUserDoc.data() as Map<String, dynamic>;
        currentUserName = data['name'] ?? '';
      } else {
        print('Current user NOT FOUND in users collection');
      }

      // Lấy thông tin other user
      final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
      String otherUserName = '';
      if (otherUserDoc.exists) {
        final data = otherUserDoc.data() as Map<String, dynamic>;
        otherUserName = data['name'] ?? '';
      } else {
        print('Other user NOT FOUND in users collection');
      }

      // Lấy thông tin shop của current user
      final currentStoreDoc = await _firestore.collection('stores').doc(currentUserId).get();
      String currentShopName = '';
      if (currentStoreDoc.exists) {
        final data = currentStoreDoc.data() as Map<String, dynamic>;
        currentShopName = data['name'] ?? '';
      } else {
        print(' Current store NOT FOUND in stores collection');
      }

      // Lấy thông tin shop của other user
      final otherStoreDoc = await _firestore.collection('stores').doc(otherUserId).get();
      String otherShopName = '';
      if (otherStoreDoc.exists) {
        final data = otherStoreDoc.data() as Map<String, dynamic>;
        otherShopName = data['name'] ?? '';
      } else {
        print('Other store NOT FOUND in stores collection');
      }

      if (isSeller) {
        // Current user là Seller, other user là Customer
        sellerId = currentUserId;
        sellerName = currentShopName.isNotEmpty ? currentShopName : currentUserName;
        customerId = otherUserId;
        customerName = otherUserName.isNotEmpty ? otherUserName : 'Khách hàng';
      } else {
        customerId = currentUserId;
        customerName = currentUserName.isNotEmpty ? currentUserName : 'Khách hàng';
        sellerId = otherUserId;
        sellerName = otherShopName.isNotEmpty ? otherShopName : otherUserName;
      }
      
    } catch (e) {
      print(' Lỗi lấy thông tin: $e');
    }

    final docRef = await _firestore.collection('conversations').add({
      'participants': [currentUserId, otherUserId],
      'customerId': customerId,
      'customerName': customerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
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
