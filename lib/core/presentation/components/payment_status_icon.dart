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
      duration: const Duration(milliseconds: 1000),
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
      // 완료임박 → 점멸 + 텍스트
        return AnimatedBuilder(
          animation: _opacityAnim,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnim.value,
              child: Container(
                height: widget.size + 6,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.error, // theme error 컬러
                  borderRadius: BorderRadius.circular(widget.size / 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '완료임박',
                  style: TextStyle(
                    color: colorScheme.onError, // error 위의 텍스트 색
                    fontSize: widget.size * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );

      case PaymentStatus.paid:
      // 납입완료 → theme success 계열
        return Container(
          height: widget.size + 6,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.primary, // primary 컬러 사용
            borderRadius: BorderRadius.circular(widget.size / 2),
          ),
          alignment: Alignment.center,
          child: Text(
            '납입완료',
            style: TextStyle(
              color: colorScheme.onPrimary, // primary 위 텍스트 색
              fontSize: widget.size * 0.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

      case PaymentStatus.paying:
        return const SizedBox.shrink();

      case PaymentStatus.all:
        return const SizedBox.shrink();
    }
  }
}
