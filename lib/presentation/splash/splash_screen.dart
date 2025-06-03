import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/const/duration.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    initScreen();
    super.initState();
  }

  void initScreen() async {
    await Future.delayed(AppDurations.duration300);
    if (mounted) {
      context.go(RoutePath.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Material(child: Center(child: Text('withMe')));
  }
}
