import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/models/store_model.dart';
import 'package:e_mart/views/item_detail_screen/item_detail.dart';
import 'package:e_mart/widget_common/product_image.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StoreDetail extends StatelessWidget {
  final Store store;

  const StoreDetail({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: store.name.text.color(darkFontGrey).fontFamily(bold).make(),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
        ],
      ),
      body: Get.isRegistered<HomeController>()
          ? Obx(
              () => _StoreDetailBody(
                store: store,
                storeProducts: _productsForStore(),
              ),
            )
          : _StoreDetailBody(
              store: store,
              storeProducts: productsByStore(store.userId),
            ),
    );
  }

  List<Product> _productsForStore() {
    final fallbackProducts = productsByStore(store.userId);
    final liveProducts = Get.find<HomeController>().products.where((product) {
      final sellerUserId = product.userId;
      if (sellerUserId != null && sellerUserId.isNotEmpty) {
        return sellerUserId == store.userId;
      }
      return product.storeId == store.userId;
    }).toList();

    return liveProducts.isEmpty ? fallbackProducts : liveProducts;
  }
}

class _StoreDetailBody extends StatelessWidget {
  final Store store;
  final List<Product> storeProducts;

  const _StoreDetailBody({required this.store, required this.storeProducts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StoreHeader(store: store, productTotal: storeProducts.length),
          12.heightBox,
          _StoreInfo(store: store),
          12.heightBox,
          _StoreMap(store: store),
          16.heightBox,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: "Products from this store".text
                .fontFamily(bold)
                .size(16)
                .color(darkFontGrey)
                .make(),
          ),
          10.heightBox,
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: storeProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 282,
            ),
            itemBuilder: (context, index) {
              return _StoreProductCard(product: storeProducts[index]);
            },
          ),
          16.heightBox,
        ],
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  final Store store;
  final int productTotal;

  const _StoreHeader({required this.store, required this.productTotal});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ProductImage(
          source: store.coverImage,
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.28)),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: -46,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ProductImage(
                    source: store.logo,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ).box.white.rounded
                  .padding(const EdgeInsets.all(12))
                  .outerShadowSm
                  .make(),
              12.widthBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    store.name.text.white
                        .fontFamily(bold)
                        .size(20)
                        .maxLines(1)
                        .overflow(TextOverflow.ellipsis)
                        .make(),
                    6.heightBox,
                    Row(
                      children: [
                        const Icon(Icons.star, color: golden, size: 18),
                        4.widthBox,
                        "${store.rating}".text.white
                            .fontFamily(semibold)
                            .make(),
                        12.widthBox,
                        "$productTotal products".text.white.size(12).make(),
                      ],
                    ),
                  ],
                ).pOnly(bottom: 8),
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: "${store.followerCount} followers".text.white
              .size(12)
              .fontFamily(semibold)
              .make()
              .box
              .color(Colors.black.withValues(alpha: 0.45))
              .roundedSM
              .padding(const EdgeInsets.symmetric(horizontal: 10, vertical: 6))
              .make(),
        ),
      ],
    ).box.margin(const EdgeInsets.only(bottom: 50)).make();
  }
}

class _StoreInfo extends StatelessWidget {
  final Store store;

  const _StoreInfo({required this.store});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          store.description.text.color(darkFontGrey).make(),
          12.heightBox,
          _InfoRow(icon: Icons.person_outline, label: store.ownerName),
          _InfoRow(icon: Icons.phone_outlined, label: store.phone),
          _InfoRow(icon: Icons.email_outlined, label: store.email),
          _InfoRow(icon: Icons.schedule, label: store.openingHours),
          _InfoRow(icon: Icons.location_on_outlined, label: store.address),
        ],
      ).box.white.roundedSM.padding(const EdgeInsets.all(14)).make(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: redColor),
          10.widthBox,
          Expanded(child: label.text.color(darkFontGrey).size(13).make()),
        ],
      ),
    );
  }
}

class _StoreMap extends StatefulWidget {
  final Store store;

  const _StoreMap({required this.store});

  @override
  State<_StoreMap> createState() => _StoreMapState();
}

class _StoreMapState extends State<_StoreMap> {
  static const String _googleMapsEmbedApiKey =
      'AIzaSyAPLdlKoYEoVZBE8eFQQJSkv_d5OZjfAiI';

  WebViewController? _webViewController;

  WebViewController get _controller {
    return _webViewController ??= WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(whiteColor)
      ..loadHtmlString(_mapHtml);
  }

  @override
  void didUpdateWidget(covariant _StoreMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store.address != widget.store.address ||
        oldWidget.store.latitude != widget.store.latitude ||
        oldWidget.store.longitude != widget.store.longitude) {
      _webViewController?.loadHtmlString(_mapHtml);
    }
  }

  String get _mapQuery {
    final address = widget.store.address.trim();
    if (address.isNotEmpty) return address;

    return '${widget.store.latitude.toStringAsFixed(6)},${widget.store.longitude.toStringAsFixed(6)}';
  }

  Uri get _mapEmbedUri {
    return Uri.https('www.google.com', '/maps/embed/v1/place', {
      'key': _googleMapsEmbedApiKey,
      'q': _mapQuery,
      'zoom': '16',
      'maptype': 'roadmap',
    });
  }

  String get _mapHtml {
    final mapUrl = _mapEmbedUri.toString();

    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="initial-scale=1.0, width=device-width" />
    <style>
      html, body, iframe {
        width: 100%;
        height: 100%;
        margin: 0;
        padding: 0;
        border: 0;
        overflow: hidden;
      }
    </style>
  </head>
  <body>
    <iframe
      src="$mapUrl"
      allowfullscreen
      loading="lazy"
      referrerpolicy="no-referrer-when-downgrade">
    </iframe>
  </body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              "Store location".text
                  .fontFamily(semibold)
                  .color(darkFontGrey)
                  .make(),
              const Spacer(),
              "Google Maps".text
                  .size(12)
                  .fontFamily(semibold)
                  .color(redColor)
                  .make(),
            ],
          ),
          10.heightBox,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: WebViewWidget(controller: _controller),
            ),
          ),
          8.heightBox,
          widget.store.address.text.color(textfieldGrey).size(12).make(),
        ],
      ).box.white.roundedSM.padding(const EdgeInsets.all(14)).make(),
    );
  }
}

class _StoreProductCard extends StatelessWidget {
  final Product product;

  const _StoreProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ItemDetail(product: product)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(
            source: product.images.isNotEmpty ? product.images[0] : imgP1,
            width: double.infinity,
            height: 145,
            fit: BoxFit.cover,
          ),
          10.heightBox,
          product.name.text
              .fontFamily(semibold)
              .color(darkFontGrey)
              .size(12)
              .maxLines(2)
              .overflow(TextOverflow.ellipsis)
              .make(),
          6.heightBox,
          Row(
            children: [
              const Icon(Icons.star, color: golden, size: 14),
              4.widthBox,
              "${product.rating}".text.size(11).color(textfieldGrey).make(),
            ],
          ),
          const Spacer(),
          "\$${product.price.toStringAsFixed(2)}".text
              .color(redColor)
              .fontFamily(bold)
              .size(14)
              .make(),
        ],
      ).box.white.roundedSM.padding(const EdgeInsets.all(10)).make(),
    );
  }
}
