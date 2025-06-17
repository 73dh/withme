import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/ui/const/duration.dart';

import '../../../../core/presentation/core_presentation_import.dart';
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
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: PartBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.black87),
                        width(5),
                         Text('${FirebaseAuth.instance.currentUser?.email}'),
                      ],
                    ),
                    height(15),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.black87),
                        width(5),
                        Text('${FirebaseAuth.instance.currentUser?.email}'),
                      ],
                    ),
                    height(15),
                    GestureDetector(
                      onTap: onTap,
                      child: Row(
                        children: [
                          const Icon(Icons.exit_to_app, color: Colors.black87),
                          width(5),
                          const Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }
}
