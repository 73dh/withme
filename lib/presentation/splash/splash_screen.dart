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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !user.emailVerified || user.uid.isEmpty) {
      authChangeNotifier.setLoggedIn(false);
      await Future.delayed(AppDurations.duration300);
      if (mounted) context.go(RoutePath.login);
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
      if (mounted) context.go(RoutePath.home);
      return;
    }

    try {
      await getIt<ProspectListViewModel>().fetchData();
      await getIt<CustomerListViewModel>().refresh();
    } catch (_) {}

    authChangeNotifier.setDataLoaded(true);
    authChangeNotifier.setNeedsOnboarding(false);

    if (mounted) context.go(RoutePath.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: colorScheme.surface, // M3 background 적용
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'withMe',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary, // M3 primary 색상 적용
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
            height(10),
            const MyCircularIndicator(),
          ],
        ),
      ),
    );
  }
}

//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initScreen();
//   }
//
//   Future<void> _initScreen() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null || !user.emailVerified || (user.uid.isEmpty)) {
//       authChangeNotifier.setLoggedIn(false);
//       await Future.delayed(AppDurations.duration300);
//       if (mounted) {
//         context.go(RoutePath.login);
//       }
//       return;
//     }
//     final prefs = await SharedPreferences.getInstance();
//     final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
//
//     if (!onboardingComplete) {
//       authChangeNotifier.setNeedsOnboarding(true);
//       return;
//     }
//
//     if (authChangeNotifier.isDataLoaded) {
//       authChangeNotifier.setNeedsOnboarding(false);
//       if (mounted) {
//         context.go(RoutePath.home); // 여기에 홈 이동 추가!
//       }
//       return;
//     }
//
//     try {
//       await getIt<ProspectListViewModel>().fetchData();
//       await getIt<CustomerListViewModel>().refresh();
//     } catch (_) {}
//
//     authChangeNotifier.setDataLoaded(true);
//     authChangeNotifier.setNeedsOnboarding(false);
//
//     if (mounted) {
//       context.go(RoutePath.home); // ✅ 여기서 직접 이동
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//              Text('withMe', style: Theme.of(context).textTheme.displayLarge),
//             height(10),
//             const MyCircularIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }
