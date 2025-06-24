import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/presentation/auth/log_in/log_in_screen.dart';
import 'package:withme/presentation/customer/screen/customer_screen.dart';
import 'package:withme/presentation/home/home_screen.dart';
import 'package:withme/presentation/registration/screen/registration_screen.dart';
import 'package:withme/presentation/splash/splash_screen.dart';

import '../../domain/model/customer_model.dart';
import '../../presentation/auth/on_boarding/on_boarding_screen.dart';
import '../../presentation/auth/sign_up/sign_up_screen.dart';
import '../../presentation/auth/verity_email/verify_email_screen.dart';
import '../../presentation/policy/screen/policy_screen.dart';
import '../di/setup.dart';

final authChangeNotifier = AuthChangeNotifier();

final router = GoRouter(
  initialLocation: RoutePath.splash,
  observers: [getIt<RouteObserver<PageRoute>>()],
  refreshListenable: authChangeNotifier,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isFirebaseLoggedIn = user != null && user.emailVerified;
    final isLoggedIn = isFirebaseLoggedIn && authChangeNotifier.isLoggedIn;

    // final isLoggedIn = user != null && user.emailVerified;

    final location = state.uri.toString(); // location 대신 사용

    final isOnboarding = location == RoutePath.onboarding;
    final isLoginRoute = [
      RoutePath.login,
      RoutePath.signUp,
      RoutePath.verifyEmail,
    ].contains(location);

    if (!isLoggedIn) {
      return isLoginRoute ? null : RoutePath.login;
    }

    if (authChangeNotifier.needsOnboarding) {
      return isOnboarding ? null : RoutePath.onboarding;
    }

    if (!authChangeNotifier.isDataLoaded && location != RoutePath.splash) {
      return RoutePath.splash;
    }

    if (isLoggedIn && isLoginRoute) {
      return RoutePath.home;
    }

    return null;
  },

  routes: [
    GoRoute(
      path: RoutePath.splash,
      pageBuilder:
          (context, state) =>
              _fadePage(child: const SplashScreen(), state: state),
    ),
    GoRoute(
      path: RoutePath.home,
      pageBuilder:
          (context, state) =>
              _fadePage(child: const HomeScreen(), state: state),
    ),
    GoRoute(
      path: RoutePath.registration,
      pageBuilder:
          (context, state) => _fadePage(
            child: RegistrationScreen(
              customerModel: state.extra as CustomerModel?,
            ),
            state: state,
          ),
    ),
    GoRoute(
      path: RoutePath.signUp,
      pageBuilder:
          (context, state) =>
              _fadePage(child: const SignUpScreen(), state: state),
    ),
    GoRoute(
      path: RoutePath.login,
      pageBuilder:
          (context, state) =>
              _fadePage(child: const LoginScreen(), state: state),
    ),
    GoRoute(
      path: RoutePath.verifyEmail,
      pageBuilder:
          (context, state) =>
              _fadePage(child: const VerifyEmailScreen(), state: state),
    ),
    GoRoute(
      path: RoutePath.onboarding,
      pageBuilder:
          (context, state) =>
              _fadePage(child: const OnboardingScreen(), state: state),
    ),
    GoRoute(
      path: RoutePath.policy,
      pageBuilder:
          (context, state) => _fadePage(
            child: PolicyScreen(customer: state.extra as CustomerModel),
            state: state,
          ),
    ),
    GoRoute(
      path: RoutePath.customer,
      pageBuilder:
          (context, state) => _fadePage(
            child: CustomerScreen(customer: state.extra as CustomerModel),
            state: state,
          ),
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
  bool _needsOnboarding = false;
  bool _isDataLoaded = false;
  bool _isLoggedIn = true; // 기본값은 로그인 상태라 가정
  bool get needsOnboarding => _needsOnboarding;

  bool get isDataLoaded => _isDataLoaded;

  bool get isLoggedIn => _isLoggedIn;

  void setNeedsOnboarding(bool value) {
    if (_needsOnboarding != value) {
      _needsOnboarding = value;
      notifyListeners();
    }
  }

  void setDataLoaded(bool value) {
    if (_isDataLoaded != value) {
      _isDataLoaded = value;
      notifyListeners();
    }
  }

  void setLoggedIn(bool value) {
    if (_isLoggedIn != value) {
      _isLoggedIn = value;
      notifyListeners();
    }
  }
}
