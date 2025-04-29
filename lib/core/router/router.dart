import 'package:go_router/go_router.dart';
import 'package:withme/app.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/presentation/home/home_screen.dart';
import 'package:withme/presentation/splash/splash_screen.dart';

final router = GoRouter(
  initialLocation: RoutePath.splash,
  routes: [
    GoRoute(builder: (_, __) => SplashScreen(), path: RoutePath.splash),
    GoRoute(builder: (_, __) => HomeScreen(), path: RoutePath.home),
  ],
);
