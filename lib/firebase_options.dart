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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDWgsJfN77Sf_kzDa0Y14-tfQuOrofL31Q',
    appId: '1:746113447405:web:3fa6e5039677ed965123e4',
    messagingSenderId: '746113447405',
    projectId: 'webrtccom1',
    authDomain: 'webrtccom1.firebaseapp.com',
    storageBucket: 'webrtccom1.appspot.com',
    measurementId: 'G-GE2MHKRSQ4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD49Bv4ovum9cTIMiD9cWCVcN_noWD6Y24',
    appId: '1:746113447405:android:523e63652dcb62835123e4',
    messagingSenderId: '746113447405',
    projectId: 'webrtccom1',
    storageBucket: 'webrtccom1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhFh0f7ta_mZqTvHHwgJRoBH2qX1I3_34',
    appId: '1:746113447405:ios:38c550243e7cad115123e4',
    messagingSenderId: '746113447405',
    projectId: 'webrtccom1',
    storageBucket: 'webrtccom1.appspot.com',
    iosClientId: '746113447405-qr6gjivllh1mv92k42htiss5hpup9680.apps.googleusercontent.com',
    iosBundleId: 'com.example.webrtcCom1',
  );
}
