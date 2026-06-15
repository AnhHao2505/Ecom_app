import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (!kIsWeb) return null;

    return const FirebaseOptions(
      apiKey: 'AIzaSyCQFqEl2rT_td86Pxz9RiNNUr5uQ7Jlicc',
      appId: '1:979649997499:android:6d2d202be4db6d2859579e',
      messagingSenderId: '979649997499',
      projectId: 'emart-1dafe',
      authDomain: 'emart-1dafe.firebaseapp.com',
      storageBucket: 'emart-1dafe.firebasestorage.app',
    );
  }
}
