import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/auth_controller.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/controllers/wishlist_controller.dart';
import 'package:e_mart/views/auth_screen/login_screen.dart';
import 'package:e_mart/views/profile_screen/edit_profile_screen.dart';
import 'package:e_mart/views/wishlist_screen/wishlist_screen.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> menuItems = [
      {
        "icon": Icons.shopping_bag_outlined,
        "title": "My Orders",
        "onTap": () {},
      },
      {
        "icon": Icons.location_on_outlined,
        "title": "Addresses",
        "onTap": () {},
      },
      {
        "icon": Icons.favorite_border,
        "title": "Wishlist",
        "onTap": () => Get.to(() => const WishlistScreen()),
      },
      {
        "icon": Icons.notifications_none,
        "title": "Notifications",
        "onTap": () {},
      },
      {"icon": Icons.settings_outlined, "title": "Settings", "onTap": () {}},
      {"icon": Icons.help_outline, "title": "Help Center", "onTap": () {}},
    ];

    Widget buildStatCard(String count, String title) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? darkDivider : lightDivider.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontFamily: bold,
                  fontSize: 20,
                  color: primaryColor,
                ),
              ),
              4.heightBox,
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [darkBg, darkBgGradientEnd]
                : [lightBg, lightBgGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: isDark ? darkSurface : primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [primaryDark.withOpacity(0.8), darkBg]
                          : [primaryColor, primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: whiteColor.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage(imgProfile2),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              16.widthBox,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    "Dummy User".text
                                        .fontFamily(bold)
                                        .size(18)
                                        .white
                                        .make(),
                                    4.heightBox,
                                    "customer@example.com".text.white
                                        .size(13)
                                        .make(),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Get.to(() => const EditProfileScreen());
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: whiteColor.withOpacity(0.2),
                                ),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: whiteColor,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildStatCard("675", "Orders"),
                        Obx(
                          () => buildStatCard(
                            "${Get.find<WishlistController>().count}",
                            "Wishlist",
                          ),
                        ),
                        Obx(
                          () => buildStatCard(
                            "${Get.find<CartController>().cartItems.length}",
                            "Cart",
                          ),
                        ),
                      ],
                    ),
                    24.heightBox,
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? darkDivider
                              : lightDivider.withOpacity(0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.transparent
                                : Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: menuItems.length,
                        separatorBuilder: (context, index) => Divider(
                          color: isDark ? darkDivider : lightDivider,
                          height: 1,
                          indent: 56,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: menuItems[index]["onTap"],
                              borderRadius: BorderRadius.vertical(
                                top: index == 0
                                    ? const Radius.circular(16)
                                    : Radius.zero,
                                bottom: index == menuItems.length - 1
                                    ? const Radius.circular(16)
                                    : Radius.zero,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        menuItems[index]["icon"],
                                        color: primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    16.widthBox,
                                    Expanded(
                                      child: Text(
                                        menuItems[index]["title"],
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                          fontFamily: semibold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    32.heightBox,
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: redColor.withOpacity(0.1),
                          foregroundColor: redColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          await Get.put(
                            AuthController(),
                          ).signoutMethod(context);
                          Get.offAll(() => const LoginScreen());
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Log Out",
                              style: TextStyle(fontFamily: bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    30.heightBox,
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
