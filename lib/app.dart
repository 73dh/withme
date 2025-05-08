import 'package:flutter/material.dart';
import 'package:withme/core/router/router.dart';

import 'core/ui/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: theme,
    );
  }
}
