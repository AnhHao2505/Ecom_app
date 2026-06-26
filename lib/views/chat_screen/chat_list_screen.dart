import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/message_controller.dart';
import 'package:e_mart/views/chat_screen/chat_detail_screen.dart';
import 'package:get/get.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageController());

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: 'Tin nhắn'.text.fontFamily(bold).white.size(20).make(),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 80, color: lightGrey),
                const SizedBox(height: 16),
                'Chưa có tin nhắn'.text.color(darkFontGrey).size(16).make(),
                const SizedBox(height: 8),
                'Hãy bắt đầu trò chuyện với shop'.text
                    .color(lightGrey)
                    .size(14)
                    .make(),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.conversations.length,
          itemBuilder: (context, index) {
            final conv = controller.conversations[index];
            final participants = conv['participants'] as List;
            final otherId = participants.firstWhere(
              (p) => p != controller.currentUserId,
              orElse: () => '',
            );

            // ✅ Lấy lastMessage là String
            final String lastMessage = conv['lastMessage'] ?? '';
            final Timestamp? lastMessageTime =
                conv['lastMessageTime'] as Timestamp?;

            return InkWell(
              onTap: () {
                Get.to(
                  () => ChatDetailScreen(
                    conversationId: conv['id'],
                    receiverId: otherId,
                    shopName: 'Shop',
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(Icons.store, color: primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          'Shop'.text.fontFamily(semibold).size(16).make(),
                          const SizedBox(height: 4),
                          lastMessage.text
                              .size(14)
                              .color(darkFontGrey)
                              .maxLines(1)
                              .overflow(TextOverflow.ellipsis)
                              .make(),
                        ],
                      ),
                    ),
                    _formatTime(
                      lastMessageTime ?? Timestamp.now(),
                    ).text.size(12).color(darkFontGrey).make(),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final time = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) return '${diff.inDays} ngày';
    if (diff.inHours > 0) return '${diff.inHours} giờ';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút';
    return 'Vừa xong';
  }
}
