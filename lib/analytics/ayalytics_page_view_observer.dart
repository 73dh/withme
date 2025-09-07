import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

mixin AnalyticsPageViewObserver<T extends StatefulWidget> on State<T> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> logTabChange(String tabName, String screenClass) async {
    print('📊 [Analytics] Tab change → $tabName');

    await analytics.logScreenView(
      screenName: tabName,
      screenClass: "${screenClass}_$tabName", // ✅ 탭별로 구분
    );
  }
}
