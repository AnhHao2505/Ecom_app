import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/widget_common/product_card.dart';
import 'package:e_mart/widget_common/flash_sale_timer.dart';

class FlashSaleSection extends StatelessWidget {
  final List<Product> products;

  const FlashSaleSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        gradient: LinearGradient(
          colors: [
            redColor.withOpacity(0.08),
            Theme.of(context).cardColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.4],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: redColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: redColor, size: 28),
              8.widthBox,
              Text(
                'Flash Sale',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: bold,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              const FlashSaleTimer(initialDuration: Duration(hours: 12, minutes: 30, seconds: 0)),
            ],
          ),
          16.heightBox,
          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, _) => 12.widthBox,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 170,
                  child: ProductCard(
                    product: products[index],
                    imageHeight: 145,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
