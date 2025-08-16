import 'package:flutter/material.dart';

import '../../ui/core_ui_import.dart';
// add_policy_widget.dart
import 'package:flutter/material.dart';
// add_policy_widget.dart
import 'package:flutter/material.dart';

class AddPolicyWidget extends StatefulWidget {
  final void Function() onTap;
  final double size;
  final Color? iconColor; // 추가

  const AddPolicyWidget({
    super.key,
    required this.onTap,
    this.size = 35,
    this.iconColor,
  });

  @override
  State<AddPolicyWidget> createState() => _AddPolicyWidgetState();
}

class _AddPolicyWidgetState extends State<AddPolicyWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = widget.iconColor ?? colorScheme.onPrimary;

    _colorAnimation = ColorTween(
      begin: colorScheme.primary,
      end: colorScheme.primaryContainer,
    ).animate(_animationController);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Icon(
                    Icons.description,
                    color: iconColor, // 전달받은 색상 사용
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
