import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDnYJlhEIG15-Hr8WNMpELkl5VcginIlEE',
    appId: '1:113968016254:web:79011c13e42a40e52a612f',
    messagingSenderId: '113968016254',
    projectId: 'brewhub-cafe-app',
    authDomain: 'brewhub-cafe-app.firebaseapp.com',
    storageBucket: 'brewhub-cafe-app.firebasestorage.app',
    measurementId: 'G-QS4FF7Q2QP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB6s99uSkkVh6511F8dP15pY70r-NLBsFU',
    appId: '1:113968016254:android:7f55301570dd1bf02a612f',
    messagingSenderId: '113968016254',
    projectId: 'brewhub-cafe-app',
    storageBucket: 'brewhub-cafe-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD7QW-7BltqnxFI5x2y3z4a5b6c7d8e9f0g',
    appId: '1:123456789:ios:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'brewhub-cafe-app',
    storageBucket: 'brewhub-cafe-app.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com',
    iosBundleId: 'com.example.brewhub',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD7QW-7BltqnxFI5x2y3z4a5b6c7d8e9f0g',
    appId: '1:123456789:macos:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'brewhub-cafe-app',
    storageBucket: 'brewhub-cafe-app.firebasestorage.app',
    iosClientId: 'YOUR_MACOS_CLIENT_ID.apps.googleusercontent.com',
    iosBundleId: 'com.example.brewhub',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD7QW-7BltqnxFI5x2y3z4a5b6c7d8e9f0g',
    appId: '1:123456789:windows:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'brewhub-cafe-app',
    storageBucket: 'brewhub-cafe-app.firebasestorage.app',
    authDomain: 'brewhub-cafe-app.firebaseapp.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyD7QW-7BltqnxFI5x2y3z4a5b6c7d8e9f0g',
    appId: '1:123456789:linux:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'brewhub-cafe-app',
    storageBucket: 'brewhub-cafe-app.firebasestorage.app',
    authDomain: 'brewhub-cafe-app.firebaseapp.com',
  );
}

