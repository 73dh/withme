import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withme/core/di/setup.dart';

import 'app.dart';
import 'core/data/fire_base/firebase_options.dart';
import 'core/router/router.dart';
import 'core/ui/theme/theme_controller.dart'; // ✅ 추가

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 중복 초기화 방지
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    Firebase.app(); // 이미 초기화된 앱 재사용
  }

  await diSetup();
  await initializeAuthState();

  // ✅ 테마 상태를 앱 시작 전에 로드
  await themeController.loadTheme();

  runApp(const App());
}

Future<void> initializeAuthState() async {
  final prefs = await SharedPreferences.getInstance();

  // ✅ 온보딩 여부 초기화
  final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
  authChangeNotifier.setNeedsOnboarding(!onboardingComplete);
}
