import 'package:flutter/material.dart';

import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';

class MainFab extends StatefulWidget {
  final bool fabVisibleLocal;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const MainFab({
    super.key,
    required this.fabVisibleLocal,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<MainFab> createState() => _MainFabState();
}

class _MainFabState extends State<MainFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.duration300,
      vsync: this,
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (widget.fabVisibleLocal) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant MainFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fabVisibleLocal) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = widget.backgroundColor ?? colorScheme.primary;
    final fgColor = widget.foregroundColor ?? colorScheme.onPrimary;

    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: FloatingActionButton(
          heroTag: 'fabMain',
          onPressed: widget.onPressed,
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          child: SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(
              IconsPath.personAdd,
              color: fgColor, // tint 적용
            ),
          ),
        ),
      ),
    );
  }
}
