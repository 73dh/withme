import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
class AnalyticsRouteObserver extends NavigatorObserver {
  final FirebaseAnalytics analytics;
  AnalyticsRouteObserver(this.analytics);

  void _sendScreenView(Route<dynamic>? route) {
    if (route is PageRoute) {
      final settings = route.settings;
      final name = settings.name ?? route.runtimeType.toString();

      debugPrint('📊 Route change → $name');

      analytics.logScreenView(
        screenName: name,
        screenClass: route.runtimeType.toString(),
      );
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _sendScreenView(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _sendScreenView(previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _sendScreenView(newRoute);
  }
}
