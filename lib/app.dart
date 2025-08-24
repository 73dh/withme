import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:withme/core/router/router.dart';

import 'core/system/auto_exit_wrapper.dart';
import 'core/ui/theme/theme.dart';
import 'core/ui/theme/theme_components.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData().textTheme;
    final materialTheme = MaterialTheme(baseTextTheme);
    ThemeData applyCustomTheme(ThemeData base) {
      final colors = base.colorScheme;
      return base.copyWith(
        textTheme: base.textTheme.apply(fontFamily: 'Noto Sans Korean'),
        appBarTheme: buildAppBarTheme(colors),
        bottomNavigationBarTheme: buildBottomNavTheme(colors),
        floatingActionButtonTheme: buildFloatingActionButtonTheme(colors),
      );
    }

    return AutoExitWrapper(
      duration: const Duration(seconds: 10),
      onTimeout: () {
        // 2) 앱을 홈으로 보내고 백그라운드에 두기 (권장)
        SystemNavigator.pop();
      },
      child: MaterialApp.router(
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
      ),
    );
  }
}
