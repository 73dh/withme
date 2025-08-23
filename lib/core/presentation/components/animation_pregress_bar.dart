import 'package:flutter/material.dart';

import '../../ui/const/duration.dart';

class AnimatedProgressBar extends StatefulWidget {
  final double progress; // 0.0 ~ 1.0
  final Duration duration;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final Color? textColor;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.duration = AppDurations.durationOneSec,
    this.height = 18.0,
    this.backgroundColor,
    this.progressColor,
    this.textColor,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalWidth = MediaQuery.of(context).size.width / 3;
    final isFull = widget.progress >= 1.0;

    final progressColor = widget.progressColor ?? colorScheme.primary;
    final textColor = widget.textColor ?? colorScheme.surface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.height / 3),
      child: Container(
        width: totalWidth,
        height: widget.height,
        color: progressColor,
        child:
            isFull
                ? FadeTransition(
                  opacity: _blinkController,
                  child: Center(
                    child: Text(
                      '100%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
                : TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: widget.progress.clamp(0.0, 1.0),
                  ),
                  duration: widget.duration,
                  builder: (context, value, _) {
                    return Stack(
                      children: [
                        Container(
                          width: totalWidth * value,
                          height: widget.height,
                          color: progressColor,
                        ),
                        Center(
                          child: Text(
                            '${(value * 100).toInt()}%',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      ),
    );
  }
}
