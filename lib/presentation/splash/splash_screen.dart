import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withme/core/presentation/components/my_circular_indicator.dart';
import 'package:withme/core/presentation/components/width_height.dart';

import '../../core/di/setup.dart';
import '../../core/router/router.dart';
import '../../core/router/router_path.dart';
import '../../core/ui/core_ui_import.dart';
import '../home/customer_list/customer_list_view_model.dart';
import '../home/prospect_list/prospect_list_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    await Future.delayed(AppDurations.duration300);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !user.emailVerified || (user.uid.isEmpty)) {
      authChangeNotifier.setLoggedIn(false);
      if (mounted) {
        context.go(RoutePath.login);
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

    if (!onboardingComplete) {
      authChangeNotifier.setNeedsOnboarding(true);
      return;
    }

    if (authChangeNotifier.isDataLoaded) {
      authChangeNotifier.setNeedsOnboarding(false);
      return;
    }

    try {
      await getIt<ProspectListViewModel>().fetchData();
      await getIt<CustomerListViewModel>().refresh();
    } catch (_) {}

    authChangeNotifier.setDataLoaded(true);
    authChangeNotifier.setNeedsOnboarding(false);

    if (mounted) {
      context.go(RoutePath.home); // ✅ 여기서 직접 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('withMe', style: TextStyles.bold20),
            height(10),
            const MyCircularIndicator(),
          ],
        ),
      ),
    );
  }
}
