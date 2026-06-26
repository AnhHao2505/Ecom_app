import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/models/billing_order_model.dart';
import 'package:e_mart/services/order_billing_service.dart';
import 'package:e_mart/widget_common/product_image.dart';
import 'package:get/get.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  static const int _ordersPerPage = 5;
  String _selectedFilter = 'all';
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    final service = OrderBillingService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
        elevation: 0,
        centerTitle: true,
        title: 'My Orders'.text.white.fontFamily(bold).size(20).make(),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [darkBg, darkBgGradientEnd]
                : [lightBg, lightBgGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<List<BillingOrder>>(
          stream: service.watchCurrentUserOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            if (snapshot.hasError) {
              return _StateMessage(
                icon: Icons.receipt_long_outlined,
                title: 'Orders unavailable',
                message:
                    'Please check your Firestore rules and try again later.',
              );
            }

            final orders = snapshot.data ?? const <BillingOrder>[];
            final filters = _buildFilters(orders);
            final filteredOrders = orders
                .where((order) => _matchesFilter(order, _selectedFilter))
                .toList();
            final totalPages = filteredOrders.isEmpty
                ? 1
                : ((filteredOrders.length - 1) ~/ _ordersPerPage) + 1;
            final pageIndex = _selectedPage >= totalPages
                ? totalPages - 1
                : _selectedPage;
            final pageOrders = filteredOrders
                .skip(pageIndex * _ordersPerPage)
                .take(_ordersPerPage)
                .toList();

            if (orders.isEmpty) {
              return const _StateMessage(
                icon: Icons.shopping_bag_outlined,
                title: 'No purchases yet',
                message: 'Your completed and pending orders will appear here.',
              );
            }

            return Column(
              children: [
                _StatusFilterBar(
                  filters: filters,
                  selectedKey: _selectedFilter,
                  onSelected: (key) {
                    setState(() {
                      _selectedFilter = key;
                      _selectedPage = 0;
                    });
                  },
                ),
                Expanded(
                  child: pageOrders.isEmpty
                      ? const _StateMessage(
                          icon: Icons.manage_search_outlined,
                          title: 'No orders in this status',
                          message: 'Choose another status to view purchases.',
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: pageOrders.length,
                          separatorBuilder: (_, _) => 12.heightBox,
                          itemBuilder: (context, index) {
                            return _OrderCard(order: pageOrders[index]);
                          },
                        ),
                ),
                _PaginationControls(
                  currentPage: pageIndex,
                  totalPages: totalPages,
                  totalItems: filteredOrders.length,
                  pageSize: _ordersPerPage,
                  onPrevious: pageIndex == 0
                      ? null
                      : () => setState(() => _selectedPage = pageIndex - 1),
                  onNext: pageIndex >= totalPages - 1
                      ? null
                      : () => setState(() => _selectedPage = pageIndex + 1),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_StatusFilter> _buildFilters(List<BillingOrder> orders) {
    int count(String key) {
      return orders.where((order) => _matchesFilter(order, key)).length;
    }

    return [
      _StatusFilter(key: 'all', label: 'All', count: orders.length),
      _StatusFilter(key: 'paid', label: 'Paid', count: count('paid')),
      _StatusFilter(key: 'pending', label: 'Pending', count: count('pending')),
      _StatusFilter(key: 'cod', label: 'COD', count: count('cod')),
      _StatusFilter(
        key: 'cancelled',
        label: 'Cancelled',
        count: count('cancelled'),
      ),
      _StatusFilter(key: 'failed', label: 'Failed', count: count('failed')),
    ];
  }

  bool _matchesFilter(BillingOrder order, String key) {
    final status = order.status.toUpperCase();
    switch (key) {
      case 'paid':
        return status == 'PAID';
      case 'pending':
        return status == 'PENDING';
      case 'cod':
        return status == 'COD_PENDING';
      case 'cancelled':
        return status == 'CANCELLED';
      case 'failed':
        return status == 'FAILED' || status == 'PAYOS_FAILED';
      case 'all':
      default:
        return true;
    }
  }
}

class _StatusFilter {
  final String key;
  final String label;
  final int count;

  const _StatusFilter({
    required this.key,
    required this.label,
    required this.count,
  });
}

class _StatusFilterBar extends StatelessWidget {
  final List<_StatusFilter> filters;
  final String selectedKey;
  final ValueChanged<String> onSelected;

  const _StatusFilterBar({
    required this.filters,
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        itemCount: filters.length,
        separatorBuilder: (_, _) => 8.widthBox,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = selectedKey == filter.key;
          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            selectedColor: primaryColor,
            backgroundColor: Theme.of(context).cardColor,
            side: BorderSide(
              color: selected
                  ? primaryColor
                  : Theme.of(context).dividerColor.withValues(alpha: 0.18),
            ),
            label: Text(
              '${filter.label} (${filter.count})',
              style: TextStyle(
                color: selected
                    ? whiteColor
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: selected ? bold : semibold,
              ),
            ),
            onSelected: (_) => onSelected(filter.key),
          );
        },
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final startItem = totalItems == 0 ? 0 : currentPage * pageSize + 1;
    final endItem = totalItems == 0
        ? 0
        : (currentPage * pageSize + pageSize).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: 'Showing $startItem-$endItem of $totalItems'.text
                  .color(Theme.of(context).textTheme.bodyMedium?.color)
                  .fontFamily(semibold)
                  .size(13)
                  .make(),
            ),
            IconButton(
              tooltip: 'Previous page',
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
              color: primaryColor,
            ),
            '${currentPage + 1}/$totalPages'.text
                .color(Theme.of(context).textTheme.bodyLarge?.color)
                .fontFamily(bold)
                .make(),
            IconButton(
              tooltip: 'Next page',
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderBillingDetailScreen extends StatelessWidget {
  final BillingOrder order;

  const OrderBillingDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: 'Billing Details'.text
            .color(Theme.of(context).textTheme.bodyLarge?.color)
            .fontFamily(bold)
            .make(),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [darkBg, darkBgGradientEnd]
                : [lightBg, lightBgGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        color: primaryColor,
                      ),
                      10.widthBox,
                      Expanded(
                        child: order.orderCode.text
                            .color(Theme.of(context).textTheme.bodyLarge?.color)
                            .fontFamily(bold)
                            .size(18)
                            .make(),
                      ),
                      _StatusPill(order: order),
                    ],
                  ),
                  14.heightBox,
                  _InfoRow(label: 'Date', value: _formatDate(order.createdAt)),
                  8.heightBox,
                  _InfoRow(label: 'Payment', value: order.paymentMethod),
                  8.heightBox,
                  _InfoRow(
                    label: 'Payment status',
                    value: order.isPaid ? 'Paid' : order.statusLabel,
                  ),
                ],
              ),
            ),
            12.heightBox,
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  'Purchased items'.text
                      .color(Theme.of(context).textTheme.bodyLarge?.color)
                      .fontFamily(bold)
                      .size(16)
                      .make(),
                  14.heightBox,
                  if (order.items.isEmpty)
                    'No item details were saved for this order.'.text
                        .color(fontGrey)
                        .make()
                  else
                    ...order.items.map((item) => _PurchasedItem(item: item)),
                ],
              ),
            ),
            12.heightBox,
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  'Billing information'.text
                      .color(Theme.of(context).textTheme.bodyLarge?.color)
                      .fontFamily(bold)
                      .size(16)
                      .make(),
                  14.heightBox,
                  _InfoRow(label: 'Bill to', value: order.billingAddress),
                  8.heightBox,
                  _InfoRow(label: 'Buyer', value: order.buyerName),
                  8.heightBox,
                  _InfoRow(label: 'Email', value: order.buyerEmail),
                  8.heightBox,
                  _InfoRow(label: 'Phone', value: order.buyerPhone),
                ],
              ),
            ),
            12.heightBox,
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  'Delivery'.text
                      .color(Theme.of(context).textTheme.bodyLarge?.color)
                      .fontFamily(bold)
                      .size(16)
                      .make(),
                  14.heightBox,
                  _InfoRow(label: 'Address', value: order.deliveryAddress),
                  8.heightBox,
                  _InfoRow(
                    label: 'Type',
                    value: order.deliveryType.isEmpty
                        ? 'Not provided'
                        : order.deliveryType,
                  ),
                ],
              ),
            ),
            12.heightBox,
            _SectionCard(
              child: Column(
                children: [
                  _PriceRow(label: 'Subtotal', amount: order.subtotal),
                  8.heightBox,
                  _PriceRow(label: 'Tax', amount: order.tax),
                  8.heightBox,
                  _PriceRow(label: 'Delivery', amount: order.shipping),
                  12.heightBox,
                  const Divider(height: 1),
                  12.heightBox,
                  _PriceRow(
                    label: 'Total',
                    amount: order.total,
                    emphasis: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final BillingOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => OrderBillingDetailScreen(order: order)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: order.orderCode.text
                        .color(Theme.of(context).textTheme.bodyLarge?.color)
                        .fontFamily(bold)
                        .size(16)
                        .maxLines(1)
                        .overflow(TextOverflow.ellipsis)
                        .make(),
                  ),
                  _StatusPill(order: order),
                ],
              ),
              8.heightBox,
              _formatDate(order.createdAt).text
                  .color(Theme.of(context).textTheme.bodyMedium?.color)
                  .size(12)
                  .make(),
              14.heightBox,
              Row(
                children: [
                  Expanded(
                    child:
                        '${order.items.length} item${order.items.length == 1 ? '' : 's'}'
                            .text
                            .color(
                              Theme.of(context).textTheme.bodyMedium?.color,
                            )
                            .fontFamily(semibold)
                            .make(),
                  ),
                  '\$${order.total.toStringAsFixed(2)}'.text
                      .color(primaryColor)
                      .fontFamily(bold)
                      .size(18)
                      .make(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PurchasedItem extends StatelessWidget {
  final BillingOrderItem item;

  const _PurchasedItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ProductImage(source: item.image, width: 56, height: 56),
          ),
          12.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                item.name.text
                    .color(Theme.of(context).textTheme.bodyLarge?.color)
                    .fontFamily(semibold)
                    .maxLines(2)
                    .overflow(TextOverflow.ellipsis)
                    .make(),
                if (item.optionLabel.isNotEmpty) ...[
                  4.heightBox,
                  item.optionLabel.text
                      .color(Theme.of(context).textTheme.bodyMedium?.color)
                      .size(12)
                      .make(),
                ],
                4.heightBox,
                'Qty ${item.quantity}'.text
                    .color(Theme.of(context).textTheme.bodyMedium?.color)
                    .size(12)
                    .make(),
              ],
            ),
          ),
          8.widthBox,
          '\$${item.lineTotal.toStringAsFixed(2)}'.text
              .color(Theme.of(context).textTheme.bodyLarge?.color)
              .fontFamily(bold)
              .make(),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.14),
        ),
      ),
      child: child,
    );
  }
}

class _StatusPill extends StatelessWidget {
  final BillingOrder order;

  const _StatusPill({required this.order});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: order.statusLabel.text
          .color(color)
          .fontFamily(bold)
          .size(12)
          .make(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: label.text
              .color(Theme.of(context).textTheme.bodyMedium?.color)
              .fontFamily(semibold)
              .size(13)
              .make(),
        ),
        Expanded(
          child: (value.trim().isEmpty ? 'Not provided' : value).text
              .color(Theme.of(context).textTheme.bodyLarge?.color)
              .fontFamily(regular)
              .size(13)
              .make(),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool emphasis;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label.text
            .color(Theme.of(context).textTheme.bodyLarge?.color)
            .fontFamily(emphasis ? bold : semibold)
            .size(emphasis ? 16 : 14)
            .make(),
        '\$${amount.toStringAsFixed(2)}'.text
            .color(
              emphasis
                  ? primaryColor
                  : Theme.of(context).textTheme.bodyLarge?.color,
            )
            .fontFamily(emphasis ? bold : semibold)
            .size(emphasis ? 18 : 14)
            .make(),
      ],
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryColor, size: 72),
            18.heightBox,
            title.text
                .color(Theme.of(context).textTheme.bodyLarge?.color)
                .fontFamily(bold)
                .size(20)
                .align(TextAlign.center)
                .make(),
            8.heightBox,
            message.text
                .color(Theme.of(context).textTheme.bodyMedium?.color)
                .size(14)
                .align(TextAlign.center)
                .make(),
          ],
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status.toUpperCase()) {
    case 'PAID':
      return successColor;
    case 'CANCELLED':
      return fontGrey;
    case 'FAILED':
    case 'PAYOS_FAILED':
      return errorColor;
    case 'COD_PENDING':
      return warningColor;
    default:
      return primaryColor;
  }
}

String _formatDate(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)} '
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
}
