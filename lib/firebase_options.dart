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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDAwURCySC2kJfqWVvj9R1s07Sx6NPYKnU',
    appId: '1:31135080982:web:4312b32752c630af41cb37',
    messagingSenderId: '31135080982',
    projectId: 'record-app-b1d9c',
    authDomain: 'record-app-b1d9c.firebaseapp.com',
    storageBucket: 'record-app-b1d9c.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyATXz_nFUlrQPdYnM2jM8UefG9XafdgtNw',
    appId: '1:31135080982:android:fdc1b7e0d9e2d30041cb37',
    messagingSenderId: '31135080982',
    projectId: 'record-app-b1d9c',
    storageBucket: 'record-app-b1d9c.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBVX5RJbNuxyhNR_V4V0xKnecUqMhFaGG0',
    appId: '1:31135080982:ios:208b4993a409c3d541cb37',
    messagingSenderId: '31135080982',
    projectId: 'record-app-b1d9c',
    storageBucket: 'record-app-b1d9c.appspot.com',
    iosClientId: '31135080982-jr8onvqb6q4rm09suuuq4ndt7v7r39ks.apps.googleusercontent.com',
    iosBundleId: 'com.example.recordsApplication.RunnerTests',
  );
}
