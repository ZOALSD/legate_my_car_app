// File generated using values from google-services.json
// This file should ideally be regenerated using FlutterFire CLI:
// flutterfire configure
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOc3tCHwAJbvcPngBndzReVVp8fZZHYqY',
    appId: '1:217253882595:android:89cc7acd9bde15d562f3d6',
    messagingSenderId: '217253882595',
    projectId: 'laqeetarabeety',
    storageBucket: 'laqeetarabeety.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBOc3tCHwAJbvcPngBndzReVVp8fZZHYqY',
    appId: '1:217253882595:ios:placeholder',
    messagingSenderId: '217253882595',
    projectId: 'laqeetarabeety',
    storageBucket: 'laqeetarabeety.firebasestorage.app',
    iosBundleId: 'com.laqeetarabeety.managers',
  );
}
