import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/presentation/auth/log_in_screen.dart';
import 'package:withme/presentation/customer/customer_screen.dart';
import 'package:withme/presentation/home/home_screen.dart';
import 'package:withme/presentation/registration/screen/registration_screen.dart';
import 'package:withme/presentation/splash/splash_screen.dart';

import '../../domain/model/customer_model.dart';
import '../../presentation/auth/on_boarding_screen.dart';
import '../../presentation/auth/sign_up_screen.dart';
import '../../presentation/auth/verify_email_screen.dart';
import '../../presentation/policy/screen/policy_screen.dart';
import '../di/setup.dart';

final authChangeNotifier = AuthChangeNotifier();

final router = GoRouter(
  initialLocation: RoutePath.splash,
  // ✅ 필수!
  observers: [getIt<RouteObserver<PageRoute>>()],
  refreshListenable: authChangeNotifier,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final loggingIn =
        state.matchedLocation == RoutePath.login ||
        state.matchedLocation == RoutePath.signUp ||
        state.matchedLocation == RoutePath.verifyEmail;

    if (user == null && !loggingIn) return RoutePath.login;

    if (user != null && loggingIn) return RoutePath.splash;

    return null;
  },

  routes: [
    GoRoute(
      path: RoutePath.splash,
      pageBuilder: (context, state) {
        return _fadePage(child: const SplashScreen(), state: state);
      },
    ),
    GoRoute(
      path: RoutePath.home,
      pageBuilder: (context, state) {
        return _fadePage(child: const HomeScreen(), state: state);
      },
    ),
    GoRoute(
      path: RoutePath.registration,
      pageBuilder: (context, state) {
        return _fadePage(
          child: RegistrationScreen(
            customerModel: state.extra as CustomerModel?,
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: RoutePath.signUp,
      pageBuilder: (context, state) {
        return _fadePage(child: const SignUpScreen(), state: state);
      },
    ),
    GoRoute(
      path: RoutePath.login,
      pageBuilder: (context, state) {
        return _fadePage(child: const LoginScreen(), state: state);
      },
    ),
    GoRoute(
      path: RoutePath.verifyEmail,
      pageBuilder: (context, state) {
        return _fadePage(child: const VerifyEmailScreen(), state: state);
      },
    ),
    GoRoute(
      path: RoutePath.onboarding,
      pageBuilder: (context, state) {
        return _fadePage(child: const OnboardingScreen(), state: state);
      },
    ),

    GoRoute(
      path: RoutePath.policy,
      pageBuilder: (context, state) {
        return _fadePage(
          child: PolicyScreen(customer: state.extra as CustomerModel),
          state: state,
        );
      },
    ),
    GoRoute(
      path: RoutePath.customer,
      pageBuilder: (context, state) {
        return _fadePage(
          child: CustomerScreen(customer: state.extra as CustomerModel),
          state: state,
        );
      },
    ),
  ],
);

CustomTransitionPage _fadePage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: AppDurations.duration300,
  );
}

class AuthChangeNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _subscription;

  AuthChangeNotifier() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
