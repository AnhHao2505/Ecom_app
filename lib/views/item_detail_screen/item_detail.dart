import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/views/store_screen/store_detail.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:get/get.dart';

class ItemDetail extends StatefulWidget {
  final Product product;
  const ItemDetail({super.key, required this.product});

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  late int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final store = storeById(widget.product.storeId);

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: widget.product.name.text
            .color(darkFontGrey)
            .fontFamily(bold)
            .make(),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: Icon(Icons.favorite_outline)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // swiper section with product images
                    VxSwiper.builder(
                      autoPlay: true,
                      height: 350,
                      aspectRatio: 16 / 9,
                      itemCount: widget.product.images.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          widget.product.images[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    ),

                    10.heightBox,
                    // title and details section
                    widget.product.name.text
                        .size(16)
                        .color(darkFontGrey)
                        .fontFamily(bold)
                        .make(),

                    10.heightBox,
                    // rating
                    VxRating(
                      onRatingUpdate: (value) {},
                      normalColor: textfieldGrey,
                      selectionColor: golden,
                      count: 5,
                      size: 25,
                      stepInt: true,
                      value: widget.product.rating,
                    ),

                    5.heightBox,
                    "(${widget.product.reviewCount} reviews)".text
                        .size(12)
                        .color(textfieldGrey)
                        .make(),

                    // price
                    10.heightBox,
                    Row(
                      children: [
                        if (widget.product.originalPrice > widget.product.price)
                          "\$${widget.product.originalPrice.toStringAsFixed(2)}"
                              .text
                              .lineThrough
                              .size(14)
                              .color(textfieldGrey)
                              .make(),
                        10.widthBox,
                        "\$${widget.product.price.toStringAsFixed(2)}".text
                            .color(redColor)
                            .size(18)
                            .fontFamily(bold)
                            .make(),
                        10.widthBox,
                        if (widget.product.discountPercentage > 0)
                          "${widget.product.discountPercentage.toStringAsFixed(0)}% off"
                              .text
                              .fontFamily(bold)
                              .size(12)
                              .color(Colors.orange)
                              .make(),
                      ],
                    ),

                    10.heightBox,

                    GestureDetector(
                      onTap: () => Get.to(() => StoreDetail(store: store)),
                      child:
                          Row(
                                children: [
                                  Image.asset(
                                        store.logo,
                                        width: 42,
                                        height: 42,
                                        fit: BoxFit.contain,
                                      ).box.white.roundedSM
                                      .padding(const EdgeInsets.all(8))
                                      .make(),
                                  12.widthBox,
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        "Seller".text.white
                                            .fontFamily(semibold)
                                            .make(),
                                        5.heightBox,
                                        store.name.text
                                            .fontFamily(semibold)
                                            .color(darkFontGrey)
                                            .size(16)
                                            .maxLines(1)
                                            .overflow(TextOverflow.ellipsis)
                                            .make(),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: golden,
                                              size: 14,
                                            ),
                                            4.widthBox,
                                            "${store.rating}".text
                                                .size(11)
                                                .color(darkFontGrey)
                                                .make(),
                                            8.widthBox,
                                            store.address.text
                                                .size(11)
                                                .color(darkFontGrey)
                                                .maxLines(1)
                                                .overflow(TextOverflow.ellipsis)
                                                .make()
                                                .expand(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const CircleAvatar(
                                    backgroundColor: whiteColor,
                                    child: Icon(
                                      Icons.storefront,
                                      color: darkFontGrey,
                                    ),
                                  ),
                                ],
                              ).box
                              .height(78)
                              .padding(
                                const EdgeInsets.symmetric(horizontal: 16),
                              )
                              .color(textfieldGrey)
                              .make(),
                    ),

                    // color and size section
                    Column(
                      children: [
                        if (widget.product.colors.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: "Color: ".text
                                    .color(textfieldGrey)
                                    .make(),
                              ),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    widget.product.colors.length,
                                    (index) => VxBox()
                                        .size(40, 40)
                                        .roundedFull
                                        .color(
                                          _getColorFromString(
                                            widget.product.colors[index],
                                          ),
                                        )
                                        .make()
                                        .tooltip(widget.product.colors[index]),
                                  ),
                                ),
                              ),
                            ],
                          ).box.padding(const EdgeInsets.all(8)).make(),
                        if (widget.product.sizes.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: "Size: ".text
                                    .color(textfieldGrey)
                                    .make(),
                              ),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    widget.product.sizes.length,
                                    (index) => widget.product.sizes[index].text
                                        .size(12)
                                        .color(darkFontGrey)
                                        .make()
                                        .box
                                        .border(color: textfieldGrey)
                                        .roundedSM
                                        .padding(
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        )
                                        .make(),
                                  ),
                                ),
                              ),
                            ],
                          ).box.padding(const EdgeInsets.all(8)).make(),
                        // quantity row
                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: "Quantity: ".text
                                  .color(textfieldGrey)
                                  .make(),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (quantity > 1) {
                                      setState(() {
                                        quantity--;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                "$quantity".text
                                    .size(16)
                                    .color(darkFontGrey)
                                    .fontFamily(bold)
                                    .make(),
                                IconButton(
                                  onPressed: () {
                                    if (quantity < widget.product.stock) {
                                      setState(() {
                                        quantity++;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                                10.widthBox,
                                "(${widget.product.stock} available)".text
                                    .color(textfieldGrey)
                                    .make(),
                              ],
                            ),
                          ],
                        ).box.padding(const EdgeInsets.all(8)).make(),
                        // total row
                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: "Total: ".text.color(textfieldGrey).make(),
                            ),
                            "\$${(widget.product.price * quantity).toStringAsFixed(2)}"
                                .text
                                .color(redColor)
                                .size(16)
                                .fontFamily(bold)
                                .make(),
                          ],
                        ).box.padding(const EdgeInsets.all(8)).make(),
                      ],
                    ).box.white.shadowSm.make(),

                    10.heightBox,
                    // description section
                    "Description".text
                        .color(darkFontGrey)
                        .fontFamily(semibold)
                        .make(),
                    10.heightBox,
                    widget.product.description.text.color(darkFontGrey).make(),

                    // buttons section
                    10.heightBox,
                    ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: List.generate(
                        itemDetailButtonList.length,
                        (index) => Material(
                          color: Colors.transparent,
                          child: ListTile(
                            title: itemDetailButtonList[index].text
                                .fontFamily(semibold)
                                .color(darkFontGrey)
                                .make(),
                            trailing: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ),
                    ),
                    20.heightBox,
                    // products may like section
                    productsYouMayLike.text
                        .fontFamily(bold)
                        .size(16)
                        .color(darkFontGrey)
                        .make(),
                    10.heightBox,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          dummyProducts
                              .where(
                                (p) => p.category == widget.product.category,
                              )
                              .length,
                          (index) {
                            final relatedProduct = dummyProducts
                                .where(
                                  (p) => p.category == widget.product.category,
                                )
                                .toList()[index];
                            return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      relatedProduct.images.isNotEmpty
                                          ? relatedProduct.images[0]
                                          : imgP1,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                                    10.heightBox,
                                    relatedProduct.name.text
                                        .fontFamily(semibold)
                                        .color(darkFontGrey)
                                        .maxLines(2)
                                        .overflow(TextOverflow.ellipsis)
                                        .make(),
                                    10.heightBox,
                                    "\$${relatedProduct.price.toStringAsFixed(2)}"
                                        .text
                                        .color(redColor)
                                        .fontFamily(bold)
                                        .size(14)
                                        .make(),
                                  ],
                                ).box.white.roundedSM
                                .margin(
                                  const EdgeInsets.symmetric(horizontal: 4),
                                )
                                .padding(const EdgeInsets.all(8))
                                .make();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ourButton(
              onPress: () {
                Get.find<CartController>().addProduct(
                  widget.product,
                  quantity: quantity,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: "Added ${widget.product.name} x$quantity to cart"
                        .text
                        .make(),
                  ),
                );
              },
              title: "Add To Cart",
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'pink':
        return Colors.pink;
      case 'purple':
        return Colors.purple;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey[400] ?? Colors.grey;
      case 'brown':
        return Colors.brown;
      case 'grey':
        return Colors.grey;
      case 'dark blue':
        return Colors.blue[900] ?? Colors.blue;
      case 'light blue':
        return Colors.blue[200] ?? Colors.blue;
      default:
        return Vx.randomPrimaryColor;
    }
  }
}
