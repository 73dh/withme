import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/presentation/customer/customer_screen.dart';
import 'package:withme/presentation/home/home_screen.dart';
import 'package:withme/presentation/registration/screen/registration_screen.dart';
import 'package:withme/presentation/splash/splash_screen.dart';

import '../../domain/model/customer_model.dart';
import '../../presentation/policy/policy_screen.dart';

final router = GoRouter(
  initialLocation: RoutePath.splash,
  routes: [
    GoRoute(builder: (_, __) => const SplashScreen(), path: RoutePath.splash),
    GoRoute(path: RoutePath.home,pageBuilder: (context,state){
      return _fadePage(child: HomeScreen(), state: state);
    }, ),
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
