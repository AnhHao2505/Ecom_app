import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/views/cart_screen/cart_screen.dart';
import 'package:e_mart/views/category_screen/category_screen.dart';
import 'package:e_mart/views/home_screen/home_screen.dart';
import 'package:e_mart/views/profile_screen/profile_screen.dart';
import 'package:get/get.dart';

import '../../consts/consts.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(HomeController());
    Get.put(CartController());

    var navbarItem = [
      BottomNavigationBarItem(
        icon: Image.asset(icHome, width: 26),
        label: home,
      ),
      BottomNavigationBarItem(
        icon: Image.asset(icCategories, width: 26),
        label: categories,
      ),
      BottomNavigationBarItem(
        icon: Obx(() {
          final count = Get.find<CartController>().cartItems.length;
          final displayCount = count > 99 ? '99+' : '$count';
          return Badge(
            isLabelVisible: count > 0,
            label: Text(displayCount, style: const TextStyle(fontSize: 10, fontFamily: bold, color: whiteColor)),
            backgroundColor: redColor,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Image.asset(icCart, width: 26),
          );
        }),
        label: cart,
      ),
      BottomNavigationBarItem(
        icon: Image.asset(icProfile, width: 26),
        label: account,
      ),
    ];

    var navBody = [
      const HomeScreen(),
      const CategoryScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Obx(
      () => Scaffold(
        extendBody: true,
        body: navBody.elementAt(controller.currentNavIndex.value),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.black.withOpacity(0.5) 
                    : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              currentIndex: controller.currentNavIndex.value,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: primaryColor,
              unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4) ?? fontGrey,
              selectedLabelStyle: const TextStyle(fontFamily: bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontFamily: semibold, fontSize: 12),
              items: navbarItem,
              onTap: (value) {
                controller.currentNavIndex.value = value;
              },
            ),
          ),
        ),
      ),
    );
  }
}
