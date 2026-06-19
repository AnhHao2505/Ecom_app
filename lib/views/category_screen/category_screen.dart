import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/views/category_screen/category_detail.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: redColor,
        elevation: 0,
        title: categories.text.fontFamily(bold).white.size(20).make(),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            mainAxisExtent: 220,
          ),
          itemCount: categoriesData.length,
          itemBuilder: (context, index) {
            return _buildCategoryCard(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, int index) {
    final category = categoriesData[index];
    return GestureDetector(
      onTap: () {
        Get.to(
          () => CategoryDetail(categoryKey: category.key, title: category.name),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: darkFontGrey.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Image Container
            Container(
              width: double.infinity,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: lightGrey,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(category.image, fit: BoxFit.cover),
                  // Overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          darkFontGrey.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text Container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    category.name.text
                        .color(darkFontGrey)
                        .fontFamily(semibold)
                        .size(14)
                        .center
                        .maxLines(2)
                        .overflow(TextOverflow.ellipsis)
                        .make(),
                    6.heightBox,
                    Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: redColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).box.border(color: lightGrey).make(),
    );
  }
}
