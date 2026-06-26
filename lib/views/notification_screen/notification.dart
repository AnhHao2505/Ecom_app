import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/notification_controller.dart';
import 'package:e_mart/views/notification_screen/widgets/notification_item.dart';
import 'package:get/get.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: 'Thông báo'.text.fontFamily(bold).white.size(20).make(),
        centerTitle: true,
        actions: [
          Obx(
            () => controller.unreadCount.value > 0
                ? IconButton(
                    icon: const Icon(Icons.done_all),
                    onPressed: () => controller.markAllAsRead(),
                  )
                : const SizedBox.shrink(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete_all') {
                _showDeleteAllDialog(context, controller);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_all',
                child: Text('Xóa tất cả'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final displayList = controller.filteredNotifications;

              if (displayList.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final notification = displayList[index];
                  return NotificationItem(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        controller.markAsRead(notification.id);
                      }
                    },
                    onDelete: () {
                      controller.deleteNotification(notification.id);
                      VxToast.show(context, msg: 'Đã xóa thông báo');
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(NotificationController controller) {
    final tabs = ['Tất cả', 'Khuyến mãi', 'Đơn hàng', 'Hệ thống'];
    final types = ['all', 'promotion', 'order', 'system'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.selectedFilter.value == types[index];
            return GestureDetector(
              onTap: () => controller.selectedFilter.value = types[index],
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primaryColor : lightGrey,
                  ),
                ),
                child: tabs[index].text
                    .color(isSelected ? whiteColor : darkFontGrey)
                    .fontFamily(semibold)
                    .size(14)
                    .make(),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: lightGrey),
          const SizedBox(height: 16),
          'Không có thông báo'.text.color(darkFontGrey).size(16).make(),
          const SizedBox(height: 8),
          'Bạn chưa có thông báo nào'.text.color(lightGrey).size(14).make(),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(
    BuildContext context,
    NotificationController controller,
  ) {
    Get.defaultDialog(
      title: 'Xóa tất cả',
      middleText: 'Bạn có chắc muốn xóa tất cả thông báo?',
      textConfirm: 'Xóa',
      textCancel: 'Hủy',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteAllNotifications();
        Get.back();
        VxToast.show(context, msg: 'Đã xóa tất cả thông báo');
      },
    );
  }
}
