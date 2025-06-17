import 'package:firebase_auth/firebase_auth.dart';

class UserSession {
  static String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';
}
