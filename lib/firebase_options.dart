// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyC7KoBW4DvaGnUklptWlfoN_Hj3bEHVEnc',
    appId: '1:623211594806:web:b4253e3c0d2d016ecbc497',
    messagingSenderId: '623211594806',
    projectId: 'levatimovie',
    authDomain: 'levatimovie.firebaseapp.com',
    databaseURL: 'https://levatimovie-default-rtdb.firebaseio.com',
    storageBucket: 'levatimovie.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJOJN4nhQsBVxRJVCcgP7CsOvosmTeMZg',
    appId: '1:623211594806:android:0eaf78cc1f3496a0cbc497',
    messagingSenderId: '623211594806',
    projectId: 'levatimovie',
    databaseURL: 'https://levatimovie-default-rtdb.firebaseio.com',
    storageBucket: 'levatimovie.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBL-fVjwboPNBs6oGcpZcFhQ-JK8nC1XTo',
    appId: '1:623211594806:ios:c88da30bdef702a3cbc497',
    messagingSenderId: '623211594806',
    projectId: 'levatimovie',
    databaseURL: 'https://levatimovie-default-rtdb.firebaseio.com',
    storageBucket: 'levatimovie.appspot.com',
    iosBundleId: 'com.example.iotEspNow',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBL-fVjwboPNBs6oGcpZcFhQ-JK8nC1XTo',
    appId: '1:623211594806:ios:c88da30bdef702a3cbc497',
    messagingSenderId: '623211594806',
    projectId: 'levatimovie',
    databaseURL: 'https://levatimovie-default-rtdb.firebaseio.com',
    storageBucket: 'levatimovie.appspot.com',
    iosBundleId: 'com.example.iotEspNow',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC7KoBW4DvaGnUklptWlfoN_Hj3bEHVEnc',
    appId: '1:623211594806:web:b4253e3c0d2d016ecbc497',
    messagingSenderId: '623211594806',
    projectId: 'levatimovie',
    authDomain: 'levatimovie.firebaseapp.com',
    databaseURL: 'https://levatimovie-default-rtdb.firebaseio.com',
    storageBucket: 'levatimovie.appspot.com',
  );

}