import 'package:flutter/material.dart';

import '../../ui/const/duration.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double progress; // 0.0 ~ 1.0
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final Color progressColor;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.duration = AppDurations.durationOneSec,
    this.height = 16.0,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    final totalWidth = MediaQuery.of(context).size.width / 3;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 3),
      child: Container(
        padding: EdgeInsets.zero,
        width: totalWidth,
        height: height,
        color: backgroundColor,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
          duration: duration,
          builder: (context, value, _) {
            return Stack(
              children: [
                Container(
                  width: totalWidth * value,
                  height: height,
                  color: progressColor,
                ),
                Center(
                  child: Text(
                    '${(value * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
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
