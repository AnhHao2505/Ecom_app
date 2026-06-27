import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/models/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: redColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Theme.of(context).cardColor
                : Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? (Theme.of(context).brightness == Brightness.dark ? darkDivider : lightDivider)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: notification.title.text
                              .fontFamily(semibold)
                              .size(16)
                              .make(),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    notification.body.text
                        .fontFamily(regular)
                        .size(14)
                        .color(darkFontGrey)
                        .maxLines(2)
                        .overflow(TextOverflow.ellipsis)
                        .make(),
                    const SizedBox(height: 6),
                    _formatTime(notification.createdAt).text
                        .fontFamily(regular)
                        .size(12)
                        .color(lightGrey)
                        .make(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _getIconColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_getIcon(), color: _getIconColor(context), size: 28),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case 'order': return Icons.shopping_bag_outlined;
      case 'promotion': return Icons.local_offer_outlined;
      case 'payment': return Icons.payment_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (notification.type) {
      case 'order': return Colors.blue;
      case 'promotion': return Colors.orange;
      case 'payment': return Colors.green;
      default: return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 7) return '${time.day}/${time.month}/${time.year}';
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
}