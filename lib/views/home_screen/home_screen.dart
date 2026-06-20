import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/widget_common/home_button.dart';
import 'package:e_mart/widget_common/product_card.dart';
import 'package:e_mart/controllers/theme_controller.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [darkBg, darkBgGradientEnd]
              : [lightBg, lightBgGradientEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      width: context.screenWidth,
      height: context.screenHeight,
      padding: EdgeInsets.zero,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header: App Name & Dark Mode
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appname,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: bold,
                      fontSize: 22,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    onPressed: () {
                      Get.find<ThemeController>().toggleTheme();
                    },
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.transparent
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    hintText: searchAnything,
                    hintStyle: TextStyle(color: textfieldGrey.withOpacity(0.8)),
                  ),
                ),
              ),
            ),
            10.heightBox,
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VxSwiper.builder(
                        aspectRatio: 16 / 9,
                        autoPlay: true,
                        height: 150,
                        enlargeCenterPage: true,
                        itemCount: sliderLists.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.transparent
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(sliderLists[index], fit: BoxFit.fill),
                            ),
                          );
                        },
                      ),
                      16.heightBox,
                      // Category Icons
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categoriesData.length,
                          itemBuilder: (context, index) {
                            return _buildCategoryIcon(context, categoriesData[index].name, categoriesData[index].image);
                          },
                        ),
                      ),
                      16.heightBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          2,
                          (index) => HomeButton(
                            height: context.screenHeight * 0.1,
                            width: context.screenWidth / 2.5,
                            icon: index == 0 ? icTodaysDeal : icFlashDeal,
                            title: index == 0 ? todayDeal : flashsale,
                          ),
                        ),
                      ),
                      20.heightBox,
                      Obx(() {
                        final featured = controller.featuredProducts;
                        if (controller.searchQuery.isNotEmpty &&
                            featured.isEmpty) {
                          return const SizedBox.shrink();
                        }
  
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? darkDivider 
                                  : primaryColor.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.transparent 
                                    : primaryColor.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.star_rounded, color: primaryColor, size: 24),
                                  ),
                                  12.widthBox,
                                  featuredProduct.text
                                      .color(Theme.of(context).textTheme.bodyLarge?.color)
                                      .fontFamily(bold)
                                      .size(18)
                                      .make(),
                                ],
                              ),
                              16.heightBox,
                              SizedBox(
                                height: 270,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: featured.length,
                                  separatorBuilder: (_, _) => 12.widthBox,
                                  itemBuilder: (context, index) {
                                    return SizedBox(
                                      width: 170,
                                      child: ProductCard(
                                        product: featured[index],
                                        imageHeight: 145,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      20.heightBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'All Products',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontFamily: bold,
                              fontSize: 18,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('See all >', style: TextStyle(color: primaryColor)),
                          ),
                        ],
                      ),
                      12.heightBox,
                      Obx(() {
                        final products = controller.filteredProducts;
                        if (products.isEmpty) {
                          return SizedBox(
                            height: 180,
                            child: Center(
                              child: Text(
                                'No products match your search.',
                                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                              ),
                            ),
                          );
                        }
  
                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: products.length,
                          gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              mainAxisExtent: 270,
                            ),
                          itemBuilder: (context, index) {
                            return ProductCard(product: products[index]);
                          },
                        );
                      }),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context, String title, String imagePath) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.transparent 
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
          ),
          8.heightBox,
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 11,
              fontFamily: semibold,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
