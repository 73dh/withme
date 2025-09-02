import '../../domain/model/policy_model.dart';
import '../data/fire_base/user_session.dart';
import '../domain/enum/payment_status.dart';

PaymentStatus checkPaymentStatus(PolicyModel policy) {
  final now = DateTime.now();

  // startDate가 null이면 납입중으로 간주
  if (policy.startDate == null) return PaymentStatus.paying;

  // 납입기간 종료일 계산 (연 단위 → 월 단위로 변환)
  final endDate = DateTime(
    policy.startDate!.year + policy.paymentPeriod,
    policy.startDate!.month,
    policy.startDate!.day,
  );

  // 종료일까지 남은 개월 수 계산
  final remainingMonths =
      (endDate.year - now.year) * 12 + (endDate.month - now.month);

  // UserSession에서 사용자 설정값 가져오기
  final threshold = UserSession().remainPaymentMonth;

  if (now.isAfter(endDate)) {
    return PaymentStatus.paid; // 이미 납입 완료
  } else if (remainingMonths <= threshold) {
    return PaymentStatus.soonPaid; // 사용자 설정 개월 수 이내
  } else {
    return PaymentStatus.paying; // 납입중
  }
}
