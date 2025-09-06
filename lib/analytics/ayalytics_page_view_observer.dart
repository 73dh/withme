import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

mixin AnalyticsPageViewObserver<T extends StatefulWidget> on State<T> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> logTabChange(String tabName, String screenClass) async {
    print('📊 [Analytics] Tab change → $tabName');

    await analytics.logScreenView(
      screenName: tabName, // ✅ 탭 이름을 화면 이름으로 기록
      screenClass: screenClass, // "HomeScreen" 같이 상위 클래스명
    );
  }
}
