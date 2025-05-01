import 'package:go_router/go_router.dart';
import 'package:withme/app.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/presentation/home/customer/customer_page.dart';
import 'package:withme/presentation/home/dash_board/dash_board_page.dart';
import 'package:withme/presentation/home/home_screen.dart';
import 'package:withme/presentation/home/pool/pool_page.dart';
import 'package:withme/presentation/home/search/search_page.dart';
import 'package:withme/presentation/splash/splash_screen.dart';

final router = GoRouter(
  initialLocation: RoutePath.splash,
  routes: [
    GoRoute(builder: (_, __) => SplashScreen(), path: RoutePath.splash),
    GoRoute(
      builder: (_, __) => HomeScreen(),
      path: RoutePath.home,
      // routes: [
      //   GoRoute(builder: (_, __) => PoolPage(), path: RoutePath.pool),
      //   GoRoute(builder: (_, __) => CustomerPage(), path: RoutePath.customer),
      //   GoRoute(builder: (_, __) => SearchPage(), path: RoutePath.search),
      //   GoRoute(builder: (_, __) => DashBoardPage(), path: RoutePath.dashBoard),
      // ],
    ),
  ],
);
