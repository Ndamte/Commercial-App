// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCSlKRxNzBYmeIVSk2a2KwsUJWaA4vVEMY',
    appId: '1:115933775681:web:4a6adb54391fb138e683c0',
    messagingSenderId: '115933775681',
    projectId: 'commercial-app-20b21',
    authDomain: 'commercial-app-20b21.firebaseapp.com',
    storageBucket: 'commercial-app-20b21.appspot.com',
    measurementId: 'G-ZPTY9XGFNF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIXfXYM2_NyFK5lFD5gksTnw6X72Y_WTU',
    appId: '1:115933775681:android:1289b1b4a6b0bf43e683c0',
    messagingSenderId: '115933775681',
    projectId: 'commercial-app-20b21',
    storageBucket: 'commercial-app-20b21.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCEJQenM_5in4UdAul9GDWCKNWtAxGdtdk',
    appId: '1:115933775681:ios:2b284a5f7036a3fbe683c0',
    messagingSenderId: '115933775681',
    projectId: 'commercial-app-20b21',
    storageBucket: 'commercial-app-20b21.appspot.com',
    iosBundleId: 'com.example.commercialApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCEJQenM_5in4UdAul9GDWCKNWtAxGdtdk',
    appId: '1:115933775681:ios:10b049769cb77f0ee683c0',
    messagingSenderId: '115933775681',
    projectId: 'commercial-app-20b21',
    storageBucket: 'commercial-app-20b21.appspot.com',
    iosBundleId: 'com.example.commercialApp.RunnerTests',
  );
}
