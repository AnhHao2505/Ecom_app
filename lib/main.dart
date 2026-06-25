import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/theme_controller.dart';
import 'package:e_mart/controllers/wishlist_controller.dart';
import 'package:e_mart/controllers/recent_view_controller.dart';
import 'package:e_mart/firebase_options.dart';
import 'package:e_mart/services/product_seeder.dart';
import 'package:e_mart/views/splash_screen/splash_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();

  ProductSeeder.checkAndSeed();

  Get.put(ThemeController());
  Get.put(WishlistController());
  Get.put(RecentViewController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: appname,
        themeMode: controller.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: lightBg,
          cardColor: lightCard,
          primaryColor: primaryColor,
          fontFamily: regular,
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: darkFontGrey),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: lightTextPrimary),
            bodyMedium: TextStyle(color: lightTextPrimary),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: darkBg,
          cardColor: darkCard,
          primaryColor: primaryColor,
          fontFamily: regular,
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: darkTextPrimary),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: darkTextPrimary),
            bodyMedium: TextStyle(color: darkTextPrimary),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
