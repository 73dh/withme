import 'package:flutter/material.dart';

import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';

class MainFab extends StatefulWidget {
  final bool fabVisibleLocal;
  final VoidCallback? onPressed;

  const MainFab({super.key, required this.fabVisibleLocal, this.onPressed});

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

    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: FloatingActionButton(
          heroTag: 'fabMain',
          onPressed: widget.onPressed,
          backgroundColor: colorScheme.primary,
          // FAB 배경색
          foregroundColor: colorScheme.onPrimary,
          // FAB 아이콘 색
          child: SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(
              IconsPath.personAdd,
              color: colorScheme.onPrimary, // 이미지 tint 적용
            ),
          ),
        ),
      ),
    );
  }
}
