import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:withme/core/router/router.dart';
import 'package:withme/main.dart';

import 'core/ui/theme/theme.dart';
import 'core/ui/theme/theme_controller.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,

          // theme: theme,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode:ThemeMode.system,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko'), // 한국어 지원
            // 필요시 다른 로케일 추가 가능
          ],
          locale: const Locale('ko'), // 앱 전체 로케일을 한국어로 강제
        )
        ;
      });
  }
}
