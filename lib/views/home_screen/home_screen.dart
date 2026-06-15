import 'package:e_mart/consts/consts.dart';

import '../../consts/lists.dart';
import '../../widget_common/home_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: lightGrey,
      width: context.screenWidth,
      height: context.screenHeight,
      padding: const EdgeInsets.all(12),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              color: lightGrey,
              height: 60,
              child: TextFormField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: whiteColor,
                  hintText: searchAnything,
                  hintStyle: TextStyle(color: textfieldGrey),
                ),
              ),
            ),
            10.heightBox,

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    //swiper brands
                    VxSwiper.builder(
                      aspectRatio: 16 / 9,
                      autoPlay: true,
                      height: 150,
                      enlargeCenterPage: true,
                      itemCount: sliderLists.length,
                      itemBuilder: (context, index) {
                        return Image.asset(sliderLists[index], fit: BoxFit.fill)
                            .box
                            .rounded
                            .clip(Clip.antiAlias)
                            .margin(const EdgeInsets.symmetric(horizontal: 8))
                            .make();
                      },
                    ),
                    10.heightBox,
                    // deals buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        2,
                        (index) => homeButtons(
                          height: context.screenHeight * 0.1,
                          width: context.screenWidth / 2.5,
                          icon: index == 0 ? icTodaysDeal : icFlashDeal,
                          title: index == 0 ? todayDeal : flashsale,
                        ),
                      ),
                    ),
                    10.heightBox,
                    // 2nd swiper
                    VxSwiper.builder(
                      aspectRatio: 16 / 9,
                      autoPlay: true,
                      height: 150,
                      enlargeCenterPage: true,
                      itemCount: secondSliderList.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                              secondSliderList[index],
                              fit: BoxFit.fill,
                            ).box.rounded
                            .clip(Clip.antiAlias)
                            .margin(const EdgeInsets.symmetric(horizontal: 8))
                            .make();
                      },
                    ),

                    // featured products
                    20.heightBox,
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: const BoxDecoration(color: redColor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          featuredProduct.text.white
                              .fontFamily(bold)
                              .size(18)
                              .make(),
                          10.heightBox,
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                dummyProducts.where((p) => p.isFeatured).length,
                                (index) {
                                  final product = dummyProducts
                                      .where((p) => p.isFeatured)
                                      .toList()[index];
                                  return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            product.images.isNotEmpty
                                                ? product.images[0]
                                                : imgP1,
                                            width: 150,
                                            height: 150,
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
                                          5.heightBox,
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                                size: 16,
                                              ),
                                              5.widthBox,
                                              "${product.rating}".text
                                                  .size(12)
                                                  .color(darkFontGrey)
                                                  .make(),
                                            ],
                                          ),
                                          10.heightBox,
                                          "\$${product.price.toStringAsFixed(2)}"
                                              .text
                                              .color(redColor)
                                              .fontFamily(bold)
                                              .size(14)
                                              .make(),
                                        ],
                                      ).box.white.roundedSM
                                      .margin(
                                        const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
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

                    // all products section
                    20.heightBox,
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: dummyProducts
                          .where((p) => !p.isFeatured)
                          .length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            mainAxisExtent: 300,
                          ),
                      itemBuilder: (context, index) {
                        final product = dummyProducts
                            .where((p) => !p.isFeatured)
                            .toList()[index];
                        return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  product.images.isNotEmpty
                                      ? product.images[0]
                                      : imgP5,
                                  width: 200,
                                  height: 150,
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
                                5.heightBox,
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 14,
                                    ),
                                    5.widthBox,
                                    "${product.rating}".text
                                        .size(10)
                                        .color(darkFontGrey)
                                        .make(),
                                    5.widthBox,
                                    "(${product.reviewCount})".text
                                        .size(10)
                                        .color(darkFontGrey)
                                        .make(),
                                  ],
                                ),
                                5.heightBox,
                                product.isInStock
                                    ? "In Stock".text
                                          .size(10)
                                          .color(Colors.green)
                                          .make()
                                    : "Out of Stock".text
                                          .size(10)
                                          .color(redColor)
                                          .make(),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (product.originalPrice >
                                        product.price) ...[
                                      "\$${product.originalPrice.toStringAsFixed(2)}"
                                          .text
                                          .lineThrough
                                          .size(10)
                                          .color(darkFontGrey)
                                          .make(),
                                    ],
                                    Row(
                                      children: [
                                        "\$${product.price.toStringAsFixed(2)}"
                                            .text
                                            .color(redColor)
                                            .fontFamily(bold)
                                            .size(14)
                                            .make(),
                                        5.widthBox,
                                        if (product.discountPercentage > 0)
                                          "${product.discountPercentage.toStringAsFixed(0)}% off"
                                              .text
                                              .fontFamily(bold)
                                              .size(10)
                                              .color(Colors.orange)
                                              .make(),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ).box.white.roundedSM
                            .margin(const EdgeInsets.symmetric(horizontal: 4))
                            .padding(const EdgeInsets.all(12))
                            .make();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
