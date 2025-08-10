import 'package:flutter/material.dart';

import '../../ui/core_ui_import.dart';

class AddPolicyWidget extends StatefulWidget {
  final void Function() onTap;
  final double size;

  const AddPolicyWidget({super.key, required this.onTap, this.size = 35});

  @override
  State<AddPolicyWidget> createState() => _AddPolicyWidgetState();
}

class _AddPolicyWidgetState extends State<AddPolicyWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Color?> _colorAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: ColorStyles.activeSwitchColor,
      end: ColorStyles.activeSearchButtonColor,
    ).animate(_animationController);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: const Icon(
                    Icons.description,
                    color: Colors.white,
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
