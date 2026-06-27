import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/notification_controller.dart';
import 'package:e_mart/models/notification_model.dart';
import 'package:e_mart/views/notification_screen/widgets/notification_item.dart';
import 'package:get/get.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.4),
        title: 'Thông báo'.text.fontFamily(bold).white.size(20).make(),
        centerTitle: true,
        iconTheme: const IconThemeData(color: whiteColor),
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
          _buildFilterTabs(context, controller),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
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
                      _handleNotificationTap(context, notification);
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, NotificationController controller) {
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
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? darkDivider : lightDivider),
                  ),
                ),
                child: tabs[index].text
                    .color(isSelected ? whiteColor : Theme.of(context).textTheme.bodyMedium?.color ?? darkFontGrey)
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

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    switch (notification.type) {
      case 'order':
        // Đi đến chi tiết đơn hàng
        break;
      case 'promotion':
        // Đi đến trang khuyến mãi
        break;
      case 'payment':
        // Đi đến trang thanh toán
        break;
      default:
        VxToast.show(context, msg: '${notification.title}');
        break;
    }
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
