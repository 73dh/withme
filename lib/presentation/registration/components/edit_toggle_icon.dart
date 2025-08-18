import 'package:flutter/material.dart';
import 'package:withme/core/ui/const/duration.dart';

class EditToggleIcon extends StatelessWidget {
  final bool isReadOnly;
  final void Function() onPressed;
  final Color? color; // 추가

  const EditToggleIcon({
    super.key,
    required this.isReadOnly,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = color ?? colorScheme.primary; // theme 기반 기본값

    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: AnimatedSwitcher(
          duration: AppDurations.duration500,
          child: Icon(
            isReadOnly ? Icons.edit : Icons.check,
            key: ValueKey(isReadOnly),
            color: iconColor, // 전달된 color 적용
          ),
          transitionBuilder:
              (child, anim) => RotationTransition(turns: anim, child: child),
        ),
      ),
    );
  }
}
