import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:withme/core/router/router.dart';

import 'core/di/setup.dart';
import 'core/ui/theme/theme.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: theme,
      localizationsDelegates:  [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),  // 한국어 지원
        // 필요시 다른 로케일 추가 가능
      ],
      locale: const Locale('ko'),  // 앱 전체 로케일을 한국어로 강제
    );
  }
}
