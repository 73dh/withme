import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

mixin AnalyticsPageViewObserver<T extends StatefulWidget> on State<T> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> logTabChange(String tabLabel, {required String screenClass}) async {
    debugPrint('📊 [Analytics] Tab change → $tabLabel');
    await analytics.logScreenView(
      screenName: tabLabel, // ✅ 한글 라벨을 직접 기록
      screenClass: screenClass,
    );
  }
}
