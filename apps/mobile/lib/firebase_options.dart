// ============================================================
// MOCK Firebase Options for LOCAL DEVELOPMENT ONLY.
// ============================================================
// This file lets the app boot against Firebase emulators without
// a real Firebase project config. Replace this with the real
// generated file by running:
//
//   flutterfire configure --project=scab-purdue
//
// DO NOT deploy to production with this file.
// ============================================================

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
        return android; // fallback for desktop/web during dev
    }
  }

  // These are placeholder values — the emulators don't validate them.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'fake-api-key-for-emulator',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'scab-purdue',
    storageBucket: 'scab-purdue.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'fake-api-key-for-emulator',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'scab-purdue',
    storageBucket: 'scab-purdue.appspot.com',
    iosBundleId: 'com.purdue.personalTrainer',
  );
}
