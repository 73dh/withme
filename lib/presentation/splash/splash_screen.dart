import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/components/my_circular_indicator.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/const/duration.dart';

import '../../core/di/di_setup_import.dart';
import '../../core/di/setup.dart';
import '../../core/ui/core_ui_import.dart';

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
    await Future.wait([
      getIt<ProspectListViewModel>().fetchData(),
      getIt<CustomerListViewModel>().refresh(),

    ]);
    await Future.delayed(AppDurations.duration300);
    if (mounted) {
      context.go(RoutePath.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Material(child: Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('withMe',style: TextStyles.bold20,),
        height(20),
        MyCircularIndicator(),
      ],
    )));
  }
}
