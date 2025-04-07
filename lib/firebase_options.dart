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
    apiKey: 'AIzaSyDNmNAD7-OHkXNH230RIw_T8uwCv9BIubg',
    appId: '1:1065657635325:web:3945c40ecc299623344994',
    messagingSenderId: '1065657635325',
    projectId: 'agumobile-27c53',
    authDomain: 'agumobile-27c53.firebaseapp.com',
    databaseURL: 'https://agumobile-27c53-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'agumobile-27c53.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCeCBL8Ks7Ws_eqiERkegQ4BpUOSlIc-a8',
    appId: '1:1065657635325:android:19adaa02844c9279344994',
    messagingSenderId: '1065657635325',
    projectId: 'agumobile-27c53',
    databaseURL: 'https://agumobile-27c53-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'agumobile-27c53.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFmTZsP1GIoCjlB6OLo5HgeoRX7p3bB8U',
    appId: '1:1065657635325:ios:7a94fc246a5d89e4344994',
    messagingSenderId: '1065657635325',
    projectId: 'agumobile-27c53',
    databaseURL: 'https://agumobile-27c53-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'agumobile-27c53.firebasestorage.app',
    iosBundleId: 'com.example.homePage',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCFmTZsP1GIoCjlB6OLo5HgeoRX7p3bB8U',
    appId: '1:1065657635325:ios:7a94fc246a5d89e4344994',
    messagingSenderId: '1065657635325',
    projectId: 'agumobile-27c53',
    databaseURL: 'https://agumobile-27c53-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'agumobile-27c53.firebasestorage.app',
    iosBundleId: 'com.example.homePage',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDNmNAD7-OHkXNH230RIw_T8uwCv9BIubg',
    appId: '1:1065657635325:web:27104377c16b9aa2344994',
    messagingSenderId: '1065657635325',
    projectId: 'agumobile-27c53',
    authDomain: 'agumobile-27c53.firebaseapp.com',
    databaseURL: 'https://agumobile-27c53-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'agumobile-27c53.firebasestorage.app',
  );

}