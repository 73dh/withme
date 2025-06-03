import 'package:flutter/material.dart';
import 'package:withme/core/ui/const/duration.dart';

class EditToggleIcon extends StatelessWidget {
  final bool isReadOnly;
  final void Function() onPressed;
  const EditToggleIcon({super.key, required this.isReadOnly, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: AppDurations.duration500,
        child: Icon(
          isReadOnly ? Icons.edit : Icons.check,
          key: ValueKey(isReadOnly),
        ),
        transitionBuilder:
            (child, anim) => RotationTransition(turns: anim, child: child),
      ),
      onPressed: onPressed,
    );
  }
}
