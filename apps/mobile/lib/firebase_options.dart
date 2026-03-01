import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return ios;
    }
  }

  // TODO: Add real Android config once an Android app is registered in Firebase.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'fake-api-key-for-emulator',
    appId: '1:995459861625:android:0000000000000000',
    messagingSenderId: '995459861625',
    projectId: 'scab-purdue',
    storageBucket: 'scab-purdue.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhXJR7VSZoCBULQ10RMoO9oRPxm-T0W60',
    appId: '1:995459861625:ios:7870b8d176d85cf31b98a8',
    messagingSenderId: '995459861625',
    projectId: 'scab-purdue',
    storageBucket: 'scab-purdue.firebasestorage.app',
    iosClientId: '995459861625-1mn5nvsjq8sq9e57qjttf2krp65t4bdc.apps.googleusercontent.com',
    iosBundleId: 'com.purdue.personaltrainer.purduePersonalTrainer',
  );
}
