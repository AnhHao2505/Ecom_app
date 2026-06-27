import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/views/category_screen/category_detail.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.4),
        title: categories.text.fontFamily(bold).white.size(20).make(),
        centerTitle: true,
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [darkBg, darkBgGradientEnd]
                : [lightBg, lightBgGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: categoriesData.length,
              separatorBuilder: (context, index) => 12.heightBox,
              itemBuilder: (context, index) {
                return _buildCategoryItem(context, index);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, int index) {
    final category = categoriesData[index];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get product count
    final homeController = Get.find<HomeController>();
    final productCount = homeController.productsByCategory(category.key).length;

    return GestureDetector(
      onTap: () {
        Get.to(
          () => CategoryDetail(categoryKey: category.key, title: category.name),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? darkDivider : lightDivider.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.transparent : Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category Icon/Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? darkSurface : lightSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  category.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.category_outlined,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            16.widthBox,
            // Category Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: bold,
                      fontSize: 16,
                    ),
                  ),
                  4.heightBox,
                  Text(
                    '$productCount products',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 12,
                      fontFamily: semibold,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing arrow
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
