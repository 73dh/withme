import 'package:flutter/material.dart';
import 'package:withme/core/utils/get_sex_icon_color.dart';

import '../../../domain/model/customer_model.dart';

class FirstNameIcon extends StatefulWidget {
  final CustomerModel customer;
  final double size;
  final double badgeSize;
  final int todoCount;
  final bool hasOverdueTodo; // ✅ 기한 초과 여부

  const FirstNameIcon({
    super.key,
    required this.customer,
    this.size = 38,
    this.badgeSize = 14,
    this.todoCount = 0,
    this.hasOverdueTodo = false,
  });

  @override
  State<FirstNameIcon> createState() => _FirstNameIconState();
}

class _FirstNameIconState extends State<FirstNameIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // ✅ 무한 반복 깜빡임

    _opacity = Tween(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = getSexIconColor(widget.customer.sex, colorScheme);

    final circle = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        widget.customer.name.isNotEmpty ? widget.customer.name[0] : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: widget.size * 0.5,
        ),
      ),
    );

    if (widget.todoCount == 0) return circle;

    return _buildBadge(colorScheme, circle);
  }

  Widget _buildBadge(ColorScheme colorScheme, Widget circle) {
    final badgeFontSize = 7.0;
    final badgeSize = widget.badgeSize; // 기본 12

    // 공통 뱃지 빌더
    Widget buildBadge({required Color bgColor, required Color textColor}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 0.8), // ✅ 얇은 테두리
        ),
        constraints: BoxConstraints(
          minWidth: badgeSize,
          minHeight: badgeSize,
        ),
        alignment: Alignment.center,
        child: Text(
          '${widget.todoCount}',
          style: TextStyle(
            color: textColor,
            fontSize: badgeFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (!widget.hasOverdueTodo) {
      // 🔹 일반 뱃지 (테두리만 있음)
      return Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          Positioned(
            right: -2,
            top: -2,
            child: buildBadge(
              bgColor: colorScheme.error,
              textColor: colorScheme.onError,
            ),
          ),
        ],
      );
    }

    // 🔴 기한 초과된 경우 → 색상 반전 애니메이션
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final backgroundColor =
        Color.lerp(colorScheme.error, colorScheme.onError, t)!;
        final textColor =
        Color.lerp(colorScheme.onError, colorScheme.error, t)!;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            circle,
            Positioned(
              right: -2,
              top: -2,
              child: buildBadge(
                bgColor: backgroundColor,
                textColor: textColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
