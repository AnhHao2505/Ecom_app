import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/message_controller.dart';
import 'package:get/get.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String receiverId;
  final String shopName;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.receiverId,
    this.shopName = 'Shop',
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late MessageController _msgController;
  
  // ✅ Thêm FocusNode
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<MessageController>()) {
      Get.put(MessageController());
    }

    _msgController = Get.find<MessageController>();
    _msgController.listenToMessages(widget.conversationId);
    
    // ✅ Request focus sau khi build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose(); // ✅ Dispose FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: widget.shopName.text.fontFamily(bold).white.size(18).make(),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _focusNode.unfocus(); 
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _focusNode.unfocus();
              },
              child: Obx(() {
                if (_msgController.messages.isEmpty) {
                  return const Center(
                    child: Text('Chưa có tin nhắn'),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _msgController.messages.length,
                  itemBuilder: (context, index) {
                    final msg = _msgController.messages[index];
                    final isMe = msg['senderId'] == _msgController.currentUserId;

                    return _buildMessageBubble(msg, isMe);
                  },
                );
              }),
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final String content = msg['content'] ?? '';
    Timestamp? createdAt = msg['createdAt'] as Timestamp?;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            content.text
                .color(isMe ? Colors.white : darkFontGrey)
                .size(14)
                .make(),
            const SizedBox(height: 4),
            _formatTime(createdAt ?? Timestamp.now()).text
                .color(isMe ? Colors.white70 : lightGrey)
                .size(10)
                .make(),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode, // ✅ Gán FocusNode
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: lightGrey,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => GestureDetector(
              onTap: _msgController.isLoading.value ? null : _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: redColor,
                  shape: BoxShape.circle,
                ),
                child: _msgController.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    _msgController.sendMessage(
      conversationId: widget.conversationId,
      receiverId: widget.receiverId,
      content: _controller.text,
    );

    _controller.clear();
    
    _focusNode.requestFocus();
  }

  String _formatTime(Timestamp timestamp) {
    final time = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes < 1) return 'Vừa xong';
    return '${diff.inMinutes} phút trước';
  }
}