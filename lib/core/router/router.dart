import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/router/router_path.dart';
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
    GoRoute(builder: (_, __) => const HomeScreen(), path: RoutePath.home),
    GoRoute(
      path: RoutePath.registration,
      pageBuilder: (context, state) {
        final customer = state.extra as CustomerModel;

        return CustomTransitionPage(
          key: state.pageKey,
          child: RegistrationScreen(customerModel: state.extra as CustomerModel?),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),
    // GoRoute(
    //   builder:
    //       (_, state) =>
    //           RegistrationScreen(customerModel: state.extra as CustomerModel?),
    //   path: RoutePath.registration,
    // ),
    GoRoute(
      builder:
          (_, state) => PolicyScreen(customer: state.extra as CustomerModel),
      path: RoutePath.policy,
    ),
    GoRoute(
      builder: (_, state) =>  CustomerScreen(customer: state.extra as CustomerModel,),
      path: RoutePath.customer,
    ),
  ],
);
