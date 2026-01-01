import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCUPZhF7YcLJbf0UWelqB5PFrypAAq10SkY",
    authDomain: "task-manager-app-46786.firebaseapp.com",
    projectId: "task-manager-app-46786",
    storageBucket: "task-manager-app-46786.firebasestorage.app",
    messagingSenderId: "170492144714",
    appId: "1:170492144714:web:1219859206bf1a27f6cab3",
  );

  static FirebaseOptions get currentPlatform => web;
}
