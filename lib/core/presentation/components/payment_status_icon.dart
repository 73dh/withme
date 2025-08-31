import 'package:flutter/material.dart';
import 'package:withme/core/domain/enum/payment_status.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/domain/enum/payment_status.dart';

class PaymentStatusIcon extends StatefulWidget {
  const PaymentStatusIcon({super.key, required this.status, this.size = 18});

  final PaymentStatus status;
  final double size;

  @override
  State<PaymentStatusIcon> createState() => _PaymentStatusIconState();
}

class _PaymentStatusIconState extends State<PaymentStatusIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnim = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (widget.status) {
      case PaymentStatus.soonPaid:
      // 완료임박 → 동그란 배경 + "임박" 텍스트 + 점멸
        return AnimatedBuilder(
          animation: _opacityAnim,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnim.value,
              child: Container(
                height: widget.size + 6,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular((widget.size + 6) / 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '임박',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.size * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );

      case PaymentStatus.paid:
      // 납입완료 → 체크 아이콘
        return Icon(
          Icons.check_circle,
          size: widget.size,
          color: Colors.green,
        );

      case PaymentStatus.paying:
      case PaymentStatus.all:
        return const SizedBox.shrink(); // 아이콘 없음
    }
  }
}
