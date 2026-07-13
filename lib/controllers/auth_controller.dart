import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mart/consts/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  // Oauth login method
  Future<UserCredential?> loginWithGoogle() async {
    // 1. Ensure initialization
    final googleSignIn = GoogleSignIn.instance;

    // 2. Authentication (Identity)
    // Triggers the account picker / Credential Manager sheet
    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

    // 3. Authorization (Permissions)
    // Request scopes to retrieve the Access Token
    final List<String> scopes = ['email', 'profile'];
    final clientAuth = await googleUser.authorizationClient.authorizeScopes(
      scopes,
    );

    // 4. Create Firebase Credential
    final credential = GoogleAuthProvider.credential(
      idToken: googleUser.authentication.idToken,
      accessToken: clientAuth.accessToken,
    );

    // 5. Sign in to Firebase
    final userCredential = await auth.signInWithCredential(credential);

    // Check if user exists in Firestore
    final userDoc = await firestore
        .collection(usersCollection)
        .doc(userCredential.user!.uid)
        .get();

    // If user doesn't exist, create them
    if (!userDoc.exists) {
      await storeUserData(
        name: googleUser.displayName,
        email: googleUser.email,
        password: '',
        imageUrl: googleUser.photoUrl,
      );
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
      await GoogleSignIn.instance.signOut();
      await auth.signOut();
    } catch (e) {
      VxToast.show(context, msg: e.toString());
    }
  }

  // reset password (forgot password) - send unauthenticated reset email link
  Future<bool> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      VxToast.show(
        context,
        msg: 'Reset link sent to $email. Check your inbox.',
        position: VxToastPosition.top,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      VxToast.show(
        context,
        msg: e.message ?? e.toString(),
        position: VxToastPosition.top,
      );
      return false;
    } catch (e) {
      VxToast.show(context, msg: e.toString(), position: VxToastPosition.top);
      return false;
    }
  }

  // storing data method
  Future<void> storeUserData({
    name,
    password,
    email,
    imageUrl = '',
    String role = 'Customer',
  }) async {
    final user = auth.currentUser;
    if (user == null) return;

    final DocumentReference store = firestore
        .collection(usersCollection)
        .doc(user.uid);
    await store.set({
      'name': name,
      'email': email,
      'password': password,
      'imageUrl': imageUrl,
      'id': user.uid,
      'role': role,
      'shopSetupComplete': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> roleForUser(String userId) async {
    final snapshot = await firestore
        .collection(usersCollection)
        .doc(userId)
        .get();
    return snapshot.data()?['role']?.toString() ?? 'Customer';
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
