import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart/consts/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/product.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;

  // textControllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // login method
  Future<UserCredential?> loginMethod(context) async {
    UserCredential? userCredential;

    try {
      userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
    return userCredential;
  }

  // signup method
  Future<UserCredential?> signupMethod({email, password, context}) async {
    UserCredential? userCredential;

    try {
      userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
    return userCredential;
  }

  // signout method
  Future<void> signoutMethod(context) async {
    try {
      await auth.signOut();
    } catch (e) {
      VxToast.show(context, msg: e.toString());
    }
  }

  // storing data method
  Future<void> storeUserData({name, password, email}) async {
    final user = auth.currentUser;
    if (user == null) return;

    final DocumentReference store = firestore
        .collection(usersCollection)
        .doc(user.uid);
    await store.set({
      'name': name,
      'email': email,
      'password': password,
      'imageUrl': '',
      'id': user.uid,
    });
  }

  Future<void> storeProductData(Product product) async {
    final DocumentReference store = firestore
        .collection(productCollection)
        .doc();
    final data = product.toMap();
    data['id'] = store.id;

    await store.set(data);
  }
}
