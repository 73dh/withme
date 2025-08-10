import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/core_ui_import.dart';

import '../../../core/di/di_setup_import.dart';
import '../../../core/di/setup.dart';
import '../../../core/router/router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isLoading = false;

  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);

    // 온보딩 완료 상태 업데이트
    authChangeNotifier.setNeedsOnboarding(false);

    // 데이터 로딩 수행
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid ?? '';
      final email = currentUser?.email ?? '';
      debugPrint('이메일 인증 완료, 홈 화면으로 이동합니다., firebase 생성');
      await getIt<FBase>().createUser(userId: userId, email: email);

      await getIt<ProspectListViewModel>().fetchData();
      await getIt<CustomerListViewModel>().refresh();
    } catch (_) {}

    authChangeNotifier.setDataLoaded(true); // 데이터 로딩 완료 표시

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      context.go(RoutePath.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            height(10),
            const Text('withMe에 오신 것을 환영합니다!', style: TextStyles.bold20),
            height(40),
            styledInfoText,
            // const Text(infoText, style: TextStyles.normal14),
            height(40),
            ElevatedButton(
              onPressed: _isLoading ? null : _completeOnboarding,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('시작하기'),
            ),
          ],
        ),
      ),
    );
  }
}
