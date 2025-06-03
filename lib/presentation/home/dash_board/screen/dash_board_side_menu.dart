import 'package:flutter/material.dart';
import 'package:withme/core/ui/const/duration.dart';

import '../../../../core/ui/core_ui_import.dart';

class DashBoardSideMenu extends StatelessWidget {
  final double menuXPosition;
  final double menuWidth;
  final void Function() onTap;

  const DashBoardSideMenu({
    super.key,
    required this.menuXPosition,
    required this.menuWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedContainer(
        duration: AppDurations.duration300,
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(menuXPosition, 0, 0),
        child: SizedBox(
          width: menuWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(title: Text('Setting', style: TextStyles.bold12)),
              ListTile(
                onTap: onTap,
                leading: const Icon(Icons.exit_to_app, color: Colors.black87),
                title: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
