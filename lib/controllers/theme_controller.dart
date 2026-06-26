import 'package:get/get.dart';

class ThemeController extends GetxController {
  final isDarkMode = false.obs;
  
  void toggleTheme() {
    isDarkMode.toggle();
    update();
  }
}
