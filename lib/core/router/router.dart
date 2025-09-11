import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/analytics/analytics_route_observer.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/presentation/auth/log_in/log_in_screen.dart';
import 'package:withme/presentation/customer/screen/customer_screen.dart';
import 'package:withme/presentation/home/home_screen.dart';
import 'package:withme/presentation/splash/splash_screen.dart';

import '../../domain/model/customer_model.dart';
import '../../presentation/auth/on_boarding/on_boarding_screen.dart';
import '../../presentation/auth/sign_up/sign_up_screen.dart';
import '../../presentation/auth/verity_email/verify_email_screen.dart';
import '../../presentation/policy/screen/policy_screen.dart';
import '../../presentation/registration/screen/registration_screen.dart';
import '../di/setup.dart';
import '../presentation/todo/todo_view_model.dart';

final authChangeNotifier = AuthChangeNotifier();
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

final router = GoRouter(
  initialLocation: RoutePath.splash,
  observers: [
    getIt<RouteObserver<PageRoute>>(),
    AnalyticsRouteObserver(analytics),
  ],
  refreshListenable: authChangeNotifier,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isFirebaseLoggedIn = user != null && user.emailVerified;
    final isLoggedIn = isFirebaseLoggedIn && authChangeNotifier.isLoggedIn;

    final location = state.uri.toString(); // location 대신 사용

    final isLoginRoute = [
      RoutePath.login,
      RoutePath.signUp,
      RoutePath.verifyEmail,
    ].contains(location);
    final isSplash = location == RoutePath.splash;
    final isOnboarding = location == RoutePath.onboarding;

    // 1. 로그인 안 되어 있으면 로그인 화면으로
    if (!isLoggedIn) {
      return isLoginRoute ? null : RoutePath.login;
    }

    // 2. 온보딩 필요 시 온보딩 화면으로
    if (authChangeNotifier.needsOnboarding) {
      return isOnboarding ? null : RoutePath.onboarding;
    }

    // 3. 데이터 아직 안 불러왔으면 Splash 유지
    if (!authChangeNotifier.isDataLoaded) {
      return isSplash ? null : RoutePath.splash;
    }

    // 4. Splash 상태인데 데이터 다 불러왔으면 Home으로 이동
    if (authChangeNotifier.isDataLoaded && isSplash) {
      return RoutePath.home;
    }

    // 5. 로그인 상태인데 로그인 화면에 있으면 Home으로
    if (isLoggedIn && isLoginRoute) {
      return RoutePath.home;
    }

    return null;
  },

  routes: [
    GoRoute(
      path: RoutePath.splash,
      pageBuilder: (context, state) {
        return fadePage(
          child: const SplashScreen(),
          state: state,
          name: 'SplashScreen',
        );
      },
    ),
    GoRoute(
      path: RoutePath.home,
      pageBuilder:
          (context, state) => fadePage(
            child: const HomeScreen(),
            state: state,
            name: 'HomeScreen',
          ),
    ),
    GoRoute(
      path: RoutePath.registration,
      pageBuilder: (context, state) {
        final customer = state.extra as CustomerModel?;
        final todoViewModel = getIt<TodoViewModel>(); // ⚡ 반드시 주입
        return fadePage(
          child: RegistrationScreen(
            customer: customer,
            scrollController: ScrollController(), // 필요 시 기본 ScrollController
            // outerContext: context,
            todoViewModel: todoViewModel,
          ),
          state: state,
          name: 'RegistrationScreen',
        );
      },
    ),
    GoRoute(
      path: RoutePath.signUp,
      pageBuilder:
          (context, state) => fadePage(
            child: const SignUpScreen(),
            state: state,
            name: 'SignupScreen',
          ),
    ),
    GoRoute(
      path: RoutePath.login,
      pageBuilder:
          (context, state) => fadePage(
            child: const LoginScreen(),
            state: state,
            name: 'LoginScreen',
          ),
    ),
    GoRoute(
      path: RoutePath.verifyEmail,
      pageBuilder:
          (context, state) => fadePage(
            child: const VerifyEmailScreen(),
            state: state,
            name: 'VerifyEmail',
          ),
    ),
    GoRoute(
      path: RoutePath.onboarding,
      pageBuilder:
          (context, state) => fadePage(
            child: const OnboardingScreen(),
            state: state,
            name: 'Onboarding',
          ),
    ),
    GoRoute(
      path: RoutePath.policy,
      pageBuilder:
          (context, state) => fadePage(
            child: PolicyScreen(customer: state.extra as CustomerModel),
            state: state,
            name: 'PolicyScreen',
          ),
    ),
    GoRoute(
      path: RoutePath.customer,
      pageBuilder:
          (context, state) => fadePage(
            child: CustomerScreen(customer: state.extra as CustomerModel),
            state: state,
            name: 'CustomerScreen',
          ),
    ),
  ],
);

Page<T> fadePage<T>({
  required Widget child,
  required GoRouterState state,
  required String name,
}) {
  return MaterialPage<T>(
    key: state.pageKey,
    name: name, // ✅ RouteSettings.name 으로 Analytics에 기록됨
    child: _FadeTransitionWrapper(child: child),
  );
}

class _FadeTransitionWrapper extends StatefulWidget {
  final Widget child;

  const _FadeTransitionWrapper({required this.child});

  @override
  State<_FadeTransitionWrapper> createState() => _FadeTransitionWrapperState();
}

class _FadeTransitionWrapperState extends State<_FadeTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

// CustomTransitionPage _fadePage({
//   required Widget child,
//   required GoRouterState state,
//   required String name, // route 추적 위해 추가
// }) {
//   return CustomTransitionPage(
//     key: state.pageKey,
//     name: name,
//     // ✅ RouteSettings.name 으로 들어감
//     child: child,
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       return FadeTransition(opacity: animation, child: child);
//     },
//     transitionDuration: AppDurations.duration300,
//   );
// }

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
