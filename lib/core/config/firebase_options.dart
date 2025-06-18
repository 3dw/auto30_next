import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBx6qx-v9Fnd72sWnNAwarmFWi-91ypA1Y',
    appId: '1:701444204172:web:c138f756e9b73b9113bda9',
    messagingSenderId: '701444204172',
    projectId: 'auto30next-56a1a',
    authDomain: 'auto30next-56a1a.firebaseapp.com',
    storageBucket: 'auto30next-56a1a.appspot.com',
    measurementId: 'G-679XL5GVLT',
  );

  // 稍後我們會添加 android 和 ios 的配置
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-ANDROID-API-KEY',
    appId: 'YOUR-ANDROID-APP-ID',
    messagingSenderId: 'YOUR-ANDROID-MESSAGING-SENDER-ID',
    projectId: 'auto30next-56a1a',
    storageBucket: 'auto30next-56a1a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: 'YOUR-IOS-APP-ID',
    messagingSenderId: 'YOUR-IOS-MESSAGING-SENDER-ID',
    projectId: 'auto30next-56a1a',
    storageBucket: 'auto30next-56a1a.appspot.com',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'com.auto30.auto30Next',
  );
} 