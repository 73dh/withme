import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withme/core/di/setup.dart';

import 'app.dart';
import 'core/data/fire_base/firebase_options.dart';
import 'core/data/fire_base/user_session.dart';
import 'core/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  diSetup();
  initializeAuthState(); // ✅ 온보딩 상태 초기화
  runApp(const App());
}

Future<void> initializeAuthState() async {
  final prefs = await SharedPreferences.getInstance();

  // ✅ 온보딩 여부 초기화
  final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
  authChangeNotifier.setNeedsOnboarding(!onboardingComplete);

  // // ✅ 관리주기 초기화 (기본 60)
  // final savedDays = prefs.getInt('prospectCycleDays') ?? 60;


}

// void initializeAuthState() async {
//   final prefs = await SharedPreferences.getInstance();
//   final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
//   authChangeNotifier.setNeedsOnboarding(!onboardingComplete);
// }
