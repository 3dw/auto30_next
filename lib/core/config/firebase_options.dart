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
    apiKey: 'AIzaSyBu6ps0axwxUgh2xUoLgTdMtGgnwaY_VNo',
    appId: '1:270389952986:web:5454756eafe52a645c80e3',
    messagingSenderId: '270389952986',
    projectId: 'shackhand-autolearn',
    authDomain: 'shackhand-autolearn.firebaseapp.com',
    storageBucket: 'shackhand-autolearn.appspot.com',
    databaseURL: 'https://shackhand-autolearn-auto30.firebaseio.com',
    measurementId: 'G-G06K7WVJ9R',
  );

  // 稍後我們會添加 android 和 ios 的配置
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-ANDROID-API-KEY',
    appId: 'YOUR-ANDROID-APP-ID',
    messagingSenderId: 'YOUR-ANDROID-MESSAGING-SENDER-ID',
    projectId: 'shackhand-autolearn',
    storageBucket: 'shackhand-autolearn.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: 'YOUR-IOS-APP-ID',
    messagingSenderId: 'YOUR-IOS-MESSAGING-SENDER-ID',
    projectId: 'shackhand-autolearn',
    storageBucket: 'shackhand-autolearn.appspot.com',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'com.auto30.auto30Next',
  );
}
