import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/models/order_receipt_model.dart';
import 'package:e_mart/views/home_screen/base_home.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:get/get.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderReceipt receipt;

  const OrderConfirmationScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: whiteColor,
          elevation: 0,
          title: 'Order confirmed'.text
              .color(darkFontGrey)
              .fontFamily(bold)
              .make(),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 72),
                  14.heightBox,
                  'Thank you for your order'.text
                      .color(darkFontGrey)
                      .fontFamily(bold)
                      .size(20)
                      .align(TextAlign.center)
                      .make(),
                  8.heightBox,
                  'Order ${receipt.orderNumber}'.text
                      .color(fontGrey)
                      .size(14)
                      .align(TextAlign.center)
                      .make(),
                  20.heightBox,
                  _receiptCard(),
                  12.heightBox,
                  _deliveryCard(),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: whiteColor,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ourButton(
                    title: 'Continue shopping',
                    onPress: () => Get.offAll(() => const Home()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, color: redColor),
              8.widthBox,
              'Billing receipt'.text
                  .color(darkFontGrey)
                  .fontFamily(bold)
                  .size(16)
                  .make(),
              const Spacer(),
              (receipt.isPaid ? 'Paid' : 'Due on delivery').text
                  .color(receipt.isPaid ? Colors.green : Colors.orange)
                  .fontFamily(bold)
                  .size(12)
                  .make(),
            ],
          ),
          16.heightBox,
          ...receipt.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: '${item.name} x${item.quantity}'.text
                        .color(darkFontGrey)
                        .maxLines(1)
                        .overflow(TextOverflow.ellipsis)
                        .make(),
                  ),
                  _formatUsd(_displayAmount(item.lineTotal)).text
                      .color(darkFontGrey)
                      .fontFamily(semibold)
                      .make(),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          _priceRow('Subtotal', _displayAmount(receipt.subtotal)),
          8.heightBox,
          _priceRow('Tax', _displayAmount(receipt.tax)),
          8.heightBox,
          _priceRow('Shipping', _displayAmount(receipt.shipping)),
          12.heightBox,
          _priceRow('Total', _displayAmount(receipt.total), emphasis: true),
          16.heightBox,
          const Divider(height: 1),
          14.heightBox,
          _detailRow('Payment', receipt.paymentMethod),
          8.heightBox,
          _detailRow('Bill to', receipt.billingAddress),
        ],
      ),
    );
  }

  Widget _deliveryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_shipping_outlined, color: redColor),
          12.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                'Deliver to'.text.color(darkFontGrey).fontFamily(bold).make(),
                6.heightBox,
                receipt.recipientName.text
                    .color(darkFontGrey)
                    .fontFamily(semibold)
                    .make(),
                3.heightBox,
                receipt.deliveryAddress.text.color(fontGrey).size(13).make(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool emphasis = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label.text
            .color(emphasis ? darkFontGrey : fontGrey)
            .fontFamily(emphasis ? bold : semibold)
            .size(emphasis ? 16 : 14)
            .make(),
        _formatUsd(amount).text
            .color(emphasis ? redColor : darkFontGrey)
            .fontFamily(emphasis ? bold : semibold)
            .size(emphasis ? 18 : 14)
            .make(),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: label.text
              .color(fontGrey)
              .fontFamily(semibold)
              .size(13)
              .make(),
        ),
        Expanded(child: value.text.color(darkFontGrey).size(13).make()),
      ],
    );
  }

  String _formatUsd(double amount) => '\$${amount.toStringAsFixed(2)}';

  double _displayAmount(double amount) {
    if (receipt.paymentMethod.toUpperCase() == 'PAYOS' && amount >= 1000) {
      return amount / 26000;
    }
    return amount;
  }
}
