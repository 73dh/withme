import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/core_ui_import.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    if (context.mounted) {
      context.go(RoutePath.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('앱 소개')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            const Text('withMe에 오신 것을 환영합니다!', style: TextStyles.bold20),
            const SizedBox(height: 20),
            const Text(
              '이 앱은 고객을 손쉽게 관리하고\n생일이나 보험 갱신을 추적하는 데 도움을 줍니다.',
              style: TextStyles.normal14,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _completeOnboarding(context),
              child: const Text('시작하기'),
            ),
          ],
        ),
      ),
    );
  }
}
