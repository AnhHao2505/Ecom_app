import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/views/home_screen/components/featured_button.dart';
import 'package:e_mart/widget_common/product_card.dart';
import 'package:get/get.dart';

import '../../consts/lists.dart';
import '../../widget_common/home_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

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
                onChanged: (value) => controller.searchQuery.value = value,
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

                    // category buttons
                    10.heightBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        3,
                        (index) => homeButtons(
                          height: context.screenHeight * 0.15,
                          width: context.screenWidth / 3.5,
                          icon: index == 0
                              ? icTopCategories
                              : index == 1
                              ? icBrands
                              : icTopSeller,
                          title: index == 0
                              ? topCategories
                              : index == 1
                              ? brand
                              : topSellers,
                        ),
                      ),
                    ),

                    // Featured Categories
                    20.heightBox,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: featuredCategories.text
                          .color(darkFontGrey)
                          .size(18)
                          .fontFamily(semibold)
                          .make(),
                    ),
                    20.heightBox,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          3,
                          (index) => Column(
                            children: [
                              featuredButton(
                                icon: featuredImages1[index],
                                title: featuredTitles1[index],
                              ),
                              10.heightBox,
                              featuredButton(
                                icon: featuredImages2[index],
                                title: featuredTitles2[index],
                              ),
                            ],
                          ),
                        ),
                      ),
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
                          Obx(() {
                            if (controller.isLoading.value) {
                              return const SizedBox(
                                height: 220,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: whiteColor,
                                  ),
                                ),
                              );
                            }

                            final products = controller.productsList
                                .take(6)
                                .toList();
                            if (products.isEmpty) {
                              return const SizedBox(
                                height: 80,
                                child: Center(
                                  child: Text(
                                    'Chưa có sản phẩm nổi bật.',
                                    style: TextStyle(color: whiteColor),
                                  ),
                                ),
                              );
                            }

                            return SizedBox(
                              height: 240,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: products.length,
                                separatorBuilder: (_, _) => 8.widthBox,
                                itemBuilder: (context, index) => SizedBox(
                                  width: 165,
                                  child: ProductCard(
                                    product: products[index],
                                    imageHeight: 145,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    // third swiper
                    20.heightBox,
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

                    // all products section
                    20.heightBox,
                    Obx(() {
                      if (controller.errorMessage.isNotEmpty) {
                        return Column(
                          children: [
                            Text(controller.errorMessage.value),
                            TextButton(
                              onPressed: controller.fetchProductsData,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        );
                      }

                      final products = controller.filteredProducts;
                      if (!controller.isLoading.value && products.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Text('Không tìm thấy sản phẩm.'),
                        );
                      }

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              mainAxisExtent: 285,
                            ),
                        itemBuilder: (context, index) {
                          return ProductCard(product: products[index]);
                        },
                      );
                    }),
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
