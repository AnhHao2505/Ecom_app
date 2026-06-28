import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart/consts/consts.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  var profileImgPath = ''.obs;

  Future<void> changeImage(context) async {
    try {
      final img = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (img == null) return;
      profileImgPath.value = img.path;
    } on PlatformException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
  }

  Future<Map<String, String>> getProfileDataForCurrentUser() async {
    final snapshot = await firestore
        .collection(usersCollection)
        .doc(currentUser!.uid)
        .get();
    final dataMap = snapshot.data();
    return {
      'image': dataMap?['imageUrl']?.toString() ?? '',
      'name': dataMap?['name']?.toString() ?? 'Customer',
      'email': dataMap?['email']?.toString() ?? 'customer@example.com',
    };
  }
}
