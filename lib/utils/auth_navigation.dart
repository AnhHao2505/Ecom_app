import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/views/auth_screen/login_screen.dart';
import 'package:e_mart/views/home_screen/base_home.dart';
import 'package:e_mart/views/seller_screen/seller_dashboard_screen.dart';
import 'package:e_mart/views/seller_screen/seller_shop_setup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

Future<void> openLandingForCurrentUser() async {
  final user = auth.currentUser;
  if (user == null) {
    Get.offAll(() => const LoginScreen());
    return;
  }

  await openLandingForUser(user);
}

Future<void> openLandingForUser(User user) async {
  final userSnapshot = await firestore
      .collection(usersCollection)
      .doc(user.uid)
      .get();
  final role = userSnapshot.data()?['role']?.toString().toLowerCase() ?? '';

  if (role == 'seller') {
    final storeSnapshot = await firestore
        .collection(storesCollection)
        .doc(user.uid)
        .get();
    if (storeSnapshot.exists) {
      Get.offAll(() => const SellerDashboardScreen());
    } else {
      Get.offAll(() => const SellerShopSetupScreen());
    }
    return;
  }

  Get.offAll(() => const Home());
}
