import 'package:flutter/material.dart';
import 'package:withme/core/utils/get_earliest_upcoming_birthday.dart';

import '../../../domain/domain_import.dart';
import '../../../domain/model/policy_model.dart';
import '../../domain/enum/payment_status.dart';
import '../../utils/check_payment_status.dart'; // ✅ checkPaymentStatus, PaymentStatus import
import '../../utils/is_birthday_within_7days.dart';
import '../core_presentation_import.dart';
import 'birthday_badge.dart';

class InsuredMembersIcon extends StatefulWidget {
  final CustomerModel customer;
  final double size;

  const InsuredMembersIcon({super.key, required this.customer, this.size = 32});

  @override
  State<InsuredMembersIcon> createState() => _InsuredMembersIconState();
}

class _InsuredMembersIconState extends State<InsuredMembersIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // 깜빡임
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<PolicyModel> policies = widget.customer.policies;
    final int totalCount = policies.length;
    final int displayCount = totalCount >= 5 ? 4 : totalCount;

    final List<Color> circleColors = [
      Colors.purple.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.blue.shade400,
    ];

    // 원 크기 및 위치 정의
    double circleSize;
    List<Offset> positions;

    switch (displayCount) {
      case 1:
        circleSize = widget.size;
        positions = [const Offset(0, 0)];
        break;
      case 2:
        circleSize = widget.size * 0.7;
        positions = [
          Offset(0, widget.size * 0.15),
          Offset(widget.size * 0.3, 0),
        ];
        break;
      case 3:
        circleSize = widget.size * 0.7;
        positions = [
          Offset(0, widget.size * 0.2),
          Offset(widget.size * 0.35, 0),
          Offset(widget.size * 0.5, widget.size * 0.4),
        ];
        break;
      default:
        circleSize = widget.size * 0.6;
        positions = [
          const Offset(0, 0),
          Offset(widget.size * 0.5, 0),
          Offset(0, widget.size * 0.5),
          Offset(widget.size * 0.5, widget.size * 0.5),
        ];
    }

    // ✅ birthday 여부 체크
    final bool hasUpcomingBirthday = policies.any(
      (p) => p.insuredBirth != null && isBirthdayWithin7Days(p.insuredBirth!),
    );

    // ✅ 납입 상태 체크
    final bool hasSoonPaid = policies.any(
      (p) => checkPaymentStatus(p) == PaymentStatus.soonPaid,
    );
    final bool hasPaid = policies.any(
      (p) => checkPaymentStatus(p) == PaymentStatus.paid,
    );

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 원 표시
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: positions[i].dx,
              top: positions[i].dy + (circleSize / 2),
              child: _buildCircle(
                policies[i].insured.characters.firstOrNull ?? '?',
                circleSize,
                circleColors[i % circleColors.length],
              ),
            ),

          // 5개 이상일 경우 우측 상단 배지
          if (totalCount > 4)
            Positioned(
              top: -4,
              right: -4,
              child: _buildBadge(totalCount.toString(), Colors.purple),
            ),

          // ✅ 생일 배지 (좌측 하단)
          if (hasUpcomingBirthday)
            Positioned(
              top: 2,
              left: -2,
              child: BirthdayBadge(
                iconSize: 18,
                isShowDate: false,
                birth: getEarliestUpcomingBirthday(policies),
              ),
            ),

          // ✅ 납입완료건 or 완료임박건 표시 (우측 하단)
          if (hasSoonPaid || hasPaid)
            Positioned(
              left: -1,
              bottom: -20,
              child:
                  hasSoonPaid
                      ? FadeTransition(
                        opacity: _blinkController,
                        child: _buildDot(
                          Theme.of(context).colorScheme.error,
                        ), // ✅ 완료임박 = error
                      )
                      : _buildDot(
                        Theme.of(context).colorScheme.primary,
                      ), // ✅ 납입완료 = primary
            ),
        ],
      ),
    );
  }

  Widget _buildCircle(String letter, double circleSize, Color color) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(fontSize: circleSize * 0.7, color: Colors.white),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDot(Color color) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: colorScheme.surface, // ✅ 배경색과 자연스럽게 맞춤
          width: 2,
        ),
      ),
    );
  }
}
