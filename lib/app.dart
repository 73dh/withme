import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:withme/core/router/router.dart';

import 'core/ui/theme/theme.dart';
import 'core/ui/theme/theme_components.dart';
import 'core/ui/theme/theme_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData(fontFamily: 'Noto Sans Korean').textTheme;
    final materialTheme = MaterialTheme(baseTextTheme);
    ThemeData applyCustomTheme(ThemeData base) {
      final colors = base.colorScheme;
      return base.copyWith(
        textTheme: baseTextTheme, // 여기서 폰트 적용
        appBarTheme: buildAppBarTheme(colors),
        bottomNavigationBarTheme: buildBottomNavTheme(colors),
        floatingActionButtonTheme: buildFloatingActionButtonTheme(colors),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      theme: applyCustomTheme(materialTheme.light()),
      darkTheme: applyCustomTheme(materialTheme.dark()),
      themeMode: ThemeMode.system,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'), // 한국어 지원
      ],
      locale: const Locale('ko'), // 앱 전체 로케일을 한국어로 강제
    );
  }
}
