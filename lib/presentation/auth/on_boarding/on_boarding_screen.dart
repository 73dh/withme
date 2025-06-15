import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/core_ui_import.dart';
import 'package:withme/core/utils/generate_user_key.dart';

import '../../../core/data/fire_base/firestore_keys.dart';
import '../../../core/di/di_setup_import.dart';
import '../../../core/di/setup.dart';
import '../../../core/router/router.dart';
import '../../../domain/model/user_model.dart';

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
      final currentUser=FirebaseAuth.instance.currentUser;
      debugPrint('이메일 인증 완료, 홈 화면으로 이동합니다., firebase 생성');
      await FirebaseFirestore.instance
          .collection(collectionUsers)
          .doc(currentUser?.uid)
          .set(
        UserModel(
          userKey: currentUser?.uid??'',       // 실제 uid 사용
          email: currentUser?.email ?? '',
          agreedDate: DateTime.now(),
        ).toMap(),
      );

      await getIt<ProspectListViewModel>().fetchData();
      await getIt<CustomerListViewModel>().refresh();
    } catch (_) {}

    authChangeNotifier.setDataLoaded(true);  // 데이터 로딩 완료 표시

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
      appBar: AppBar(title: const Text('앱 소개')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            height(10),
            const Text('withMe에 오신 것을 환영합니다!', style: TextStyles.bold20),
            height(40),
            const Text(
              '이 앱은 가망고객을 발굴한 후\n고객을 손쉽게 체계적으로 관리할수 있도록\n만들었습니다.'
                  '\n\n생일, 상령일, 미관리 고객등을 선별해 볼수도 있으며\n계약자의 경우 계약내용까지 관리가 가능합니다.'
                  '\n\n또한, Dashboard에서는 현재 관리중인 가망고객이나 계약자의 통계를 확인할 수 있습니다.'
                  '\n\n\n50명 고객까지는 무료로 사용이 가능하며, \n이상의 고객을 관리하기 위해서는 유료 서비스를 신청하시기 바랍니다.'
                  '\n\n\n\n 문의: kdaehee@gmail.com',
              style: TextStyles.normal14,
            ),
            height(40),
            ElevatedButton(
              onPressed: _isLoading ? null : _completeOnboarding,
              child: _isLoading
                  ? SizedBox(
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
